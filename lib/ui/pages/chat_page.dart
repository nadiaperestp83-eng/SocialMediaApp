import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:social_media_app/app/configs/colors.dart';
import 'package:social_media_app/app/configs/theme.dart';
import 'package:social_media_app/app/resources/constant/named_routes.dart';
import 'package:social_media_app/core/providers/chat_providers.dart';
import 'package:social_media_app/domain/entities/chat_summary_entity.dart';
import 'package:social_media_app/domain/entities/profile_search_result.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(chatSessionProvider);

    final chatListAsync = ref.watch(chatListProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Conversas', style: AppTheme.blackTextStyle.copyWith(fontSize: 22, fontWeight: AppTheme.bold)),
            const SizedBox(height: 16),
            _buildSearchField(),
            const SizedBox(height: 12),
            Expanded(
              child: _query.trim().isEmpty ? _buildChatList(chatListAsync) : _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(color: AppColors.backgroundColor, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: AppColors.greyColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              style: AppTheme.blackTextStyle.copyWith(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Buscar conversas ou @username',
                hintStyle: AppTheme.greyTextStyle.copyWith(fontSize: 14),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList(AsyncValue<List<ChatSummaryEntity>> chatListAsync) {
    return chatListAsync.when(
      data: (chats) {
        if (chats.isEmpty) {
          return Center(
            child: Text('Nenhuma conversa ainda.\nUse a busca acima para começar.',
                textAlign: TextAlign.center, style: AppTheme.greyTextStyle),
          );
        }
        return ListView.separated(
          itemCount: chats.length,
          separatorBuilder: (_, __) => const SizedBox(height: 4),
          itemBuilder: (context, index) => _ChatListTile(chat: chats[index]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, st) => Center(child: Text('Erro ao carregar conversas: $err')),
    );
  }

  Widget _buildSearchResults() {
    return FutureBuilder<List<ProfileSearchResult>>(
      future: ref.read(chatRepositoryProvider).searchUsers(_query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final results = snapshot.data ?? [];
        if (results.isEmpty) {
          return Center(child: Text('Nenhum usuário encontrado.', style: AppTheme.greyTextStyle));
        }
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final user = results[index];
            return ListTile(
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.backgroundColor,
                backgroundImage: user.avatarUrl.isNotEmpty ? NetworkImage(user.avatarUrl) : null,
              ),
              title: Text(user.name, style: AppTheme.blackTextStyle.copyWith(fontWeight: AppTheme.semiBold)),
              subtitle: Text('@${user.username}', style: AppTheme.greyTextStyle.copyWith(fontSize: 12)),
              onTap: () {
                _searchController.clear();
                setState(() => _query = '');
                context.push('${NamedRoutes.chatConversationScreen}?userId=${user.id}');
              },
            );
          },
        );
      },
    );
  }
}

class _ChatListTile extends StatelessWidget {
  final ChatSummaryEntity chat;

  const _ChatListTile({required this.chat});

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 1) return 'agora';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = chat.unreadCount > 0;

    return InkWell(
      onTap: () => context.push('${NamedRoutes.chatConversationScreen}?userId=${chat.otherUserId}'),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.backgroundColor,
              backgroundImage:
                  chat.otherUserAvatarUrl.isNotEmpty ? NetworkImage(chat.otherUserAvatarUrl) : null,
              child: chat.otherUserAvatarUrl.isEmpty
                  ? const Icon(Icons.person, color: AppColors.greyColor)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.otherUserName.isNotEmpty ? chat.otherUserName : '@${chat.otherUsername}',
                    style: AppTheme.blackTextStyle.copyWith(fontWeight: AppTheme.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    chat.lastMessageStatus == 'expired'
                        ? 'Mensagem expirou sem ser vista'
                        : (chat.lastMessageIsMine ? 'Você: ${chat.lastMessage}' : chat.lastMessage),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.greyTextStyle.copyWith(
                      fontSize: 13,
                      color: chat.lastMessageStatus == 'expired' ? AppColors.dangerColor : AppColors.greyTextColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_formatTime(chat.lastMessageAt), style: AppTheme.greyTextStyle.copyWith(fontSize: 11)),
                const SizedBox(height: 6),
                if (hasUnread)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: const BoxDecoration(color: AppColors.purpleColor, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 20),
                    child: Text(
                      '${chat.unreadCount}',
                      textAlign: TextAlign.center,
                      style: AppTheme.whiteTextStyle.copyWith(fontSize: 11, fontWeight: AppTheme.bold),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
