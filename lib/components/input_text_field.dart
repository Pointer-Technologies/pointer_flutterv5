import 'package:flutter/material.dart';

import '../constants.dart' as Constants;


/// A custom input text field.
/// Saved as a separate class because of frequent use,
/// in order to avoid cluttering in the code.
// ignore: must_be_immutable
class InputTextField extends StatelessWidget{

  /// The controller needed to use whatever input is given to the field.
  TextEditingController controller;
  String _hintText;

  /// Plain constructor.
  InputTextField(this._hintText);

  /// Constructor with the widget's own controller.
  InputTextField.n(this._hintText,this.controller);


  @override
  Widget build(BuildContext context) {

    return Container(
      padding: EdgeInsets.symmetric(
          vertical: Constants.PARENT_PADDING / 4,
          horizontal: Constants.PARENT_PADDING
      ),

      child: TextField(
        controller: controller,

        // Format before the field is activated.
        decoration: InputDecoration(
          hintText: _hintText,
          hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            borderSide: BorderSide(color: Colors.grey)
          ),

          labelText: _hintText,

          // Format when the field is chosen.
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            borderSide: BorderSide(color: Constants.ACCENT_COLOR)),
        ),
      ),
    );
  }

}
