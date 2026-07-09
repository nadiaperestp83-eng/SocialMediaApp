import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:social_media_app/app/configs/colors.dart';
import 'package:social_media_app/app/configs/theme.dart';
import 'package:social_media_app/app/resources/constant/named_routes.dart';
import 'package:social_media_app/core/providers/auth_providers.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _handleSend() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).requestPasswordRecovery(_emailController.text.trim());
      if (mounted) {
        context.push('${NamedRoutes.resetPasswordScreen}?email=${_emailController.text.trim()}');
      }
    } catch (_) {
      setState(() => _error = 'Não foi possível enviar o código. Verifique o e-mail.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(backgroundColor: AppColors.whiteColor, elevation: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Icon(Icons.mark_email_read_outlined, color: AppColors.purpleColor, size: 48),
              const SizedBox(height: 20),
              Text('Esqueceu a senha?', style: AppTheme.blackTextStyle.copyWith(fontSize: 24, fontWeight: AppTheme.bold)),
              const SizedBox(height: 8),
              Text('Enviaremos um código de 6 dígitos para o seu e-mail',
                  style: AppTheme.greyTextStyle.copyWith(fontSize: 14)),
              const SizedBox(height: 28),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'E-mail cadastrado',
                  prefixIcon: const Icon(Icons.email_outlined, color: AppColors.greyColor, size: 20),
                  filled: true,
                  fillColor: AppColors.backgroundColor.withOpacity(0.5),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: AppColors.dangerColor, fontSize: 13)),
              ],
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _handleSend,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purpleColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text('Enviar código', style: AppTheme.whiteTextStyle.copyWith(fontWeight: AppTheme.semiBold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
