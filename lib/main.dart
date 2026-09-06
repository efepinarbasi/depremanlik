import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'screens/stitch_home_screen.dart';
import 'services/notification_service.dart';
import 'providers/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().init();
  runApp(const DepremAnlikApp());
}

class DepremAnlikApp extends StatelessWidget {
  const DepremAnlikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeNotifier,
      builder: (context, currentLocale, _) {
        return MaterialApp(
          title: 'SeismoAlert',
          debugShowCheckedModeBanner: false,
          locale: currentLocale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('tr'),
            Locale('en'),
            Locale('ja'),
            Locale('fr'),
            Locale('de'),
            Locale('es'),
            Locale('ru'),
          ],
          theme: ThemeData(
            brightness: Brightness.dark,
            fontFamily: 'Inter',
            primaryColor: const Color(0xFFDAE2FD),
            scaffoldBackgroundColor: const Color(0xFF0B1326),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF0B1326),
              elevation: 0,
              iconTheme: IconThemeData(color: Color(0xFFDAE2FD)),
              titleTextStyle: TextStyle(color: Color(0xFFDAE2FD), fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'Inter'),
            ),
            navigationBarTheme: NavigationBarThemeData(
              backgroundColor: const Color(0xFF060E20),
              indicatorColor: const Color(0xFFDAE2FD).withValues(alpha: 0.25),
              labelTextStyle: WidgetStateProperty.all(const TextStyle(fontSize: 12, fontFamily: 'Inter')),
            ),
            sliderTheme: const SliderThemeData(
              activeTrackColor: Color(0xFFDAE2FD),
              thumbColor: Color(0xFFDAE2FD),
              inactiveTrackColor: Color(0xFF393939),
            ),
            checkboxTheme: CheckboxThemeData(
              fillColor: WidgetStateProperty.resolveWith((states) => 
                states.contains(WidgetState.selected) ? const Color(0xFF2AE500) : const Color(0xFF222A3D)),
              checkColor: WidgetStateProperty.all(Colors.black),
            ),
            switchTheme: SwitchThemeData(
              thumbColor: WidgetStateProperty.resolveWith((states) => 
                states.contains(WidgetState.selected) ? const Color(0xFFDAE2FD) : const Color(0xFF222A3D)),
              trackColor: WidgetStateProperty.resolveWith((states) => 
                states.contains(WidgetState.selected) ? const Color(0xFFDAE2FD).withValues(alpha: 0.4) : const Color(0xFF131B2E)),
            ),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFDAE2FD),
              secondary: Color(0xFFFD8B00),
              tertiary: Color(0xFF2AE500),
              surface: Color(0xFF0B1326),
              surfaceContainerHighest: Color(0xFF222A3D),
              onSurface: Color(0xFFDAE2FD),
              onSurfaceVariant: Color(0xFFC4C7C8),
              error: Color(0xFFFFB4AB),
              outline: Color(0xFFAE8883),
              outlineVariant: Color(0xFF5E3F3C),
            ),
          ),
          home: const StitchHomeScreen(),
        );
      },
    );
  }
}
