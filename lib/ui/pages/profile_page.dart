import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:social_media_app/app/configs/colors.dart';
import 'package:social_media_app/app/configs/theme.dart';
import 'package:social_media_app/core/providers/repository_providers.dart';
import 'package:social_media_app/data/gallery_model.dart';
import 'package:social_media_app/domain/entities/friendship_entity.dart';

const _mockProfileUserId = 'toa_heftiba';

final _profileGalleryProvider = FutureProvider<List<GalleryModel>>((ref) async {
  // Mantido temporariamente vazio. Troque por um GalleryRepository real
  // quando o Supabase estiver conectado.
  return const [];
});

final _friendshipStatusProvider =
    FutureProvider.autoDispose<FriendshipStatus>((ref) async {
  final repo = ref.watch(friendsRepositoryProvider);
  return repo.getStatus(_mockProfileUserId);
});

class ProfilePage extends ConsumerWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 24,
            color: AppColors.blackColor,
          ),
        ),
        title: Text(
          'Jenny Wilson',
          style: AppTheme.blackTextStyle.copyWith(
            fontSize: 18,
            fontWeight: AppTheme.bold,
          ),
        ),
        actions: const [
          Icon(
            Icons.more_horiz_rounded,
            size: 24,
            color: AppColors.blackColor,
          ),
          SizedBox(width: 24),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(right: 24, left: 24, top: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildImageProfile(),
                const SizedBox(height: 16),
                Text(
                  "@Toa_Heftiba",
                  style: AppTheme.blackTextStyle.copyWith(
                    fontWeight: AppTheme.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 24),
                _buildDescription(),
                const SizedBox(height: 24),
                _buildFriendshipAction(ref),
                const SizedBox(height: 30),
                _buildTabBar(),
                const SizedBox(height: 24),
                _buildGridList(context, ref),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridList(BuildContext context, WidgetRef ref) {
    final galleryAsync = ref.watch(_profileGalleryProvider);

    return galleryAsync.when(
      data: (galleries) {
        if (galleries.isEmpty) {
          return const SizedBox(
            height: 100,
            child: Center(child: Text('Nenhuma foto ainda.')),
          );
        }
        return SizedBox(
          height: 400,
          width: double.infinity,
          child: GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            childAspectRatio: 0.62,
            physics: const BouncingScrollPhysics(),
            children: galleries
                .map((gallery) => Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            image: DecorationImage(
                              image: NetworkImage(gallery.image),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 10,
                          ),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            gallery.like,
                            style: AppTheme.blackTextStyle.copyWith(
                                fontWeight: AppTheme.bold, fontSize: 10),
                          ),
                        ),
                      ],
                    ))
                .toList(),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Erro: $err')),
    );
  }

  Row _buildTabBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          "Fotos",
          style: AppTheme.blackTextStyle.copyWith(
            fontWeight: AppTheme.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(width: 24),
        Text(
          "Vídeos",
          style: AppTheme.blackTextStyle.copyWith(
            fontWeight: AppTheme.bold,
            fontSize: 18,
            color: AppColors.greyColor,
          ),
        ),
        const SizedBox(width: 24),
        Text(
          "Marcações",
          style: AppTheme.blackTextStyle.copyWith(
            fontWeight: AppTheme.bold,
            fontSize: 18,
            color: AppColors.greyColor,
          ),
        ),
        const Spacer(),
        Image.asset("assets/images/ic_dots_2.png", width: 32),
      ],
    );
  }

  Widget _buildFriendshipAction(WidgetRef ref) {
    final statusAsync = ref.watch(_friendshipStatusProvider);

    return statusAsync.when(
      data: (status) => _FriendshipButton(status: status, ref: ref),
      loading: () => const SizedBox(
        height: 45,
        width: 120,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }

  Row _buildDescription() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "29",
              style: AppTheme.blackTextStyle.copyWith(
                fontWeight: AppTheme.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Seguindo",
              style: AppTheme.blackTextStyle.copyWith(
                fontWeight: AppTheme.regular,
                color: AppColors.greyColor,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "121.9k",
              style: AppTheme.blackTextStyle.copyWith(
                fontWeight: AppTheme.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Amigos",
              style: AppTheme.blackTextStyle.copyWith(
                fontWeight: AppTheme.regular,
                color: AppColors.greyColor,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "7.5M",
              style: AppTheme.blackTextStyle.copyWith(
                fontWeight: AppTheme.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Curtidas",
              style: AppTheme.blackTextStyle.copyWith(
                fontWeight: AppTheme.regular,
                color: AppColors.greyColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Container _buildImageProfile() {
    return Container(
      width: 130,
      height: 130,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.dashedLineColor,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(60),
        child: Image.network(
          "https://images.unsplash.com/photo-1517841905240-472988babdf9?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8ODR8fHNvbGlkJTIwYmFja2dyb3VuZCUyMHBlb3BsZSUyMGltYWdlc3xlbnwwfHwwfHw%3D&auto=format&fit=crop&w=500&q=60",
          width: 120,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _FriendshipButton extends StatelessWidget {
  final FriendshipStatus status;
  final WidgetRef ref;

  const _FriendshipButton({required this.status, required this.ref});

  String get _label {
    switch (status) {
      case FriendshipStatus.none:
        return 'Adicionar amigo';
      case FriendshipStatus.pendingSent:
        return 'Cancelar solicitação';
      case FriendshipStatus.pendingReceived:
        return 'Responder';
      case FriendshipStatus.friends:
        return 'Amigos';
    }
  }

  Color get _color {
    switch (status) {
      case FriendshipStatus.friends:
        return AppColors.greyColor;
      case FriendshipStatus.pendingSent:
        return AppColors.greyColor;
      default:
        return AppColors.greenColor;
    }
  }

  Future<void> _handleTap() async {
    final repo = ref.read(friendsRepositoryProvider);

    switch (status) {
      case FriendshipStatus.none:
        await repo.sendFriendRequest(_mockProfileUserId);
        break;
      case FriendshipStatus.pendingSent:
        await repo.cancelRequest(_mockProfileUserId);
        break;
      case FriendshipStatus.pendingReceived:
      case FriendshipStatus.friends:
        break;
    }
    ref.invalidate(_friendshipStatusProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _handleTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: _color,
            minimumSize: const Size(160, 45),
            elevation: 8,
            shadowColor: AppColors.primaryColor.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            _label,
            style: AppTheme.whiteTextStyle.copyWith(fontWeight: AppTheme.semiBold),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.greyColor.withOpacity(0.17),
            image: const DecorationImage(
              scale: 2.3,
              image: AssetImage("assets/images/ic_inbox.png"),
            ),
          ),
        ),
      ],
    );
  }
}
