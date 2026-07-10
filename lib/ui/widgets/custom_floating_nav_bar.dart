import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:social_media_app/app/configs/colors.dart';
import 'package:social_media_app/app/configs/theme.dart';

class _NavBarItemData {
  final IconData icon;
  final String label;

  const _NavBarItemData({required this.icon, required this.label});
}

class CustomFloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomFloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    _NavBarItemData(icon: Icons.home_rounded, label: 'Feed'),
    _NavBarItemData(icon: Icons.people_alt_rounded, label: 'Amigos'),
    _NavBarItemData(icon: Icons.chat_bubble_rounded, label: 'Chat'),
    _NavBarItemData(icon: Icons.person_rounded, label: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 66,
          decoration: BoxDecoration(
            color: AppColors.whiteColor.withOpacity(0.72),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: AppColors.whiteColor.withOpacity(0.5), width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.blackColor.withOpacity(0.14),
                blurRadius: 24,
                spreadRadius: 2,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_items.length, (index) {
              return _NavBarButton(
                item: _items[index],
                selected: index == currentIndex,
                onTap: () => onTap(index),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavBarButton extends StatelessWidget {
  final _NavBarItemData item;
  final bool selected;
  final VoidCallback onTap;

  const _NavBarButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.purpleColor : AppColors.greyColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.purpleColor.withOpacity(0.14) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, size: 22, color: color),
            const SizedBox(height: 3),
            Text(
              item.label,
              style: AppTheme.blackTextStyle.copyWith(
                fontSize: 11,
                fontWeight: AppTheme.semiBold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
