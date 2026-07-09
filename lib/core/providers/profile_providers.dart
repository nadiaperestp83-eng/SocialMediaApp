import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:social_media_app/core/providers/supabase_providers.dart';
import 'package:social_media_app/data/repositories/supabase_profile_repository.dart';
import 'package:social_media_app/domain/entities/profile_entity.dart';
import 'package:social_media_app/domain/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return SupabaseProfileRepository(client: ref.watch(supabaseClientProvider));
});

final myProfileProvider =
    StateNotifierProvider<MyProfileNotifier, AsyncValue<ProfileEntity>>((ref) {
  return MyProfileNotifier(ref.watch(profileRepositoryProvider));
});

class MyProfileNotifier extends StateNotifier<AsyncValue<ProfileEntity>> {
  final ProfileRepository _repository;

  MyProfileNotifier(this._repository) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      final profile = await _repository.fetchMyProfile();
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => _load();

  Future<void> updateProfile({
    required String name,
    required String bio,
    required String city,
  }) async {
    final updated = await _repository.updateProfile(name: name, bio: bio, city: city);
    state = AsyncValue.data(updated);
  }

  Future<void> updateAvatar(Uint8List bytes, String fileName) async {
    final url = await _repository.uploadAvatar(bytes: bytes, fileName: fileName);
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncValue.data(current.copyWith(avatarUrl: url));
    }
  }
}
