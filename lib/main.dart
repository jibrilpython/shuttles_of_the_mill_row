import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shuttles_of_the_mill_row/initial_screen.dart';
import 'package:shuttles_of_the_mill_row/providers/user_provider.dart';
import 'package:shuttles_of_the_mill_row/screens/add_screen.dart';
import 'package:shuttles_of_the_mill_row/screens/info_screen.dart';
import 'package:shuttles_of_the_mill_row/screens/main_navigation.dart';
import 'package:shuttles_of_the_mill_row/screens/showcase_screen.dart';
import 'package:shuttles_of_the_mill_row/utils/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(ProviderScope(child: MyApp(preferences: preferences)));
}

class MyApp extends ConsumerWidget {
  final SharedPreferences preferences;
  const MyApp({super.key, required this.preferences});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProv = ref.watch(userProvider);
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Shuttles of the Mill Row',
            theme: buildAppTheme(),
            home: child,
            routes: {
              '/home': (_) => const MainNavigation(),
              '/initial_screen': (_) => const InitialScreen(),
              '/showcase': (_) => const ShowcaseScreen(),
              '/add_screen': (context) {
                final args =
                    ModalRoute.of(context)?.settings.arguments
                        as Map<String, dynamic>? ??
                    {};
                return AddScreen(
                  isEdit: args['isEdit'] as bool? ?? false,
                  currentIndex: args['index'] as int? ?? 0,
                );
              },
              '/info_screen': (_) => const InfoScreen(),
            },
          ),
        );
      },
      child: userProv.firstTimeUser
          ? const InitialScreen()
          : const MainNavigation(),
    );
  }
}
