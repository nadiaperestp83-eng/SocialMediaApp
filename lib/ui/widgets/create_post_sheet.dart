import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:social_media_app/app/configs/colors.dart';
import 'package:social_media_app/app/configs/theme.dart';
import 'package:social_media_app/core/providers/repository_providers.dart';

Future<void> showCreatePostSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const CreatePostSheet(),
  );
}

class CreatePostSheet extends ConsumerStatefulWidget {
  const CreatePostSheet({super.key});

  @override
  ConsumerState<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends ConsumerState<CreatePostSheet> {
  final _captionController = TextEditingController();
  final _picker = ImagePicker();

  XFile? _pickedImage;
  Uint8List? _pickedImageBytes;
  bool _isPublishing = false;
  String? _errorMessage;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  bool get _canPublish =>
      !_isPublishing &&
      (_captionController.text.trim().isNotEmpty || _pickedImage != null);

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _pickedImage = file;
      _pickedImageBytes = bytes;
    });
  }

  void _removeImage() {
    setState(() {
      _pickedImage = null;
      _pickedImageBytes = null;
    });
  }

  Future<void> _publish() async {
    if (!_canPublish) return;
    setState(() {
      _isPublishing = true;
      _errorMessage = null;
    });

    try {
      await ref.read(feedProvider.notifier).createPost(
            caption: _captionController.text.trim(),
            imageBytes: _pickedImageBytes,
            imageFileName: _pickedImage?.name,
          );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _errorMessage = 'Não foi possível publicar. Tente novamente.');
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
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
                    Text(
                      'Nova publicação',
                      style: AppTheme.blackTextStyle.copyWith(fontSize: 17, fontWeight: AppTheme.bold),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _isPublishing ? null : () => Navigator.of(context).pop(),
                      child: Text('Cancelar', style: AppTheme.greyTextStyle.copyWith(fontSize: 14)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _captionController,
                          maxLines: 6,
                          minLines: 3,
                          autofocus: true,
                          onChanged: (_) => setState(() {}),
                          style: AppTheme.blackTextStyle.copyWith(fontSize: 15),
                          decoration: InputDecoration(
                            hintText: 'No que você está pensando?',
                            hintStyle: AppTheme.greyTextStyle.copyWith(fontSize: 15),
                            border: InputBorder.none,
                          ),
                        ),
                        if (_pickedImageBytes != null) ...[
                          const SizedBox(height: 8),
                          Stack(
                            alignment: Alignment.topRight,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.memory(
                                  _pickedImageBytes!,
                                  width: double.infinity,
                                  height: 220,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: GestureDetector(
                                  onTap: _removeImage,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.blackColor.withOpacity(0.55),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close_rounded, color: AppColors.whiteColor, size: 18),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _errorMessage!,
                            style: AppTheme.blackTextStyle.copyWith(color: AppColors.dangerColor, fontSize: 13),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      onPressed: _isPublishing ? null : _pickImage,
                      icon: const Icon(Icons.image_outlined, color: AppColors.purpleColor),
                      tooltip: 'Adicionar imagem',
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _canPublish ? _publish : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.purpleColor,
                        disabledBackgroundColor: AppColors.dashedLineColor,
                        foregroundColor: AppColors.whiteColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: _isPublishing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.whiteColor),
                            )
                          : const Text('Publicar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
