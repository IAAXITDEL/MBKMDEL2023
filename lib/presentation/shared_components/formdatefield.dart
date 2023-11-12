import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme.dart';



class FormDateField extends StatelessWidget {
  final TextEditingController textController;
  final String text;
  final bool readOnly;
  const FormDateField( {Key? key,required this.text, required this.textController, this.readOnly = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: textController,
      obscureText: false,
      readOnly: readOnly,
      validator: (value) {
        if (value == null || value.isEmpty) {   // Validation Logic
          return 'Please enter the $text';
        }
        return null;
      },
      decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 0,horizontal: 10),
          suffixIcon: const Icon(Icons.calendar_month, color: TsOneColor.primary,),
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
      onTap: () async {
       if(!readOnly){
         DateTime? pickedDate = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1945), lastDate: DateTime(2300));
         if(pickedDate != null){
           String formattedDate = DateFormat('dd MMM yyyy').format(pickedDate);
           textController.text = formattedDate;
         }
       }
      },
    );
  }
}
