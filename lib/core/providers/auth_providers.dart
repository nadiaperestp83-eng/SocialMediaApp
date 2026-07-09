import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:social_media_app/core/providers/supabase_providers.dart';
import 'package:social_media_app/data/repositories/auth_repository_impl.dart';
import 'package:social_media_app/domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(client: ref.watch(supabaseClientProvider));
});
