import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:social_media_app/domain/entities/profile_entity.dart';
import 'package:social_media_app/domain/repositories/profile_repository.dart';

class SupabaseProfileRepository implements ProfileRepository {
  final SupabaseClient _client;

  SupabaseProfileRepository({required SupabaseClient client}) : _client = client;

  static const _avatarsBucket = 'avatars';

  String get _currentUserId => _client.auth.currentUser?.id ?? '';

  @override
  Future<ProfileEntity> fetchMyProfile() async {
    final row = await _client
        .from('profiles')
        .select('id, username, name, bio, city, avatar_url, birth_date')
        .eq('id', _currentUserId)
        .single();

    return ProfileEntity.fromJson(row);
  }

  @override
  Future<ProfileEntity> updateProfile({
    required String name,
    required String bio,
    required String city,
  }) async {
    final row = await _client
        .from('profiles')
        .update({'name': name, 'bio': bio, 'city': city})
        .eq('id', _currentUserId)
        .select('id, username, name, bio, city, avatar_url, birth_date')
        .single();

    return ProfileEntity.fromJson(row);
  }

  @override
  Future<String> uploadAvatar({required Uint8List bytes, required String fileName}) async {
    final path = '$_currentUserId/${DateTime.now().microsecondsSinceEpoch}_$fileName';

    await _client.storage.from(_avatarsBucket).uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
        );

    final publicUrl = _client.storage.from(_avatarsBucket).getPublicUrl(path);

    await _client.from('profiles').update({'avatar_url': publicUrl}).eq('id', _currentUserId);

    return publicUrl;
  }
}
