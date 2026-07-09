abstract class AuthRepository {
  Future<void> signInWithIdentifier({required String identifier, required String password});
  Future<void> signUpWithEmail({required String email, required String password, required String name});
  Future<void> requestPasswordRecovery(String email);
  Future<void> confirmPasswordRecovery({
    required String email,
    required String token,
    required String newPassword,
  });
  Future<void> signOut();
}
