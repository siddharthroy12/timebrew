import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timebrew/providers/tag_provider.dart';
import 'package:timebrew/tabs/tags.dart';
import 'tabs/timer.dart';
import 'fab.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => TagProvider())],
      child: MaterialApp(
        title: 'Timebrew',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: const ColorScheme.dark(),
          useMaterial3: true,
          dialogTheme: const DialogTheme(
            actionsPadding: EdgeInsets.only(bottom: 10, right: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(5),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            isDense: true,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 15),
            border: const OutlineInputBorder(
              borderSide: BorderSide(width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: const ColorScheme.dark().primary, width: 2),
            ),
          ),
        ),
        home: const Tabs(),
      ),
    );
  }
}

class Tabs extends StatefulWidget {
  const Tabs({
    super.key,
  });

  @override
  State<Tabs> createState() => _TabsState();
}

class _TabsState extends State<Tabs> with SingleTickerProviderStateMixin {
  late TabController _tcontroller;
  final List<String> titleList = ["Timer", "Logs", "Tasks", "Tags", "Stats"];
  String currentTitle = "";

  @override
  void initState() {
    currentTitle = titleList[0];
    _tcontroller = TabController(length: 5, vsync: this);
    _tcontroller.addListener(changeTitle); // Registering listener
    super.initState();
  }

  // This function is called, every time active tab is changed
  void changeTitle() {
    setState(() {
      // get index of active tab & change current appbar title
      currentTitle = titleList[_tcontroller.index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(currentTitle),
          actions: [
            PopupMenuButton(
              itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                const PopupMenuItem(
                  value: 'Hello',
                  child: Text('Settings'),
                ),
                const PopupMenuItem(
                  value: 'Hello',
                  child: Text('Send feedback'),
                ),
                const PopupMenuItem(
                  value: 'Hello',
                  child: Text('Help'),
                ),
              ],
            )
          ],
          bottom: TabBar(
            controller: _tcontroller,
            tabs: const [
              Tab(icon: Icon(Icons.hourglass_bottom_rounded)),
              Tab(icon: Icon(Icons.history_rounded)),
              Tab(icon: Icon(Icons.checklist_rounded)),
              Tab(icon: Icon(Icons.tag_rounded)),
              Tab(icon: Icon(Icons.analytics_rounded)),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tcontroller,
          children: const [
            Center(child: Timer()),
            Tab(icon: Icon(Icons.history_rounded)),
            Tab(icon: Icon(Icons.checklist_rounded)),
            Tags(),
            Tab(icon: Icon(Icons.analytics_rounded)),
          ],
        ),
        floatingActionButton: const Fab(),
      ),
    );
  }
}
