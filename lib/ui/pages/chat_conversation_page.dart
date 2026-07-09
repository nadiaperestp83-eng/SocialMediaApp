import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:social_media_app/app/configs/colors.dart';
import 'package:social_media_app/app/configs/theme.dart';
import 'package:social_media_app/core/providers/chat_providers.dart';
import 'package:social_media_app/core/providers/supabase_providers.dart';
import 'package:social_media_app/domain/entities/chat_message_entity.dart';

class ChatConversationPage extends ConsumerStatefulWidget {
  final String otherUserId;

  const ChatConversationPage({super.key, required this.otherUserId});

  @override
  ConsumerState<ChatConversationPage> createState() => _ChatConversationPageState();
}

class _ChatConversationPageState extends ConsumerState<ChatConversationPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatRepositoryProvider).markConversationRead(widget.otherUserId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _messageController.clear();
    try {
      await ref.read(chatRepositoryProvider).sendMessage(receiverId: widget.otherUserId, content: text);
      await Future.delayed(const Duration(milliseconds: 100));
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider(widget.otherUserId));

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.blackColor),
        title: FutureBuilder(
          future: ref
              .read(supabaseClientProvider)
              .from('profiles')
              .select('name, username, avatar_url')
              .eq('id', widget.otherUserId)
              .single(),
          builder: (context, snapshot) {
            final data = snapshot.data as Map<String, dynamic>?;
            final name = data?['name'] as String? ?? 'Conversa';
            return Text(name, style: AppTheme.blackTextStyle.copyWith(fontWeight: AppTheme.bold, fontSize: 16));
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: messagesAsync.when(
                data: (messages) {
                  if (messages.isEmpty) {
                    return Center(child: Text('Diga oi 👋', style: AppTheme.greyTextStyle));
                  }
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                    }
                  });
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) => _MessageBubble(message: messages[index]),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, st) => Center(child: Text('Erro: $err')),
              ),
            ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
              decoration: InputDecoration(
                hintText: 'Mensagem...',
                hintStyle: AppTheme.greyTextStyle.copyWith(fontSize: 14),
                filled: true,
                fillColor: AppColors.backgroundColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _isSending ? null : _send,
            icon: const Icon(Icons.send_rounded, color: AppColors.purpleColor),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessageEntity message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isExpired = message.status == 'expired';

    return Align(
      alignment: message.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          color: message.isMine ? AppColors.purpleColor : AppColors.backgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.isMine ? 16 : 4),
            bottomRight: Radius.circular(message.isMine ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isExpired ? 'Mensagem expirou sem ser vista' : message.content,
              style: (message.isMine ? AppTheme.whiteTextStyle : AppTheme.blackTextStyle).copyWith(
                fontSize: 14,
                fontStyle: isExpired ? FontStyle.italic : FontStyle.normal,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${message.createdAt.hour.toString().padLeft(2, '0')}:${message.createdAt.minute.toString().padLeft(2, '0')}',
                  style: (message.isMine ? AppTheme.whiteTextStyle : AppTheme.greyTextStyle).copyWith(fontSize: 10),
                ),
                if (message.isMine) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.status == 'delivered'
                        ? Icons.done_all_rounded
                        : (message.status == 'expired' ? Icons.error_outline_rounded : Icons.done_rounded),
                    size: 13,
                    color: AppColors.whiteColor,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
