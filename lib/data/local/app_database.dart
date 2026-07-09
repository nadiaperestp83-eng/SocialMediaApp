import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:social_media_app/domain/entities/chat_message_entity.dart';
import 'package:social_media_app/domain/entities/chat_summary_entity.dart';

class AppDatabase {
  Database? _db;

  Future<Database> _database() async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'social_media_app_chat.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE messages (
            id TEXT PRIMARY KEY,
            chat_user_id TEXT NOT NULL,
            sender_id TEXT NOT NULL,
            receiver_id TEXT NOT NULL,
            content TEXT,
            created_at TEXT NOT NULL,
            is_mine INTEGER NOT NULL,
            status TEXT NOT NULL
          )
        ''');
        await db.execute('CREATE INDEX idx_messages_chat_user ON messages (chat_user_id)');
      },
    );
    return _db!;
  }

  Future<void> open() async {
    await _database();
  }

  Future<void> insertMessage({
    required String id,
    required String chatUserId,
    required String senderId,
    required String receiverId,
    required String content,
    required String createdAt,
    required bool isMine,
    required String status,
  }) async {
    final db = await _database();
    await db.insert(
      'messages',
      {
        'id': id,
        'chat_user_id': chatUserId,
        'sender_id': senderId,
        'receiver_id': receiverId,
        'content': content,
        'created_at': createdAt,
        'is_mine': isMine ? 1 : 0,
        'status': status,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateStatus(String id, String status) async {
    final db = await _database();
    await db.update('messages', {'status': status}, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<ChatMessageEntity>> messagesForChat(String otherUserId) async {
    final db = await _database();
    final rows = await db.query(
      'messages',
      where: 'chat_user_id = ?',
      whereArgs: [otherUserId],
      orderBy: 'created_at ASC',
    );

    return rows
        .map((r) => ChatMessageEntity(
              id: r['id'] as String,
              chatUserId: r['chat_user_id'] as String,
              senderId: r['sender_id'] as String,
              receiverId: r['receiver_id'] as String,
              content: r['content'] as String? ?? '',
              createdAt: DateTime.parse(r['created_at'] as String),
              isMine: (r['is_mine'] as int) == 1,
              status: r['status'] as String,
            ))
        .toList();
  }

  Future<List<ChatSummaryEntity>> chatSummaries() async {
    final db = await _database();
    final rows = await db.rawQuery('''
      SELECT chat_user_id, MAX(created_at) as last_at
      FROM messages
      GROUP BY chat_user_id
      ORDER BY last_at DESC
    ''');

    final summaries = <ChatSummaryEntity>[];
    for (final row in rows) {
      final chatUserId = row['chat_user_id'] as String;

      final lastMsgRows = await db.query(
        'messages',
        where: 'chat_user_id = ?',
        whereArgs: [chatUserId],
        orderBy: 'created_at DESC',
        limit: 1,
      );
      final lastMsg = lastMsgRows.first;

      final unreadRows = await db.query(
        'messages',
        where: 'chat_user_id = ? AND is_mine = 0 AND status = ?',
        whereArgs: [chatUserId, 'received'],
      );

      summaries.add(ChatSummaryEntity(
        otherUserId: chatUserId,
        otherUserName: '',
        otherUsername: '',
        otherUserAvatarUrl: '',
        lastMessage: lastMsg['content'] as String? ?? '',
        lastMessageAt: DateTime.parse(lastMsg['created_at'] as String),
        lastMessageIsMine: (lastMsg['is_mine'] as int) == 1,
        lastMessageStatus: lastMsg['status'] as String,
        unreadCount: unreadRows.length,
      ));
    }
    return summaries;
  }

  Future<void> markChatRead(String otherUserId) async {
    final db = await _database();
    await db.update(
      'messages',
      {'status': 'read'},
      where: 'chat_user_id = ? AND is_mine = 0 AND status = ?',
      whereArgs: [otherUserId, 'received'],
    );
  }
}
