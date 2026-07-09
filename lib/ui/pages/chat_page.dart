import 'package:flutter/material.dart';

import 'package:social_media_app/app/configs/theme.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Conversas',
              style: AppTheme.blackTextStyle.copyWith(
                fontSize: 22,
                fontWeight: AppTheme.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Expanded(
              child: Center(
                child: Text('Nenhuma conversa ainda.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
