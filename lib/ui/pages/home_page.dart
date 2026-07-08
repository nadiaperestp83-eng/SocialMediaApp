import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:social_media_app/core/providers/repository_providers.dart';
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

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                const SizedBox(height: 12),
                _buildCustomAppBar(context),
                const SizedBox(height: 18),
                feedState.when(
                  data: (posts) => Column(
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
                  loading: () => const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, stack) => Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Center(child: Text('Erro ao carregar feed: $err')),
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
          Builder(
            builder: (innerContext) => IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () => Scaffold.of(innerContext).openDrawer(),
            ),
          ),
          const Spacer(),
          Image.asset("assets/images/ic_notification.png", width: 24, height: 24),
          const SizedBox(width: 12),
          Image.asset("assets/images/ic_search.png", width: 24, height: 24),
        ],
      ),
    );
  }
}
