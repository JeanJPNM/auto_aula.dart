import 'package:flutter/material.dart';

class InputDialog extends StatefulWidget {
  const InputDialog({
    required this.title,
    this.initialText,
    this.inputLabel,
    this.canCancel = true,
  });
  final Widget title;
  final String? initialText;
  final String? inputLabel;
  final bool canCancel;
  @override
  _InputDialogState createState() => _InputDialogState();
}

class _InputDialogState extends State<InputDialog> {
  late TextEditingController controller;
  @override
  void initState() {
    controller = TextEditingController(text: widget.initialText);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: widget.title,
      actions: [
        if (widget.canCancel)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: const Text('Pronto'),
        ),
      ],
      content: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: widget.inputLabel,
        ),
      ),
    );
  }
}
