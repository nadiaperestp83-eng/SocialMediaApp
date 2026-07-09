import 'dart:typed_data';

import 'package:social_media_app/domain/entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity> fetchMyProfile();

  Future<ProfileEntity> updateProfile({
    required String name,
    required String bio,
    required String city,
  });

  Future<String> uploadAvatar({
    required Uint8List bytes,
    required String fileName,
  });
}
