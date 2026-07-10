import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:social_media_app/app/configs/colors.dart';
import 'package:social_media_app/app/configs/theme.dart';
import 'package:social_media_app/core/providers/profile_providers.dart';
import 'package:social_media_app/core/providers/repository_providers.dart';
import 'package:social_media_app/domain/entities/friend_entity.dart';
import 'package:social_media_app/domain/entities/profile_entity.dart';
import 'package:social_media_app/ui/widgets/facebook_post_card.dart';
import 'package:social_media_app/ui/widgets/profile_editor_sheet.dart';

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

    final profileAsync = ref.watch(myProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 24, color: AppColors.blackColor),
        ),
        title: Text(
          profileAsync.valueOrNull?.name.isNotEmpty == true ? profileAsync.valueOrNull!.name : 'Perfil',
          style: AppTheme.blackTextStyle.copyWith(fontSize: 18, fontWeight: AppTheme.bold),
        ),
        actions: const [
          Icon(Icons.more_horiz_rounded, size: 24, color: AppColors.blackColor),
          SizedBox(width: 24),
        ],
      ),
      body: SafeArea(
        child: profileAsync.when(
          data: (profile) => _ProfileContent(profile: profile),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded, color: AppColors.greyColor, size: 40),
                  const SizedBox(height: 12),
                  Text('Não foi possível carregar o perfil', style: AppTheme.blackTextStyle),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'ERRO REAL (diagnóstico): $err',
                      style: AppTheme.blackTextStyle.copyWith(fontSize: 12, color: AppColors.dangerColor),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => ref.read(myProfileProvider.notifier).refresh(),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileContent extends ConsumerStatefulWidget {
  final ProfileEntity profile;

  const _ProfileContent({required this.profile});

  @override
  ConsumerState<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends ConsumerState<_ProfileContent> {
  int _selectedTab = 0; // 0 = Posts, 1 = Fotos

  ProfileEntity get profile => widget.profile;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        // bottom: 110 -> espaço pra navbar flutuante não cobrir o conteúdo
        padding: const EdgeInsets.fromLTRB(24, 30, 24, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildImageProfile(),
            const SizedBox(height: 16),
            Text(
              '@${profile.username}',
              style: AppTheme.blackTextStyle.copyWith(fontWeight: AppTheme.bold, fontSize: 22),
            ),
            if (profile.bio.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                profile.bio,
                textAlign: TextAlign.center,
                style: AppTheme.blackTextStyle.copyWith(fontSize: 14, color: AppColors.greyColor),
              ),
            ],
            if (profile.age != null || profile.city.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildAgeCityRow(),
            ],
            const SizedBox(height: 24),
            _buildStatsRow(),
            const SizedBox(height: 24),
            _buildEditProfileAction(context),
            const SizedBox(height: 30),
            _buildTabBar(),
            const SizedBox(height: 20),
            if (_selectedTab == 0) _buildPostsTab() else _buildPhotosTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildAgeCityRow() {
    final chips = <Widget>[];
    if (profile.age != null) {
      chips.add(_InfoChip(icon: Icons.cake_outlined, label: '${profile.age} anos'));
    }
    if (profile.city.isNotEmpty) {
      chips.add(_InfoChip(icon: Icons.location_on_outlined, label: profile.city));
    }
    return Wrap(spacing: 12, runSpacing: 8, alignment: WrapAlignment.center, children: chips);
  }

  Widget _buildStatsRow() {
    final statsAsync = ref.watch(profileStatsProvider);

    return statsAsync.when(
      data: (stats) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(value: '${stats.postsCount}', label: 'Publicações'),
          _StatItem(value: '${stats.friendsCount}', label: 'Amigos'),
          _StatItem(value: '${stats.likesTotal}', label: 'Curtidas'),
        ],
      ),
      loading: () => const SizedBox(height: 40, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
      error: (err, st) => const SizedBox.shrink(),
    );
  }

  Widget _buildEditProfileAction(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => showProfileEditorSheet(context, profile),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.greenColor,
            minimumSize: const Size(160, 45),
            elevation: 8,
            shadowColor: AppColors.primaryColor.withOpacity(0.3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text('Editar perfil', style: AppTheme.whiteTextStyle.copyWith(fontWeight: AppTheme.semiBold)),
        ),
        const SizedBox(width: 12),
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.greyColor.withOpacity(0.17),
            image: const DecorationImage(scale: 2.3, image: AssetImage("assets/images/ic_inbox.png")),
          ),
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
        border: Border.all(color: AppColors.dashedLineColor, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(60),
        child: profile.avatarUrl.isNotEmpty
            ? Image.network(profile.avatarUrl, width: 120, height: 120, fit: BoxFit.cover)
            : Container(
                color: AppColors.backgroundColor,
                child: const Icon(Icons.person, size: 48, color: AppColors.greyColor),
              ),
      ),
    );
  }

  Widget _buildTabBar() {
    Widget tab(String label, int index) {
      final selected = _selectedTab == index;
      return Expanded(
        child: InkWell(
          onTap: () => setState(() => _selectedTab = index),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  label,
                  style: AppTheme.blackTextStyle.copyWith(
                    fontWeight: AppTheme.bold,
                    fontSize: 15,
                    color: selected ? AppColors.purpleColor : AppColors.greyColor,
                  ),
                ),
              ),
              Container(height: 2, color: selected ? AppColors.purpleColor : Colors.transparent),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.dashedLineColor)),
      ),
      child: Row(children: [tab('Posts', 0), tab('Fotos', 1)]),
    );
  }

  Widget _buildPostsTab() {
    return Column(
      children: [
        _buildFriendsSection(),
        const SizedBox(height: 24),
        _buildPhotosSection(preview: true),
        const SizedBox(height: 24),
        _buildOwnPostsList(),
      ],
    );
  }

  Widget _buildPhotosTab() {
    return _buildPhotosSection(preview: false);
  }

  Widget _buildFriendsSection() {
    final friendsAsync = ref.watch(friendsListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Amigos', style: AppTheme.blackTextStyle.copyWith(fontWeight: AppTheme.bold, fontSize: 17)),
            const Spacer(),
            TextButton(
              onPressed: () {},
              child: Text('Ver tudo', style: AppTheme.blackTextStyle.copyWith(color: AppColors.purpleColor, fontSize: 13)),
            ),
          ],
        ),
        friendsAsync.when(
          data: (friends) {
            if (friends.isEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: Text('Nenhum amigo ainda.', style: AppTheme.greyTextStyle.copyWith(fontSize: 13)),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${friends.length} amigos', style: AppTheme.greyTextStyle.copyWith(fontSize: 13)),
                const SizedBox(height: 10),
                SizedBox(
                  height: 82,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: friends.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) => _FriendAvatar(friend: friends[index]),
                  ),
                ),
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (err, st) => Text('Erro ao carregar amigos', style: AppTheme.greyTextStyle.copyWith(fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildPhotosSection({required bool preview}) {
    final photosAsync = ref.watch(myPhotosProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (preview)
          Row(
            children: [
              Text('Fotos', style: AppTheme.blackTextStyle.copyWith(fontWeight: AppTheme.bold, fontSize: 17)),
              const Spacer(),
              TextButton(
                onPressed: () => setState(() => _selectedTab = 1),
                child: Text('Ver tudo', style: AppTheme.blackTextStyle.copyWith(color: AppColors.purpleColor, fontSize: 13)),
              ),
            ],
          ),
        photosAsync.when(
          data: (photos) {
            if (photos.isEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: Text('Nenhuma foto ainda.', style: AppTheme.greyTextStyle.copyWith(fontSize: 13)),
              );
            }
            final shown = preview ? photos.take(8).toList() : photos;
            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: shown.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) => ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(shown[index], width: 100, height: 100, fit: BoxFit.cover),
                  ),
                ),
              ),
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (err, st) => Text('Erro ao carregar fotos', style: AppTheme.greyTextStyle.copyWith(fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildOwnPostsList() {
    final postsAsync = ref.watch(myPostsProvider);

    return postsAsync.when(
      data: (posts) {
        if (posts.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text('Você ainda não publicou nada.', style: AppTheme.greyTextStyle.copyWith(fontSize: 13)),
          );
        }
        return Column(
          children: posts
              .map((post) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: FacebookPostCard(
                      post: post,
                      onToggleLike: (liked) => ref.read(feedProvider.notifier).toggleLike(post.id, liked),
                    ),
                  ))
              .toList(),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, st) => Text('Erro ao carregar publicações', style: AppTheme.greyTextStyle.copyWith(fontSize: 12)),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(value, style: AppTheme.blackTextStyle.copyWith(fontWeight: AppTheme.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Text(label, style: AppTheme.blackTextStyle.copyWith(fontWeight: AppTheme.regular, color: AppColors.greyColor)),
      ],
    );
  }
}

class _FriendAvatar extends StatelessWidget {
  final FriendEntity friend;

  const _FriendAvatar({required this.friend});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.backgroundColor,
            backgroundImage: friend.avatarUrl.isNotEmpty ? NetworkImage(friend.avatarUrl) : null,
            child: friend.avatarUrl.isEmpty ? const Icon(Icons.person, color: AppColors.greyColor) : null,
          ),
          const SizedBox(height: 4),
          Text(
            friend.name.isNotEmpty ? friend.name : friend.username,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.blackTextStyle.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: AppColors.backgroundColor, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.greyColor),
          const SizedBox(width: 6),
          Text(label, style: AppTheme.blackTextStyle.copyWith(fontSize: 13)),
        ],
      ),
    );
  }
}
