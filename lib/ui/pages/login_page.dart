import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:social_media_app/app/configs/colors.dart';
import 'package:social_media_app/app/configs/theme.dart';
import 'package:social_media_app/app/resources/constant/named_routes.dart';
import 'package:social_media_app/core/providers/auth_providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  Future<void> _handleLogin() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).signInWithIdentifier(
            identifier: _identifierController.text.trim(),
            password: _passwordController.text,
          );
      if (mounted) context.go(NamedRoutes.homeScreen);
    } catch (_) {
      setState(() => _error = 'E-mail/usuário ou senha incorretos.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.purpleColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.groups_rounded, color: AppColors.purpleColor, size: 36),
              ),
              const SizedBox(height: 24),
              Text('Bem-vindo de volta',
                  style: AppTheme.blackTextStyle.copyWith(fontSize: 26, fontWeight: AppTheme.bold)),
              const SizedBox(height: 6),
              Text('Entre para continuar conectado com seus amigos',
                  style: AppTheme.greyTextStyle.copyWith(fontSize: 14)),
              const SizedBox(height: 36),
              _buildField(
                controller: _identifierController,
                label: 'E-mail ou usuário',
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _passwordController,
                label: 'Senha',
                icon: Icons.lock_outline_rounded,
                obscure: _obscure,
                suffix: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.greyColor, size: 20),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push(NamedRoutes.forgotPasswordScreen),
                  child: Text('Esqueceu a senha?',
                      style: AppTheme.blackTextStyle.copyWith(
                          fontSize: 13, color: AppColors.purpleColor, fontWeight: AppTheme.medium)),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 4),
                Text(_error!, style: TextStyle(color: AppColors.dangerColor, fontSize: 13)),
              ],
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purpleColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text('Entrar', style: AppTheme.whiteTextStyle.copyWith(fontWeight: AppTheme.semiBold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Não tem conta? ', style: AppTheme.greyTextStyle.copyWith(fontSize: 14)),
                  GestureDetector(
                    onTap: () => context.push(NamedRoutes.signUpScreen),
                    child: Text('Cadastre-se',
                        style: AppTheme.blackTextStyle.copyWith(
                            fontSize: 14, color: AppColors.purpleColor, fontWeight: AppTheme.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: AppTheme.blackTextStyle.copyWith(fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTheme.greyTextStyle.copyWith(fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.greyColor, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: AppColors.backgroundColor.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
