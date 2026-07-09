import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:social_media_app/app/configs/colors.dart';
import 'package:social_media_app/app/configs/theme.dart';
import 'package:social_media_app/core/providers/profile_providers.dart';
import 'package:social_media_app/domain/entities/profile_entity.dart';
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

class _ProfileContent extends StatelessWidget {
  final ProfileEntity profile;

  const _ProfileContent({required this.profile});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildImageProfile(),
            const SizedBox(height: 16),
            Text(
              profile.name.isNotEmpty ? profile.name : 'Sem nome',
              style: AppTheme.blackTextStyle.copyWith(fontWeight: AppTheme.bold, fontSize: 20),
            ),
            const SizedBox(height: 4),
            Text('@${profile.username}', style: AppTheme.greyTextStyle.copyWith(fontSize: 14)),
            const SizedBox(height: 16),
            _buildInfoRow(),
            if (profile.bio.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                profile.bio,
                textAlign: TextAlign.center,
                style: AppTheme.blackTextStyle.copyWith(fontSize: 14),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => showProfileEditorSheet(context, profile),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purpleColor,
                foregroundColor: AppColors.whiteColor,
                minimumSize: const Size(200, 46),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: const Text('Editar perfil'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow() {
    final chips = <Widget>[];

    if (profile.age != null) {
      chips.add(_InfoChip(icon: Icons.cake_outlined, label: '${profile.age} anos'));
    }
    if (profile.city.isNotEmpty) {
      chips.add(_InfoChip(icon: Icons.location_on_outlined, label: profile.city));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Wrap(spacing: 12, runSpacing: 8, alignment: WrapAlignment.center, children: chips);
  }

  Widget _buildImageProfile() {
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
