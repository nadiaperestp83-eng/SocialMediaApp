import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:social_media_app/app/configs/colors.dart';
import 'package:social_media_app/app/configs/theme.dart';
import 'package:social_media_app/core/providers/profile_providers.dart';
import 'package:social_media_app/domain/entities/profile_entity.dart';

Future<void> showProfileEditorSheet(BuildContext context, ProfileEntity profile) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ProfileEditorSheet(profile: profile),
  );
}

class ProfileEditorSheet extends ConsumerStatefulWidget {
  final ProfileEntity profile;

  const ProfileEditorSheet({super.key, required this.profile});

  @override
  ConsumerState<ProfileEditorSheet> createState() => _ProfileEditorSheetState();
}

class _ProfileEditorSheetState extends ConsumerState<ProfileEditorSheet> {
  late final TextEditingController _nameController =
      TextEditingController(text: widget.profile.name);
  late final TextEditingController _bioController =
      TextEditingController(text: widget.profile.bio);
  late final TextEditingController _cityController =
      TextEditingController(text: widget.profile.city);

  final _picker = ImagePicker();
  Uint8List? _newAvatarBytes;
  String? _newAvatarFileName;

  bool _isSaving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _newAvatarBytes = bytes;
      _newAvatarFileName = file.name;
    });
  }

  Future<void> _save() async {
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      if (_newAvatarBytes != null) {
        await ref
            .read(myProfileProvider.notifier)
            .updateAvatar(_newAvatarBytes!, _newAvatarFileName ?? 'avatar.jpg');
      }
      await ref.read(myProfileProvider.notifier).updateProfile(
            name: _nameController.text.trim(),
            bio: _bioController.text.trim(),
            city: _cityController.text.trim(),
          );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _errorMessage = 'Não foi possível salvar. Tente novamente.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        decoration: const BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.dashedLineColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text('Editar perfil',
                        style: AppTheme.blackTextStyle.copyWith(fontSize: 17, fontWeight: AppTheme.bold)),
                    const Spacer(),
                    TextButton(
                      onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                      child: Text('Cancelar', style: AppTheme.greyTextStyle.copyWith(fontSize: 14)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: GestureDetector(
                            onTap: _pickAvatar,
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: 48,
                                  backgroundColor: AppColors.backgroundColor,
                                  backgroundImage: _newAvatarBytes != null
                                      ? MemoryImage(_newAvatarBytes!) as ImageProvider
                                      : (widget.profile.avatarUrl.isNotEmpty
                                          ? NetworkImage(widget.profile.avatarUrl) as ImageProvider
                                          : null),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: AppColors.purpleColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.camera_alt_rounded, color: AppColors.whiteColor, size: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text('Username', style: AppTheme.greyTextStyle.copyWith(fontSize: 12)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text('@${widget.profile.username}',
                                    style: AppTheme.greyTextStyle.copyWith(fontSize: 14)),
                              ),
                              const Icon(Icons.lock_outline_rounded, size: 16, color: AppColors.greyColor),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildField(label: 'Nome', controller: _nameController),
                        const SizedBox(height: 16),
                        _buildField(label: 'Bio', controller: _bioController, maxLines: 3),
                        const SizedBox(height: 16),
                        _buildField(label: 'Cidade', controller: _cityController),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Text(_errorMessage!,
                              style: AppTheme.blackTextStyle.copyWith(color: AppColors.dangerColor, fontSize: 13)),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purpleColor,
                    foregroundColor: AppColors.whiteColor,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.whiteColor),
                        )
                      : const Text('Salvar alterações'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({required String label, required TextEditingController controller, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.greyTextStyle.copyWith(fontSize: 12)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: AppTheme.blackTextStyle.copyWith(fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.backgroundColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
