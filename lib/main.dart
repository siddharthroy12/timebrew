import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:timebrew/notifiers/timer_notifier.dart';
import './tabs/tabs.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => TimerNotifier()),
          ],
          child: MaterialApp(
            title: 'Timebrew',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: darkDynamic,
              useMaterial3: true,
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
