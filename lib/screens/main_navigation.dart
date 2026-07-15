import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shuttles_of_the_mill_row/screens/home_screen.dart';
import 'package:shuttles_of_the_mill_row/screens/settings_screen.dart';
import 'package:shuttles_of_the_mill_row/screens/showcase_screen.dart';
import 'package:shuttles_of_the_mill_row/screens/stats_screen.dart';
import 'package:shuttles_of_the_mill_row/utils/const.dart';

class MainNavigation extends ConsumerStatefulWidget {
  final int index;
  const MainNavigation({super.key, this.index = 0});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  late int _currentIndex;
  final List<Widget> _screens = const [
    HomeScreen(),
    ShowcaseScreen(),
    StatsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: _screens),
          Positioned(
            left: 16.w,
            right: 16.w,
            bottom:
                MediaQuery.of(context).padding.bottom + kBottomNavBarMargin.h,
            child: _buildNav(),
          ),
        ],
      ),
    );
  }

  Widget _buildNav() {
    return Container(
      height: kBottomNavBarHeight.h,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusPill),
        border: Border.all(color: kOutline),
        boxShadow: const [kShadowFloat],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navItem(0, Icons.inventory_2_outlined, 'Shed'),
          _navItem(1, Icons.route_rounded, 'Mill Map'),
          _navItem(2, Icons.bar_chart_rounded, 'Logbook'),
          _navItem(3, Icons.compare_arrows_rounded, 'Bench'),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final selected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        height: 48.h,
        padding: EdgeInsets.symmetric(horizontal: selected ? 14.w : 11.w),
        decoration: BoxDecoration(
          color: selected ? kAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(kRadiusPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected
                  ? kBackground
                  : kPrimaryText.withValues(alpha: 0.38),
              size: 20.sp,
            ),
            if (selected) ...[
              SizedBox(width: 7.w),
              Text(
                label.toUpperCase(),
                style: GoogleFonts.ibmPlexMono(
                  color: kBackground,
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
