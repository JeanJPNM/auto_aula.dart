import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DurationPicker extends StatefulWidget {
  const DurationPicker({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _DurationPickerState createState() => _DurationPickerState();
}

class _DurationPickerState extends State<DurationPicker> {
  TextEditingController controller = TextEditingController();
  int get _textValue {
    return int.tryParse(controller.text) ?? 0;
  }

  int _dropdownValue = 1;
  Duration get _duration => Duration(milliseconds: _textValue * _dropdownValue);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _duration),
          child: const Text('Pronto'),
        )
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<int>(
            value: _dropdownValue,
            items: const [
              DropdownMenuItem(
                value: 1,
                child: Text('Milisegundos'),
              ),
              DropdownMenuItem(
                value: Duration.millisecondsPerSecond,
                child: Text('Segundos'),
              ),
              DropdownMenuItem(
                value: Duration.millisecondsPerMinute,
                child: Text('Minutos'),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _dropdownValue = value;
              });
            },
          ),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          )
        ],
      ),
    );
  }
}
