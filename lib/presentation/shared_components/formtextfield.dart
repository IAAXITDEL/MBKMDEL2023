import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme.dart';


class FormTextField extends StatelessWidget {
  final TextEditingController textController;
  final String text;
  final bool readOnly;
  final IconData? icon;
  const FormTextField( {Key? key,required this.text, required this.textController, this.readOnly = false,  this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: textController,
      obscureText: false,
      readOnly: readOnly,
      validator: (value) {
        if (value == null || value.isEmpty) {   // Validation Logic
          return 'Please enter the ${text}';
        }
        return null;
      },
      decoration: InputDecoration(
          suffixIcon: Icon(icon, color: TsOneColor.primary,),
          contentPadding: EdgeInsets.symmetric(vertical: 0,horizontal: 10),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: TsOneColor.secondaryContainer,
            ),
          ),
          border: OutlineInputBorder(
              borderSide: BorderSide(color: TsOneColor.secondaryContainer)
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.green,
            ),
          ),
          labelText: text
      ),
    );
  }
}
