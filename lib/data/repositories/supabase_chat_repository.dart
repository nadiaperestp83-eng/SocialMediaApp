import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:social_media_app/data/local/app_database.dart';
import 'package:social_media_app/domain/entities/chat_message_entity.dart';
import 'package:social_media_app/domain/entities/chat_summary_entity.dart';
import 'package:social_media_app/domain/entities/profile_search_result.dart';
import 'package:social_media_app/domain/repositories/chat_repository.dart';

class SupabaseChatRepository implements ChatRepository {
  final SupabaseClient _client;
  final AppDatabase _db;

  SupabaseChatRepository({required SupabaseClient client, required AppDatabase db})
      : _client = client,
        _db = db;

  final _chatListController = StreamController<List<ChatSummaryEntity>>.broadcast();
  final Map<String, StreamController<List<ChatMessageEntity>>> _conversationControllers = {};

  StreamSubscription? _incomingSub;
  StreamSubscription? _outgoingSub;
  final Set<String> _pendingSentIds = {};
  bool _initialized = false;

  String get _me => _client.auth.currentUser?.id ?? '';

  @override
  Future<void> init() async {
    if (_initialized || _me.isEmpty) return;
    _initialized = true;

    await _db.open();

    _incomingSub = _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('receiver_id', _me)
        .listen(_handleIncoming);

    _outgoingSub = _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('sender_id', _me)
        .listen(_handleOutgoingStatus);

    await _refreshChatList();
  }

  Future<void> _handleIncoming(List<Map<String, dynamic>> rows) async {
    for (final row in rows) {
      if (row['status'] != 'sent') continue; // expirada/redigida: nunca chegou a ser vista

      final id = row['id'] as String;

      await _db.insertMessage(
        id: id,
        chatUserId: row['sender_id'] as String,
        senderId: row['sender_id'] as String,
        receiverId: row['receiver_id'] as String,
        content: row['content'] as String? ?? '',
        createdAt: row['created_at'] as String,
        isMine: false,
        status: 'received',
      );

      // Conteúdo já está seguro no celular: apaga do Supabase.
      await _client.from('messages').delete().eq('id', id);
    }

    await _refreshChatList();
    await _refreshOpenConversations();
  }

  Future<void> _handleOutgoingStatus(List<Map<String, dynamic>> rows) async {
    final currentIds = <String>{};
    for (final row in rows) {
      final id = row['id'] as String;
      currentIds.add(id);
      if (row['status'] == 'expired') {
        await _db.updateStatus(id, 'expired');
      }
    }

    // IDs que estavam pendentes e sumiram da lista = foram entregues
    // (o destinatário apagou a linha do Supabase depois de salvar localmente).
    final delivered = _pendingSentIds.difference(currentIds);
    for (final id in delivered) {
      await _db.updateStatus(id, 'delivered');
    }
    _pendingSentIds
      ..clear()
      ..addAll(currentIds);

    await _refreshChatList();
    await _refreshOpenConversations();
  }

  Future<void> _refreshChatList() async {
    final localSummaries = await _db.chatSummaries();
    if (localSummaries.isEmpty) {
      _chatListController.add(const []);
      return;
    }

    final ids = localSummaries.map((s) => s.otherUserId).toList();
    final profiles = await _client
        .from('profiles')
        .select('id, name, username, avatar_url')
        .inFilter('id', ids);

    final profileMap = {
      for (final p in (profiles as List)) p['id'] as String: p as Map<String, dynamic>,
    };

    final enriched = localSummaries.map((s) {
      final p = profileMap[s.otherUserId];
      return s.copyWith(
        otherUserName: p?['name'] as String? ?? 'Usuário',
        otherUsername: p?['username'] as String? ?? '',
        otherUserAvatarUrl: p?['avatar_url'] as String? ?? '',
      );
    }).toList();

    _chatListController.add(enriched);
  }

  Future<void> _refreshOpenConversations() async {
    for (final entry in _conversationControllers.entries) {
      entry.value.add(await _db.messagesForChat(entry.key));
    }
  }

  @override
  Stream<List<ChatSummaryEntity>> watchChatList() {
    _refreshChatList();
    return _chatListController.stream;
  }

  @override
  Stream<List<ChatMessageEntity>> watchMessages(String otherUserId) {
    final controller = _conversationControllers.putIfAbsent(
      otherUserId,
      () => StreamController<List<ChatMessageEntity>>.broadcast(),
    );
    _db.messagesForChat(otherUserId).then(controller.add);
    return controller.stream;
  }

  @override
  Future<void> markConversationRead(String otherUserId) async {
    await _db.markChatRead(otherUserId);
    await _refreshChatList();
    final controller = _conversationControllers[otherUserId];
    if (controller != null) {
      controller.add(await _db.messagesForChat(otherUserId));
    }
  }

  @override
  Future<void> sendMessage({required String receiverId, required String content}) async {
    final row = await _client
        .from('messages')
        .insert({
          'sender_id': _me,
          'receiver_id': receiverId,
          'content': content,
          'status': 'sent',
        })
        .select()
        .single();

    final id = row['id'] as String;
    _pendingSentIds.add(id);

    await _db.insertMessage(
      id: id,
      chatUserId: receiverId,
      senderId: _me,
      receiverId: receiverId,
      content: content,
      createdAt: row['created_at'] as String,
      isMine: true,
      status: 'sent',
    );

    await _refreshChatList();
    await _refreshOpenConversations();
  }

  @override
  Future<List<ProfileSearchResult>> searchUsers(String query) async {
    if (query.trim().isEmpty) return [];

    final rows = await _client
        .from('profiles')
        .select('id, name, username, avatar_url')
        .or('name.ilike.%$query%,username.ilike.%$query%')
        .neq('id', _me)
        .limit(20);

    return (rows as List)
        .map((r) => ProfileSearchResult(
              id: r['id'] as String,
              name: r['name'] as String? ?? '',
              username: r['username'] as String? ?? '',
              avatarUrl: r['avatar_url'] as String? ?? '',
            ))
        .toList();
  }

  @override
  Future<void> dispose() async {
    await _incomingSub?.cancel();
    await _outgoingSub?.cancel();
    await _chatListController.close();
    for (final c in _conversationControllers.values) {
      await c.close();
    }
  }
}
