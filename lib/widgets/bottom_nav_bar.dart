// lib/widgets/bottom_nav_bar.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: SafeArea(
        top: false,
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.blueDark, AppColors.blueDeep],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.blueDark.withOpacity(0.35),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
                isActive: selectedIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.quiz_outlined,
                activeIcon: Icons.quiz_rounded,
                label: 'Kuis',
                isActive: selectedIndex == 1,
                onTap: () => onTap(1),
              ),
              // Check-in FAB
              Expanded(
                child: GestureDetector(
                  onTap: () => onTap(2),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold.withOpacity(0.5),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add_location_alt_rounded,
                          color: AppColors.blueDark,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Check-in',
                        style: AppText.body(8, color: AppColors.white)
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Profil',
                isActive: selectedIndex == 3,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon, activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.white.withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isActive ? activeIcon : icon,
                  color: isActive
                      ? AppColors.white
                      : AppColors.white.withOpacity(0.45),
                  size: 22,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppText.body(9).copyWith(
                  color: isActive
                      ? AppColors.white
                      : AppColors.white.withOpacity(0.4),
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      );
}