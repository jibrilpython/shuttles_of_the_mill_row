import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shuttles_of_the_mill_row/enum/my_enums.dart';
import 'package:shuttles_of_the_mill_row/models/project_model.dart';
import 'package:shuttles_of_the_mill_row/providers/image_provider.dart';
import 'package:shuttles_of_the_mill_row/providers/input_provider.dart';
import 'package:shuttles_of_the_mill_row/providers/project_provider.dart';
import 'package:shuttles_of_the_mill_row/providers/search_provider.dart';
import 'package:shuttles_of_the_mill_row/utils/const.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  FiberType? _selectedFiber;
  bool _isBtnPressed = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() => setState(() {}));
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final project = ref.watch(projectProvider);
    final search = ref.watch(searchProvider);
    final allEntries = project.entries;
    final entries = search
        .filteredList(allEntries)
        .where(
          (e) => _selectedFiber == null || e.fiberType == _selectedFiber,
        )
        .toList();
    final addButtonBottom = homeAddButtonBottom(context);
    final listBottomPad = addButtonBottom + 56.h;

    return Scaffold(
      backgroundColor: kBackground,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              _header(allEntries.length),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    children: [
                      _searchBar(),
                      SizedBox(height: 14.h),
                      _fiberChips(),
                      SizedBox(height: 22.h),
                    ],
                  ),
                ),
              ),
              if (project.isLoading)
                const SliverToBoxAdapter(
                  child: LinearProgressIndicator(
                    color: kAccent,
                    backgroundColor: kOutline,
                    minHeight: 2,
                  ),
                )
              else if (entries.isEmpty)
                SliverFillRemaining(hasScrollBody: false, child: _emptyState())
              else
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  sliver: SliverList.builder(
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return _ShuttleCard(
                        entry: entry,
                        index: allEntries.indexOf(entry),
                      );
                    },
                  ),
                ),
              SliverToBoxAdapter(child: SizedBox(height: listBottomPad)),
            ],
          ),
          Positioned(
            right: 20.w,
            bottom: addButtonBottom,
            child: _addButton(),
          ),
        ],
      ),
    );
  }

  Widget _header(int count) {
    final countLabel = count == 0 ? 'Empty shed' : '$count in the shed';

    return SliverPadding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 14.h,
        bottom: 18.h,
      ),
      sliver: SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MILL ROW ARCHIVES',
                          style: GoogleFonts.ibmPlexMono(
                            color: kAccent,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.8,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          'Shuttles of\nthe Mill Row',
                          style: GoogleFonts.archivo(
                            color: kPrimaryText,
                            fontSize: 34.sp,
                            fontWeight: FontWeight.w700,
                            height: 0.98,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: kAmberSurface,
                      borderRadius: BorderRadius.circular(kRadiusPill),
                      border: Border.all(
                        color: kAccent.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          count.toString().padLeft(2, '0'),
                          style: GoogleFonts.archivo(
                            color: kAccent,
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'FLIERS',
                          style: GoogleFonts.ibmPlexMono(
                            color: kSecondaryText,
                            fontSize: 7.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            kAccent.withValues(alpha: 0.7),
                            kOutline.withValues(alpha: 0.2),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    countLabel.toUpperCase(),
                    style: GoogleFonts.ibmPlexMono(
                      color: kSecondaryText,
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Text(
                'Catalogued fly-shuttles from the picking boxes and raceboards.',
                style: GoogleFonts.ibmPlexSans(
                  color: kSecondaryText,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w300,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchBar() {
    final hasQuery = _searchController.text.isNotEmpty;
    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      onChanged: ref.read(searchProvider).setSearchQuery,
      style: GoogleFonts.ibmPlexSans(
        color: kPrimaryText,
        fontSize: 14.sp,
      ),
      decoration: InputDecoration(
        hintText: 'Search registry, hallmark, mill, era...',
        hintStyle: GoogleFonts.ibmPlexSans(
          color: kSecondaryText.withValues(alpha: 0.5),
          fontSize: 14.sp,
        ),
        filled: true,
        fillColor: kPanelBg,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: kSecondaryText,
          size: 20.sp,
        ),
        suffixIcon: hasQuery
            ? IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: kSecondaryText,
                  size: 20.sp,
                ),
                onPressed: () {
                  _searchController.clear();
                  ref.read(searchProvider).clearSearchQuery();
                  setState(() {});
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusStandard),
          borderSide: const BorderSide(color: kOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusStandard),
          borderSide: const BorderSide(color: kOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusStandard),
          borderSide: const BorderSide(color: kAccent, width: 1.5),
        ),
      ),
    );
  }

  Widget _fiberChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _chip(null, 'All'),
          ...FiberType.values.map((f) => _chip(f, f.label)),
        ],
      ),
    );
  }

  Widget _chip(FiberType? fiber, String label) {
    final selected = _selectedFiber == fiber;
    final color = fiber == null ? kPrimaryText : getFiberColor(fiber);
    return GestureDetector(
      onTap: () => setState(() => _selectedFiber = fiber),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusPill),
          border: Border.all(
            color: selected ? color : kOutline,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.ibmPlexMono(
            color: selected ? color : kSecondaryText,
            fontSize: 9.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }

  Widget _addButton() {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isBtnPressed = true),
      onTapUp: (_) {
        setState(() => _isBtnPressed = false);
        ref.read(inputProvider).clearAll();
        ref.read(imageProvider).clearImage();
        Navigator.pushNamed(context, '/add_screen');
      },
      onTapCancel: () => setState(() => _isBtnPressed = false),
      child: AnimatedScale(
        scale: _isBtnPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: kAccent,
            borderRadius: BorderRadius.circular(kRadiusPill),
            border: Border.all(color: kAccent),
            boxShadow: const [kShadowFloat],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  color: kBackground.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: kBackground,
                  size: 16.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                'LOG SHUTTLE',
                style: GoogleFonts.ibmPlexMono(
                  color: kBackground,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Text(
        'NO SHUTTLES IN THIS SHED.',
        style: GoogleFonts.ibmPlexMono(
          color: kSecondaryText,
          fontSize: 11.sp,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _ShuttleCard extends ConsumerWidget {
  final WeavingShuttleModel entry;
  final int index;
  const _ShuttleCard({required this.entry, required this.index});

  Color get _leftBorderColor {
    if (isOperationalWear(entry.trackFrictionWear)) return kAccent;
    if (entry.trackFrictionWear == TrackFrictionWear.displayCased) {
      return kSecondaryAccent;
    }
    return getFiberColor(entry.fiberType);
  }

  Color get _silhouetteColor =>
      isOperationalWear(entry.trackFrictionWear) ? kAccent : kSecondaryAccent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagePath = ref.watch(imageProvider).getImagePath(entry.photoPath);
    final conditionColor = getConditionColor(entry.trackFrictionWear);
    final title = entry.artisanHallmark.trim().isNotEmpty
        ? entry.artisanHallmark
        : entry.loomApplicationClass.label;
    final millTag = entry.weavingGroundZero.trim();

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/info_screen',
        arguments: {'index': index},
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusSubtle),
          boxShadow: const [kShadowSubtle],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(kRadiusSubtle),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: kSelectedTint.withValues(alpha: 0.35),
                  border: Border.all(color: kOutline),
                  borderRadius: BorderRadius.circular(kRadiusSubtle),
                ),
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(kRadiusSubtle),
                        child: SizedBox(
                          width: 82.w,
                          height: 92.h,
                          child: imagePath != null && File(imagePath).existsSync()
                              ? Image.file(File(imagePath), fit: BoxFit.cover)
                              : Container(
                                  color: kBackground,
                                  child: Center(
                                    child: CustomPaint(
                                      size: Size(54.w, 22.h),
                                      painter: _ShuttleSilhouettePainter(
                                        color: _silhouetteColor,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    title.toUpperCase(),
                                    style: GoogleFonts.archivo(
                                      color: kPrimaryText,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700,
                                      height: 1.1,
                                      letterSpacing: 0.4,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                CustomPaint(
                                  size: Size(36.w, 14.h),
                                  painter: _ShuttleSilhouettePainter(
                                    color: _silhouetteColor,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              entry.shuttleRegistryMark,
                              style: GoogleFonts.ibmPlexMono(
                                color: kSecondaryText,
                                fontSize: 8.5.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 8.h),
                            Wrap(
                              spacing: 6.w,
                              runSpacing: 5.h,
                              children: [
                                _threadBadge(fiberThreadSpec(entry.fiberType)),
                                if (millTag.isNotEmpty) _millTag(millTag),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Container(
                                  width: 7.w,
                                  height: 7.w,
                                  decoration: BoxDecoration(
                                    color: conditionColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Expanded(
                                  child: Text(
                                    entry.trackFrictionWear.label,
                                    style: GoogleFonts.ibmPlexSans(
                                      color: kSecondaryText,
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                child: Container(width: 3, color: _leftBorderColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _threadBadge(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: kAccent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(kRadiusPill),
        border: Border.all(color: kOutline),
      ),
      child: Text(
        text,
        style: GoogleFonts.ibmPlexMono(
          color: kAccent,
          fontSize: 7.5.sp,
          fontWeight: FontWeight.w700,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _millTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: kAccent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(kRadiusPill),
      ),
      child: Text(
        text,
        style: GoogleFonts.ibmPlexSans(
          color: kAccent,
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _ShuttleSilhouettePainter extends CustomPainter {
  final Color color;
  _ShuttleSilhouettePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final midY = size.height / 2;
    final tipInset = size.width * 0.04;

    path.moveTo(tipInset, midY);
    path.quadraticBezierTo(
      size.width * 0.18,
      0,
      size.width * 0.5,
      size.height * 0.08,
    );
    path.quadraticBezierTo(
      size.width * 0.82,
      0,
      size.width - tipInset,
      midY,
    );
    path.quadraticBezierTo(
      size.width * 0.82,
      size.height,
      size.width * 0.5,
      size.height * 0.92,
    );
    path.quadraticBezierTo(
      size.width * 0.18,
      size.height,
      tipInset,
      midY,
    );
    path.close();
    canvas.drawPath(path, paint);

    final pirnPaint = Paint()
      ..color = kBackground.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, midY),
        width: size.width * 0.28,
        height: size.height * 0.42,
      ),
      pirnPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ShuttleSilhouettePainter oldDelegate) =>
      oldDelegate.color != color;
}

