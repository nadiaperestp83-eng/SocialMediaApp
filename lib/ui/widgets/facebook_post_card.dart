import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:social_media_app/app/configs/colors.dart';
import 'package:social_media_app/app/configs/theme.dart';
import 'package:social_media_app/core/providers/repository_providers.dart';
import 'package:social_media_app/domain/entities/post_entity.dart';

class FacebookPostCard extends ConsumerStatefulWidget {
  final PostEntity post;
  final ValueChanged<bool> onToggleLike;

  const FacebookPostCard({
    super.key,
    required this.post,
    required this.onToggleLike,
  });

  @override
  ConsumerState<FacebookPostCard> createState() => _FacebookPostCardState();
}

class _FacebookPostCardState extends ConsumerState<FacebookPostCard> {
  bool _commentsOpen = false;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.backgroundColor,
                  backgroundImage: post.authorAvatarUrl.isNotEmpty
                      ? NetworkImage(post.authorAvatarUrl)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    post.authorName,
                    style: AppTheme.blackTextStyle.copyWith(
                      fontWeight: AppTheme.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                Icon(Icons.more_horiz_rounded, color: AppColors.greyColor),
              ],
            ),
          ),
          if (post.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(post.caption, style: AppTheme.blackTextStyle.copyWith(fontSize: 14)),
            ),
          if (post.hashtags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Text(
                post.hashtags.join(' '),
                style: AppTheme.blackTextStyle.copyWith(
                  fontSize: 13,
                  color: AppColors.greenColor,
                  fontWeight: AppTheme.medium,
                ),
              ),
            ),
          if (post.imageUrl != null) ...[
            const SizedBox(height: 12),
            CachedNetworkImage(
              imageUrl: post.imageUrl!,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(height: 220, color: AppColors.backgroundColor),
              errorWidget: (_, __, ___) => Container(height: 220, color: AppColors.backgroundColor),
            ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                Text('${post.likesCount} curtidas', style: AppTheme.greyTextStyle.copyWith(fontSize: 12)),
                const Spacer(),
                Text('${post.commentsCount} comentários', style: AppTheme.greyTextStyle.copyWith(fontSize: 12)),
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                _ActionButton(
                  icon: post.likedByMe ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
                  label: 'Curtir',
                  color: post.likedByMe ? AppColors.purpleColor : AppColors.blackColor,
                  onTap: () => widget.onToggleLike(!post.likedByMe),
                ),
                _ActionButton(
                  icon: Icons.mode_comment_outlined,
                  label: 'Comentar',
                  color: AppColors.blackColor,
                  onTap: () => setState(() => _commentsOpen = !_commentsOpen),
                ),
                _ActionButton(
                  icon: Icons.share_outlined,
                  label: 'Compartilhar',
                  color: AppColors.blackColor,
                  onTap: () {},
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _commentsOpen ? _buildCommentsSection(post.id) : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection(String postId) {
    final commentsAsync = ref.watch(commentsProvider(postId));

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          commentsAsync.when(
            data: (comments) {
              if (comments.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text('Seja o primeiro a comentar.',
                      style: AppTheme.greyTextStyle.copyWith(fontSize: 13)),
                );
              }
              return Column(
                children: comments.map((c) => _CommentBubble(comment: c)).toList(),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (err, _) => Text('Erro ao carregar comentários', style: AppTheme.greyTextStyle),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Escreva um comentário...',
                    hintStyle: AppTheme.greyTextStyle.copyWith(fontSize: 13),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    filled: true,
                    fillColor: AppColors.backgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send_rounded, color: AppColors.purpleColor),
                onPressed: () async {
                  final text = _commentController.text.trim();
                  if (text.isEmpty) return;
                  await ref
                      .read(postsRepositoryProvider)
                      .addComment(postId: postId, content: text);
                  _commentController.clear();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CommentBubble extends StatelessWidget {
  final dynamic comment;

  const _CommentBubble({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(radius: 14, backgroundColor: AppColors.backgroundColor),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(comment.authorName,
                      style: AppTheme.blackTextStyle.copyWith(fontSize: 12, fontWeight: AppTheme.bold)),
                  const SizedBox(height: 2),
                  Text(comment.content, style: AppTheme.blackTextStyle.copyWith(fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(label,
                  style: AppTheme.blackTextStyle.copyWith(
                      fontSize: 13, fontWeight: AppTheme.medium, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
