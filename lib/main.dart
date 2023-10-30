import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/gestures.dart';
import 'package:timebrew/widgets/restart.dart';
import 'tabs/tabs.dart';

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
        return RestartWidget(
          child: MaterialApp(
            title: 'Timebrew',
            debugShowCheckedModeBanner: false,
            scrollBehavior: ThisShouldBeDefaultScrollBehavior(),
            theme: ThemeData(
              colorScheme: darkDynamic,
              useMaterial3: true,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                    color: darkDynamic?.primary ??
                        const ColorScheme.dark().primary,
                    width: 2,
                  ),
                ),
              ),
            ),
            home: const Tabs(),
          ),
        );
      },
    );
  }
}
