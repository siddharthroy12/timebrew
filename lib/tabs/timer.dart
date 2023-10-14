import 'package:flutter/material.dart';

class Timer extends StatefulWidget {
  const Timer({super.key});

  @override
  State<Timer> createState() => _TimerState();
}

class _TimerState extends State<Timer> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '00:00:00',
                style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
              ),
              IconButton.filled(
                onPressed: () {},
                icon: const Icon(Icons.play_arrow),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                constraints: const BoxConstraints(maxWidth: 500),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      cursorHeight: 20,
                      style: TextStyle(height: 1.2),
                      decoration: InputDecoration(
                        labelText: 'Task Description',
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    DropdownMenu(
                      expandedInsets:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 0),
                      enableFilter: true,
                      leadingIcon: Icon(Icons.checklist_rounded),
                      label: Text('Task'),
                      dropdownMenuEntries: [
                        DropdownMenuEntry(value: 'hello', label: 'Hello')
                      ],
                      inputDecorationTheme: InputDecorationTheme(
                        isDense: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 70,
              )
            ],
          ),
        ),
      ],
    );
  }
}
