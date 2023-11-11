import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/gestures.dart';
import 'package:timebrew/widgets/restart.dart';
import 'tabs/tabs.dart';

// Fictitious brand color.
const _brandBlue = Color(0xFF1E88E5);

ThemeData mixWithCommonTheme(ColorScheme colorSheme) {
  return ThemeData(
    colorScheme: colorSheme,
    useMaterial3: true,
    visualDensity: VisualDensity.compact,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    cardTheme: CardTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
    ),
    timePickerTheme: const TimePickerThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(5),
        ),
      ),
    ),
    datePickerTheme: const DatePickerThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(5),
        ),
      ),
    ),
    dialogTheme: const DialogTheme(
      actionsPadding: EdgeInsets.only(
        bottom: 10,
        right: 10,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(5),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 18,
        horizontal: 15,
      ),
      border: const OutlineInputBorder(
        borderSide: BorderSide(width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          width: 2,
          color: colorSheme.primary,
        ),
      ),
    ),
  );
}

void main() {
  runApp(const MyApp());
}

class ThisShouldBeDefaultScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus
      };
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme lightColorScheme;
        ColorScheme darkColorScheme;

        if (lightDynamic != null && darkDynamic != null) {
          // On Android S+ devices, use the provided dynamic color scheme.
          // (Recommended) Harmonize the dynamic color scheme' built-in semantic colors.
          lightColorScheme = lightDynamic.harmonized();

          // Repeat for the dark color scheme.
          darkColorScheme = darkDynamic.harmonized();
        } else {
          // Otherwise, use fallback schemes.
          lightColorScheme = ColorScheme.fromSeed(
            seedColor: _brandBlue,
          );
          darkColorScheme = ColorScheme.fromSeed(
            seedColor: _brandBlue,
            brightness: Brightness.dark,
          );
        }

        return RestartWidget(
          child: MaterialApp(
            title: 'Timebrew',
            debugShowCheckedModeBanner: false,
            scrollBehavior: ThisShouldBeDefaultScrollBehavior(),
            themeMode: ThemeMode.dark,
            theme: mixWithCommonTheme(lightColorScheme),
            darkTheme: mixWithCommonTheme(darkColorScheme),
            home: const Tabs(),
          ),
        );
      },
    );
  }
}
