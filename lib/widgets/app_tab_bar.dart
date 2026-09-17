import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

class AppTabBar extends StatelessWidget implements PreferredSizeWidget {
  final List<String> tabs;

  const AppTabBar({super.key, required this.tabs});

  @override
  Size get preferredSize => const Size.fromHeight(kTextTabBarHeight);

  @override
  Widget build(BuildContext context) {
    final labelStyle = GoogleFonts.plusJakartaSans(
      fontSize: 13,
      fontWeight: FontWeight.w600,
    );

    return TabBar(
      isScrollable: false,
      indicatorSize: TabBarIndicatorSize.tab,
      labelColor: AppColors.brandDeep,
      unselectedLabelColor: AppColors.neutralDark,
      indicatorColor: AppColors.brandDeep,
      labelStyle: labelStyle,
      unselectedLabelStyle: labelStyle,
      tabs: [
        for (final tab in tabs)
          Tab(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(tab),
            ),
          ),
      ],
    );
  }
}
