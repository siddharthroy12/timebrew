import 'package:flutter/material.dart';

class ConfirmDeleteDialog extends StatefulWidget {
  const ConfirmDeleteDialog({
    super.key,
    this.onConfirm,
    this.onCancle,
    this.description,
    this.extraDescription,
  });

  final String? description;
  final Function? onConfirm;
  final Function? onCancle;
  final Widget? extraDescription;

  @override
  State<ConfirmDeleteDialog> createState() => _ConfirmDeleteDialogState();
}

class _ConfirmDeleteDialogState extends State<ConfirmDeleteDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 10,
          ),
          Text(
            'Confirm Delete',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            widget.description ?? '',
          ),
          ...widget.extraDescription != null
              ? [
                  const SizedBox(
                    height: 20,
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 300,
                      minHeight: 0,
                    ),
                    child: widget.extraDescription!,
                  )
                ]
              : []
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            if (widget.onCancle != null) {
              widget.onCancle!();
            }
          },
          child: const Text('CLOSE'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            if (widget.onConfirm != null) {
              widget.onConfirm!();
            }
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
