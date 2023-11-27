import 'package:flutter/material.dart';

import '../theme.dart';


class FormTextField extends StatelessWidget {
  final TextEditingController textController;
  final String text;
  final bool readOnly;
  const FormTextField( {Key? key,required this.text, required this.textController, this.readOnly = false, TextStyle? style,  Icon? suffixIcon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: textController,
      obscureText: false,
      readOnly: readOnly,
      validator: (value) {
        if (value == null || value.isEmpty || value == " ") {   // Validation Logic
          return 'Please enter the $text';
        }
        return null;
      },
      decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 0,horizontal: 10),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: TsOneColor.secondaryContainer,
            ),
          ),
          border: const OutlineInputBorder(
              borderSide: BorderSide(color: TsOneColor.secondaryContainer)
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.green,
            ),
          ),
          labelText: text
      ),
    );
  }
}
