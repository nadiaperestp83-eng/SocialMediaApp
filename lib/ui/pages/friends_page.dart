import 'package:flutter/material.dart';

import 'package:social_media_app/app/configs/theme.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        // bottom: 100 -> espaço pra navbar flutuante não cobrir o conteúdo
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amigos',
              style: AppTheme.blackTextStyle.copyWith(
                fontSize: 22,
                fontWeight: AppTheme.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Expanded(
              child: Center(
                child: Text('Nenhuma solicitação ou amigo ainda.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
