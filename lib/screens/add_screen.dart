import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shuttles_of_the_mill_row/common/photo_bottom_sheet.dart';
import 'package:shuttles_of_the_mill_row/enum/my_enums.dart';
import 'package:shuttles_of_the_mill_row/providers/image_provider.dart';
import 'package:shuttles_of_the_mill_row/providers/input_provider.dart';
import 'package:shuttles_of_the_mill_row/providers/project_provider.dart';
import 'package:shuttles_of_the_mill_row/utils/const.dart';

class AddScreen extends ConsumerStatefulWidget {
  final bool isEdit;
  final int currentIndex;
  const AddScreen({super.key, this.isEdit = false, this.currentIndex = 0});

  @override
  ConsumerState<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends ConsumerState<AddScreen> {
  late final PageController _pageController;
  int _currentPage = 0;
  bool _hallmarkError = false;
  late final TextEditingController _artisanHallmarkCtrl;
  late final TextEditingController _capacityCtrl;
  late final TextEditingController _proportionsCtrl;
  late final TextEditingController _groundZeroCtrl;
  late final TextEditingController _temperatureCtrl;
  late final TextEditingController _eraCtrl;
  late final TextEditingController _calibratedSiteCtrl;
  late final TextEditingController _notesCtrl;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    final p = ref.read(inputProvider);
    _artisanHallmarkCtrl = TextEditingController(text: p.artisanHallmark);
    _capacityCtrl = TextEditingController(text: p.internalBobbinCapacity);
    _proportionsCtrl = TextEditingController(text: p.physicalProportions);
    _groundZeroCtrl = TextEditingController(text: p.weavingGroundZero);
    _temperatureCtrl = TextEditingController(text: p.temperatureRange);
    _eraCtrl = TextEditingController(text: p.era);
    _calibratedSiteCtrl = TextEditingController(text: p.calibratedSite);
    _notesCtrl = TextEditingController(text: p.notes);
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final controller in [
      _artisanHallmarkCtrl,
      _capacityCtrl,
      _proportionsCtrl,
      _groundZeroCtrl,
      _temperatureCtrl,
      _eraCtrl,
      _calibratedSiteCtrl,
      _notesCtrl,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _goTo(int page) => _pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );

  void _save() async {
    final p = ref.read(inputProvider);
    p.artisanHallmark = _artisanHallmarkCtrl.text.trim();
    p.internalBobbinCapacity = _capacityCtrl.text.trim();
    p.physicalProportions = _proportionsCtrl.text.trim();
    p.weavingGroundZero = _groundZeroCtrl.text.trim();
    p.temperatureRange = _temperatureCtrl.text.trim();
    p.era = _eraCtrl.text.trim();
    p.calibratedSite = _calibratedSiteCtrl.text.trim();
    p.notes = _notesCtrl.text.trim();

    if (_artisanHallmarkCtrl.text.trim().isEmpty) {
      setState(() => _hallmarkError = true);
      _goTo(0);
      HapticFeedback.mediumImpact();
      return;
    }

    setState(() => _hallmarkError = false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _SavingDialog(),
    );
    await Future.delayed(const Duration(milliseconds: 650));
    if (widget.isEdit) {
      ref.read(projectProvider).editEntry(ref, widget.currentIndex);
    } else {
      ref.read(projectProvider).addEntry(ref);
    }
    if (!mounted) return;
    Navigator.pop(context);
    Navigator.pop(context);
    ref.read(inputProvider).clearAll();
    ref.read(imageProvider).clearImage();
  }

  void _clearHallmarkError() {
    if (_hallmarkError) setState(() => _hallmarkError = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _shedHeader(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  children: [
                    _pageIdentity(),
                    _pageSpecs(),
                    _pageProvenance(),
                  ],
                ),
              ),
            ],
          ),
          if (_hallmarkError) _hallmarkErrorBanner(),
          Positioned(
            left: 18.w,
            right: 18.w,
            bottom: MediaQuery.of(context).padding.bottom + 14.h,
            child: _floatingNavPill(),
          ),
        ],
      ),
    );
  }

  Widget _shedHeader() {
    const steps = ['Identity', 'Specs', 'Provenance'];
    final stepTitle = steps[_currentPage];

    return Container(
      decoration: BoxDecoration(
        color: kPanelBg,
        border: Border(
          bottom: BorderSide(color: kOutline.withValues(alpha: 0.85)),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          18.w,
          MediaQuery.of(context).padding.top + 10.h,
          18.w,
          16.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _headerCloseButton(),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: kAmberSurface,
                    borderRadius: BorderRadius.circular(kRadiusPill),
                    border: Border.all(color: kAccent.withValues(alpha: 0.45)),
                  ),
                  child: Text(
                    widget.isEdit ? 'EDIT ENTRY' : 'NEW ENTRY',
                    style: GoogleFonts.ibmPlexMono(
                      color: kAccent,
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 18.h),
            Text(
              widget.isEdit ? 'Revise cabinet record' : 'Log a fly-shuttle',
              style: GoogleFonts.archivo(
                color: kPrimaryText,
                fontSize: 30.sp,
                fontWeight: FontWeight.w700,
                height: 1.0,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Step ${_currentPage + 1} · $stepTitle',
              style: GoogleFonts.ibmPlexSans(
                color: kSecondaryText,
                fontSize: 13.sp,
                fontWeight: FontWeight.w300,
              ),
            ),
            SizedBox(height: 18.h),
            _stepRail(),
          ],
        ),
      ),
    );
  }

  Widget _headerCloseButton() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: kBackground,
          shape: BoxShape.circle,
          border: Border.all(color: kOutline),
        ),
        child: Icon(Icons.close_rounded, color: kPrimaryText, size: 20.sp),
      ),
    );
  }

  Widget _stepRail() {
    const labels = ['Identity', 'Specs', 'Provenance'];
    return LayoutBuilder(
      builder: (context, constraints) {
        final segment = constraints.maxWidth / labels.length;
        return SizedBox(
          height: 54.h,
          child: Stack(
            children: [
              Positioned(
                top: 11.h,
                left: segment * 0.5,
                right: segment * 0.5,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: kOutline,
                    borderRadius: BorderRadius.circular(kRadiusPill),
                  ),
                ),
              ),
              Positioned(
                top: 11.h,
                left: segment * 0.5,
                width: segment * _currentPage,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: kAccent,
                    borderRadius: BorderRadius.circular(kRadiusPill),
                  ),
                ),
              ),
              Row(
                children: List.generate(labels.length, (i) {
                  final active = i == _currentPage;
                  final done = i < _currentPage;
                  return Expanded(
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOut,
                          width: active ? 24.w : 20.w,
                          height: active ? 24.w : 20.w,
                          decoration: BoxDecoration(
                            color: done
                                ? kSecondaryAccent
                                : active
                                    ? kAccent
                                    : kBackground,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: active || done ? Colors.transparent : kOutline,
                              width: 1.5,
                            ),
                            boxShadow: active
                                ? [
                                    BoxShadow(
                                      color: kAccent.withValues(alpha: 0.35),
                                      blurRadius: 12,
                                      spreadRadius: -2,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: done
                                ? Icon(
                                    Icons.check_rounded,
                                    size: 12.sp,
                                    color: kBackground,
                                  )
                                : Text(
                                    '${i + 1}',
                                    style: GoogleFonts.ibmPlexMono(
                                      color: active ? kBackground : kSecondaryText,
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          labels[i].toUpperCase(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.ibmPlexMono(
                            color: active ? kAccent : kSecondaryText,
                            fontSize: 7.sp,
                            fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _hallmarkErrorBanner() {
    return Positioned(
      left: 18.w,
      right: 18.w,
      bottom: MediaQuery.of(context).padding.bottom + 88.h,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: kAmberSurface,
            borderRadius: BorderRadius.circular(kRadiusStandard),
            border: Border.all(color: kAccent.withValues(alpha: 0.55)),
            boxShadow: const [kShadowSubtle],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: kAccent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.verified_outlined, color: kAccent, size: 18.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Maker\'s mark missing',
                      style: GoogleFonts.archivo(
                        color: kPrimaryText,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Every shuttle needs an artisan hallmark before it can be saved to the cabinet.',
                      style: GoogleFonts.ibmPlexSans(
                        color: kSecondaryText,
                        fontSize: 12.sp,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _hallmarkError = false),
                child: Icon(
                  Icons.close_rounded,
                  color: kSecondaryText,
                  size: 18.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _floatingNavPill() {
    final isLast = _currentPage >= 2;
    final primaryLabel = isLast
        ? (widget.isEdit ? 'Update cabinet' : 'Save to cabinet')
        : 'Continue';

    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: kPanelBg.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(kRadiusPill),
        border: Border.all(color: kOutline),
        boxShadow: const [kShadowFloat],
      ),
      child: Row(
        children: [
          if (_currentPage > 0) ...[
            Expanded(
              child: _pillButton(
                label: 'Back',
                icon: Icons.arrow_back_rounded,
                primary: false,
                onTap: () => _goTo(_currentPage - 1),
              ),
            ),
            SizedBox(width: 8.w),
          ],
          Expanded(
            flex: _currentPage > 0 ? 2 : 1,
            child: _pillButton(
              label: primaryLabel,
              icon: isLast ? Icons.inventory_2_outlined : Icons.arrow_forward_rounded,
              primary: true,
              onTap: () {
                if (_currentPage < 2) {
                  _goTo(_currentPage + 1);
                } else {
                  _save();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _pillButton({
    required String label,
    required IconData icon,
    required bool primary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        height: 48.h,
        decoration: BoxDecoration(
          color: primary ? kAccent : kBackground,
          borderRadius: BorderRadius.circular(kRadiusPill),
          border: Border.all(color: primary ? kAccent : kOutline),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!primary) ...[
              Icon(icon, color: kPrimaryText, size: 16.sp),
              SizedBox(width: 6.w),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.ibmPlexMono(
                  color: primary ? kBackground : kPrimaryText,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            if (primary) ...[
              SizedBox(width: 6.w),
              Icon(icon, color: kBackground, size: 16.sp),
            ],
          ],
        ),
      ),
    );
  }

  Widget _pageIdentity() {
    final p = ref.watch(inputProvider);
    return _page('01', 'Identity', [
      _photoSection(),
      SizedBox(height: 24.h),
      _registryPreview(),
      _enumGroup<FiberType>(
        'FIBER TYPE',
        FiberType.values,
        p.fiberType,
        (v) => ref.read(inputProvider).fiberType = v,
        (v) => v.label,
      ),
      _enumGroup<LoomApplicationClass>(
        'LOOM APPLICATION CLASS',
        LoomApplicationClass.values,
        p.loomApplicationClass,
        (v) => ref.read(inputProvider).loomApplicationClass = v,
        (v) => v.label,
      ),
      _field(
        'ARTISAN HALLMARK',
        _artisanHallmarkCtrl,
        'Bedford Loom Shuttle Guild, Atlantic Shuttlewood & Eye',
        (v) {
          _clearHallmarkError();
          ref.read(inputProvider).artisanHallmark = v;
        },
        required: true,
        hasError: _hallmarkError,
        errorText: 'Stamp the maker\'s name or guild mark to continue.',
      ),
    ]);
  }

  Widget _pageSpecs() {
    final p = ref.watch(inputProvider);
    return _page('02', 'Specs', [
      _enumGroup<TimberHardwood>(
        'TIMBER HARDWOOD',
        TimberHardwood.values,
        p.timberHardwood,
        (v) => ref.read(inputProvider).timberHardwood = v,
        (v) => v.label,
      ),
      _enumGroup<ThreadDeliveryEyelet>(
        'THREAD DELIVERY EYELET',
        ThreadDeliveryEyelet.values,
        p.threadDeliveryEyelet,
        (v) => ref.read(inputProvider).threadDeliveryEyelet = v,
        (v) => v.label,
      ),
      _enumGroup<TipMetallurgy>(
        'TIP METALLURGY',
        TipMetallurgy.values,
        p.tipMetallurgy,
        (v) => ref.read(inputProvider).tipMetallurgy = v,
        (v) => v.label,
      ),
      _field(
        'INTERNAL BOBBIN CAPACITY',
        _capacityCtrl,
        '220 m / 2/60s cotton, pirn Ø 22 mm',
        (v) => ref.read(inputProvider).internalBobbinCapacity = v,
      ),
      _field(
        'PHYSICAL PROPORTIONS',
        _proportionsCtrl,
        'L 340 mm · W 38 mm · Tip span 12 mm',
        (v) => ref.read(inputProvider).physicalProportions = v,
      ),
      _enumGroup<TrackFrictionWear>(
        'TRACK FRICTION WEAR',
        TrackFrictionWear.values,
        p.trackFrictionWear,
        (v) => ref.read(inputProvider).trackFrictionWear = v,
        (v) => v.label,
      ),
    ]);
  }

  Widget _pageProvenance() {
    return _page('03', 'Provenance', [
      _field(
        'WEAVING GROUND ZERO',
        _groundZeroCtrl,
        'Lancashire Cotton, Yorkshire Wool, Lowell Massachusetts',
        (v) => ref.read(inputProvider).weavingGroundZero = v,
      ),
      _field(
        'TEMPERATURE RANGE',
        _temperatureCtrl,
        '18-24 C shed floor humidity band',
        (v) => ref.read(inputProvider).temperatureRange = v,
      ),
      _field(
        'ERA',
        _eraCtrl,
        '1880-1920',
        (v) => ref.read(inputProvider).era = v,
        inputFormatters: const [_EraInputFormatter()],
      ),
      _field(
        'CALIBRATED SITE',
        _calibratedSiteCtrl,
        'Mill row loom bay, picking-box calibration bench',
        (v) => ref.read(inputProvider).calibratedSite = v,
      ),
      _field(
        'NOTES',
        _notesCtrl,
        'Tip ferrule seating, pirn bore, maker stamp, shed history...',
        (v) => ref.read(inputProvider).notes = v,
        maxLines: 5,
      ),
    ]);
  }

  Widget _page(String num, String title, List<Widget> children) {
    final bottomPad = MediaQuery.of(context).padding.bottom + 96.h;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, bottomPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                num,
                style: GoogleFonts.ibmPlexMono(
                  color: kAccent,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 12.w),
              Container(width: 24.w, height: 1, color: kOutline),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.archivo(
                    color: kPrimaryText,
                    fontSize: 27.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 22.h),
          ...children,
        ],
      ),
    );
  }

  Widget _photoSection() {
    final imagePath = ref
        .watch(imageProvider)
        .getImagePath(ref.watch(imageProvider).resultImage);
    return GestureDetector(
      onTap: () => photoBottomSheet(context, ref.read(imageProvider), 0, ref),
      child: Container(
        width: double.infinity,
        height: 166.h,
        decoration: BoxDecoration(
          color: kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusSubtle),
          border: Border.all(color: kOutline),
        ),
        clipBehavior: Clip.antiAlias,
        child: imagePath != null && File(imagePath).existsSync()
            ? Image.file(File(imagePath), fit: BoxFit.cover)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_camera_outlined,
                    color: kAccent.withValues(alpha: 0.45),
                    size: 32.sp,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'TAP TO PHOTOGRAPH SHUTTLE',
                    style: GoogleFonts.ibmPlexMono(
                      color: kSecondaryText,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _registryPreview() {
    final p = ref.watch(inputProvider);
    final fiber = p.fiberType.label.substring(0, 3).toUpperCase();
    final classToken = p.loomApplicationClass.label.split(' ').last;
    final suffix = classToken.isNotEmpty
        ? classToken.substring(0, 1).toUpperCase()
        : 'X';
    final ledger = widget.isEdit && p.shuttleRegistryMark.isNotEmpty
        ? p.shuttleRegistryMark
        : 'SMR-LOOM-####-$fiber-$suffix';
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: kSelectedTint,
        borderRadius: BorderRadius.circular(kRadiusSubtle),
        border: Border.all(color: kOutline),
      ),
      child: Row(
        children: [
          Icon(Icons.qr_code_2_rounded, color: kAccent, size: 22.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SYSTEM GENERATED REGISTRY',
                  style: GoogleFonts.ibmPlexMono(
                    color: kSecondaryText,
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  ledger,
                  style: GoogleFonts.ibmPlexMono(
                    color: kPrimaryText,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl,
    String hint,
    ValueChanged<String> onChanged, {
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
    bool required = false,
    bool hasError = false,
    String? errorText,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 22.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (required)
            Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: kAmberSurface,
                      borderRadius: BorderRadius.circular(kRadiusPill),
                      border: Border.all(
                        color: hasError
                            ? kError.withValues(alpha: 0.6)
                            : kAccent.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      'REQUIRED',
                      style: GoogleFonts.ibmPlexMono(
                        color: hasError ? kError : kAccent,
                        fontSize: 7.5.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          TextField(
            controller: ctrl,
            onChanged: onChanged,
            maxLines: maxLines,
            inputFormatters: inputFormatters,
            style: GoogleFonts.ibmPlexSans(color: kPrimaryText, fontSize: 14.sp),
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(kRadiusSubtle),
                borderSide: BorderSide(
                  color: hasError ? kError : kOutline,
                  width: hasError ? 1.5 : 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(kRadiusSubtle),
                borderSide: BorderSide(
                  color: hasError ? kError : kAccent,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(kRadiusSubtle),
                borderSide: const BorderSide(color: kError, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(kRadiusSubtle),
                borderSide: const BorderSide(color: kError, width: 1.5),
              ),
            ),
          ),
          if (hasError && errorText != null) ...[
            SizedBox(height: 8.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: kError, size: 14.sp),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    errorText,
                    style: GoogleFonts.ibmPlexSans(
                      color: kError,
                      fontSize: 12.sp,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _enumGroup<T>(
    String label,
    List<T> values,
    T current,
    ValueChanged<T> onSelected,
    String Function(T) labelBuilder,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.ibmPlexMono(
              color: kSecondaryText,
              fontSize: 9.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 7.w,
            runSpacing: 7.h,
            children: values.map((value) {
              final selected = value == current;
              return GestureDetector(
                onTap: () => onSelected(value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? kAccent : kPanelBg,
                    borderRadius: BorderRadius.circular(kRadiusSubtle),
                    border: Border.all(color: selected ? kAccent : kOutline),
                  ),
                  child: Text(
                    labelBuilder(value),
                    style: GoogleFonts.ibmPlexSans(
                      color: selected ? kBackground : kPrimaryText,
                      fontSize: 12.sp,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

}

class _EraInputFormatter extends TextInputFormatter {
  const _EraInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final buffer = StringBuffer();
    var digitCount = 0;
    var hyphenCount = 0;

    for (final char in newValue.text.split('')) {
      if (char == '-' && hyphenCount < 1 && digitCount > 0) {
        buffer.write('-');
        hyphenCount++;
      } else if (RegExp(r'[0-9]').hasMatch(char)) {
        if (hyphenCount == 0 && digitCount < 4) {
          buffer.write(char);
          digitCount++;
        } else if (hyphenCount == 1) {
          final afterHyphen = buffer.toString().split('-').last.length;
          if (afterHyphen < 4) {
            buffer.write(char);
          }
        }
      }
    }

    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class _SavingDialog extends StatelessWidget {
  const _SavingDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: kPanelBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadiusStandard),
      ),
      child: Padding(
        padding: EdgeInsets.all(34.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 42.w,
              height: 42.w,
              child: const CircularProgressIndicator(
                color: kAccent,
                strokeWidth: 2,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'LOGGING SHUTTLE',
              style: GoogleFonts.ibmPlexMono(
                color: kPrimaryText,
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Recording the fly-shuttle to the mill-row shed archive.',
              textAlign: TextAlign.center,
              style: GoogleFonts.ibmPlexSans(
                color: kSecondaryText,
                fontSize: 13.sp,
                fontWeight: FontWeight.w300,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
