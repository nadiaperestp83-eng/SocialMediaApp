import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:social_media_app/app/configs/colors.dart';
import 'package:social_media_app/app/configs/theme.dart';
import 'package:social_media_app/domain/entities/post_entity.dart';

class FacebookPostCard extends StatelessWidget {
  final PostEntity post;
  final ValueChanged<bool> onToggleLike;

  const FacebookPostCard({
    super.key,
    required this.post,
    required this.onToggleLike,
  });

  @override
  Widget build(BuildContext context) {
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    post.authorAvatarUrl,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                  ),
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
              child: Text(
                post.caption,
                style: AppTheme.blackTextStyle.copyWith(fontSize: 14),
              ),
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
            ClipRRect(
              borderRadius: BorderRadius.zero,
              child: CachedNetworkImage(
                imageUrl: post.imageUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  height: 220,
                  color: AppColors.backgroundColor,
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 220,
                  color: AppColors.backgroundColor,
                  child: const Icon(Icons.image_not_supported_outlined),
                ),
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                Text(
                  '${post.likesCount} curtidas',
                  style: AppTheme.greyTextStyle.copyWith(fontSize: 12),
                ),
                const Spacer(),
                Text(
                  '${post.commentsCount} comentários',
                  style: AppTheme.greyTextStyle.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                _ActionButton(
                  icon: post.likedByMe
                      ? Icons.thumb_up_rounded
                      : Icons.thumb_up_outlined,
                  label: 'Curtir',
                  color: post.likedByMe ? AppColors.purpleColor : AppColors.blackColor,
                  onTap: () => onToggleLike(!post.likedByMe),
                ),
                _ActionButton(
                  icon: Icons.mode_comment_outlined,
                  label: 'Comentar',
                  color: AppColors.blackColor,
                  onTap: () {},
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

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

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
              Text(
                label,
                style: AppTheme.blackTextStyle.copyWith(
                  fontSize: 13,
                  fontWeight: AppTheme.medium,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
