import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:social_media_app/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _client;

  AuthRepositoryImpl({required SupabaseClient client}) : _client = client;

  bool _looksLikeEmail(String value) => value.contains('@');

  @override
  Future<void> signInWithIdentifier({
    required String identifier,
    required String password,
  }) async {
    String email = identifier;

    if (!_looksLikeEmail(identifier)) {
      final resolved = await _client.rpc(
        'get_email_by_username',
        params: {'p_username': identifier.trim().toLowerCase()},
      ) as String?;
      if (resolved == null) throw AuthException('Usuário não encontrado.');
      email = resolved;
    }

    await _client.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    // O nome vai nos metadados do próprio usuário; um trigger no banco
    // (handle_new_user) cria a linha em profiles automaticamente e de
    // forma atômica junto com o cadastro — sem chamada extra no cliente.
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );

    if (response.user == null) throw AuthException('Falha ao criar conta.');
  }

  @override
  Future<void> requestPasswordRecovery(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  @override
  Future<void> confirmPasswordRecovery({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    await _client.auth.verifyOTP(
      type: OtpType.recovery,
      email: email,
      token: token,
    );
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  @override
  Future<void> signOut() => _client.auth.signOut();
}
