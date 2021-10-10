import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants.dart' as Constants;


/// The second kind of input text fields used in the app.
/// Separated because of extra functionalities:
/// Obscure text,
/// Eradication of auto-correct,
/// Extra icon to make the input visible.
// ignore: must_be_immutable
class InputTextPassword extends StatefulWidget {

  /// Sets if the text is visible or not.
 bool obscure;
 /// The controller needed to use whatever input is given to the field.
 TextEditingController controller;
 String hintText;

   /// Plain constructor.
  InputTextPassword(String hintText,bool obscure){
    this.obscure=obscure;
    this.hintText=hintText;
  }

   /// Constructor with the widget's own controller.
  InputTextPassword.n(String hintText, bool obscure,TextEditingController controller){
    this.hintText = hintText;
    this.obscure = obscure;
    this.controller=controller;
  }

  @override
  State<InputTextPassword> createState(){
    return _InputTextPasswordState();
  }
}

class _InputTextPasswordState extends State<InputTextPassword>{

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: EdgeInsets.symmetric(
          vertical: Constants.PARENT_PADDING / 4,
          horizontal: Constants.PARENT_PADDING
      ),

      child: TextField(
        enableSuggestions: false,
        autocorrect: false,
        obscureText: widget.obscure,
        controller: widget.controller,

        // Format before the input field is activated.
        decoration: InputDecoration(
          hintText: widget.hintText,
          labelText: widget.hintText,
          hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
          suffix: IconButton(
            /// The icons come with a 48px padding.
            /// So we make sure to eliminate it with constraints.
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            icon: (widget.obscure) // Switch between the two icons.
            ? Icon(Icons.visibility_outlined)
            : Icon(Icons.visibility_off_outlined),

            // Alternate between making the text visible or obscure.
            onPressed: () {
              setState(() {
                widget.obscure = !widget.obscure;
              });
            }
          ),
          
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              borderSide: BorderSide(color: Colors.grey)
          ),

          // Format when the field is chosen.
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              borderSide: BorderSide(color: Constants.ACCENT_COLOR)
          ),
        ),
      ),
    );
  }

}