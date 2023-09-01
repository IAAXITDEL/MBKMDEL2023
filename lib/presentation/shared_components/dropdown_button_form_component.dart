import 'package:flutter/material.dart';

class DropdownButtonFormComponent extends StatefulWidget {
  const DropdownButtonFormComponent(
      {super.key,
      this.value,
      required this.label,
      required this.isDisabled,
      required this.onValueChanged});

  final String? value;
  final String label;
  final bool isDisabled;
  final Function(String newValue) onValueChanged;

  @override
  State<DropdownButtonFormComponent> createState() => _DropdownButtonFormComponentState();
}

class _DropdownButtonFormComponentState extends State<DropdownButtonFormComponent> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      value: widget.value,
      onChanged: widget.isDisabled ? null : (value) => widget.onValueChanged(value as String),
      decoration: InputDecoration(
          border: const OutlineInputBorder(),
          hintMaxLines: 1,
          label: Text(
            widget.label,
            style: const TextStyle(
              fontSize: 12,
            ),
          )),
      items: const [
        DropdownMenuItem(
          value: "1",
          child: Text(
            "1",
            style: TextStyle(fontSize: 12),
          ),
        ),
        DropdownMenuItem(
          value: "2",
          child: Text(
            "2",
            style: TextStyle(fontSize: 12),
          ),
        ),
        DropdownMenuItem(
          value: "3",
          child: Text(
            "3",
            style: TextStyle(fontSize: 12),
          ),
        ),
        DropdownMenuItem(
          value: "4",
          child: Text(
            "4",
            style: TextStyle(fontSize: 12),
          ),
        ),
        DropdownMenuItem(
          value: "5",
          child: Text(
            "5",
            style: TextStyle(fontSize: 12),
          ),
        )
      ],
    );
  }
}
