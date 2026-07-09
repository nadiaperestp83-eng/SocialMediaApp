import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:social_media_app/app/configs/colors.dart';
import 'package:social_media_app/app/configs/theme.dart';
import 'package:social_media_app/core/providers/repository_providers.dart';
import 'package:social_media_app/ui/widgets/create_post_sheet.dart';
import 'package:social_media_app/ui/widgets/custom_app_bar.dart';
import 'package:social_media_app/ui/widgets/facebook_post_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    final feedState = ref.watch(feedProvider);

    // Sem Scaffold aqui de propósito: o único Scaffold da árvore é o do
    // MainScaffold (ShellRoute), que já contém o Drawer.
    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.purpleColor,
        onRefresh: () => ref.read(feedProvider.notifier).refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                const SizedBox(height: 12),
                _buildCustomAppBar(context),
                const SizedBox(height: 18),
                _buildComposerTrigger(context),
                const SizedBox(height: 18),
                feedState.when(
                  data: (posts) => posts.isEmpty
                      ? _EmptyFeedState(onCreatePost: () => showCreatePostSheet(context))
                      : Column(
                          children: posts
                              .map(
                                (post) => FacebookPostCard(
                                  post: post,
                                  onToggleLike: (liked) => ref
                                      .read(feedProvider.notifier)
                                      .toggleLike(post.id, liked),
                                ),
                              )
                              .toList(),
                        ),
                  loading: () => const _FeedSkeleton(),
                  error: (err, stack) => _FeedErrorState(
                    onRetry: () => ref.read(feedProvider.notifier).refresh(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  CustomAppBar _buildCustomAppBar(BuildContext context) {
    return CustomAppBar(
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
          const Spacer(),
          Image.asset("assets/images/ic_notification.png", width: 24, height: 24),
          const SizedBox(width: 12),
          Image.asset("assets/images/ic_search.png", width: 24, height: 24),
        ],
      ),
    );
  }

  Widget _buildComposerTrigger(BuildContext context) {
    return InkWell(
      onTap: () => showCreatePostSheet(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        child: Row(
          children: [
            const CircleAvatar(radius: 18, backgroundColor: AppColors.backgroundColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No que você está pensando?',
                style: AppTheme.greyTextStyle.copyWith(fontSize: 14),
              ),
            ),
            const Icon(Icons.image_outlined, color: AppColors.purpleColor),
          ],
        ),
      ),
    );
  }
}

class _EmptyFeedState extends StatelessWidget {
  final VoidCallback onCreatePost;

  const _EmptyFeedState({required this.onCreatePost});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              color: AppColors.primaryLightColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.forum_rounded, color: AppColors.purpleColor, size: 40),
          ),
          const SizedBox(height: 20),
          Text(
            'Nenhuma publicação por aqui ainda',
            textAlign: TextAlign.center,
            style: AppTheme.blackTextStyle.copyWith(fontSize: 16, fontWeight: AppTheme.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Seja o primeiro a compartilhar algo com seus amigos.',
            textAlign: TextAlign.center,
            style: AppTheme.greyTextStyle.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onCreatePost,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purpleColor,
              foregroundColor: AppColors.whiteColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            ),
            child: const Text('Criar primeira publicação'),
          ),
        ],
      ),
    );
  }
}

class _FeedErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _FeedErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        children: [
          const Icon(Icons.wifi_off_rounded, color: AppColors.greyColor, size: 40),
          const SizedBox(height: 16),
          Text(
            'Não foi possível carregar o feed',
            style: AppTheme.blackTextStyle.copyWith(fontSize: 15, fontWeight: AppTheme.semiBold),
          ),
          const SizedBox(height: 6),
          Text(
            'Verifique sua conexão e tente novamente.',
            style: AppTheme.greyTextStyle.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.purpleColor,
              side: const BorderSide(color: AppColors.purpleColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}

class _FeedSkeleton extends StatefulWidget {
  const _FeedSkeleton();

  @override
  State<_FeedSkeleton> createState() => _FeedSkeletonState();
}

class _FeedSkeletonState extends State<_FeedSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final opacity = 0.4 + (_controller.value * 0.3);
        return Column(children: List.generate(3, (_) => _skeletonCard(opacity)));
      },
    );
  }

  Widget _skeletonCard(double opacity) {
    Widget bar({double width = double.infinity, double height = 12}) {
      return Container(
        width: width,
        height: height,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor.withOpacity(opacity),
          borderRadius: BorderRadius.circular(8),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor.withOpacity(opacity),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: bar(height: 14)),
            ],
          ),
          const SizedBox(height: 16),
          bar(),
          bar(width: 200),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: AppColors.backgroundColor.withOpacity(opacity),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ],
      ),
    );
  }
}
