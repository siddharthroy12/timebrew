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
                child: LayoutBuilder(builder: (context, constraints) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const TextField(
                        cursorHeight: 20,
                        style: TextStyle(height: 1.2),
                        decoration: InputDecoration(
                          labelText: 'Task Description',
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      DropdownMenu(
                        width: constraints.maxWidth,
                        enableFilter: true,
                        leadingIcon: const Icon(Icons.checklist_rounded),
                        label: const Text('Task'),
                        dropdownMenuEntries: const [
                          DropdownMenuEntry(value: 'hello', label: 'Hello')
                        ],
                        inputDecorationTheme: const InputDecorationTheme(
                          isDense: true,
                        ),
                      ),
                    ],
                  );
                }),
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
