import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timebrew/providers/tag_provider.dart';
import 'package:timebrew/tabs/tags.dart';
import 'tabs/timer.dart';
import 'fab.dart';

class TabEntry {
  String title;
  IconData icon;
  TabEntry({required this.title, required this.icon});
}

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
                color: const ColorScheme.dark().primary,
                width: 2,
              ),
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

  List<TabEntry> tabs = [
    TabEntry(title: 'Timer', icon: Icons.hourglass_bottom_rounded),
    TabEntry(title: 'Logs', icon: Icons.history_rounded),
    TabEntry(title: 'Tasks', icon: Icons.checklist_rounded),
    TabEntry(title: 'Tags', icon: Icons.tag_rounded),
    TabEntry(title: 'Stats', icon: Icons.analytics_rounded),
  ];

  TabBar buildTabBar(BuildContext context) {
    List<Tab> tabWidgets = [];
    bool minimal = MediaQuery.of(context).size.width < 550;

    for (TabEntry tab in tabs) {
      tabWidgets.add(
        Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(tab.icon),
              ...(minimal
                  ? []
                  : [
                      const SizedBox(
                        width: 10,
                      ),
                      Text(tab.title)
                    ]),
            ],
          ),
        ),
      );
    }

    return TabBar(
      controller: _tcontroller,
      splashBorderRadius: BorderRadius.circular(50),
      indicator: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(50)),
      indicatorSize: TabBarIndicatorSize.tab,
      tabs: tabWidgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
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
          bottom: PreferredSize(
            preferredSize: buildTabBar(context).preferredSize,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
              child: buildTabBar(context),
            ),
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
