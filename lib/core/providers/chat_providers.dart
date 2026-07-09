import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:social_media_app/core/providers/supabase_providers.dart';
import 'package:social_media_app/data/local/app_database.dart';
import 'package:social_media_app/data/repositories/supabase_chat_repository.dart';
import 'package:social_media_app/domain/entities/chat_message_entity.dart';
import 'package:social_media_app/domain/entities/chat_summary_entity.dart';
import 'package:social_media_app/domain/repositories/chat_repository.dart';

final _appDatabaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final repo = SupabaseChatRepository(
    client: ref.watch(supabaseClientProvider),
    db: ref.watch(_appDatabaseProvider),
  );
  ref.onDispose(repo.dispose);
  return repo;
});

/// Garante que o repositório de chat seja inicializado (abre o banco local
/// e assina o Realtime) uma única vez por sessão.
final chatSessionProvider = FutureProvider<void>((ref) async {
  final repo = ref.watch(chatRepositoryProvider);
  await repo.init();
});

final chatListProvider = StreamProvider<List<ChatSummaryEntity>>((ref) {
  return ref.watch(chatRepositoryProvider).watchChatList();
});

final chatMessagesProvider =
    StreamProvider.family<List<ChatMessageEntity>, String>((ref, otherUserId) {
  return ref.watch(chatRepositoryProvider).watchMessages(otherUserId);
});
