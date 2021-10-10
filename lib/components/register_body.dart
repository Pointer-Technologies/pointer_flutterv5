import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../app_localizations.dart';
import '../components/input_text_field.dart';
import '../components/input_text_password.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constants.dart' as Constants;


/// The body of the register activity.
// ignore: must_be_immutable
class RegisterBody extends StatefulWidget{
  String errorEmail="";
  String errorUsername="";
  String errorPassword="";
  String errorRePassword="";

  @override
  State<StatefulWidget> createState() {
    return _RegisterBodyState();
  }

  /// Checks if every single input is correct.

  // Username length check.
  bool checkUsername(String username) {
    if(username.length < 4 || username.length > 20)
      return false;
    return true;
  }

  // Email check.
  bool checkEmail(String email) {
    if(!email.contains("@"))
      return false;
    return true;
  }

  // Ensure the password is longer than 8 characters
  // and contains at least one number.
  bool checkPassword(String password) {
    if(password.length < 8 || !textContainsNum(password))
      return false;
    return true;
  }

  // Ensure the two passwords match.
  bool checkReEnterPassword(String password,String rePassword) {
    if(password==rePassword)
      return true;
    else
      return false;
  }

  // Check if the input contains a number.
  bool textContainsNum(String string) {
    return(
      string.contains("0")
      || string.contains("1")
      || string.contains("2")
      || string.contains("3")
      || string.contains("4")
      || string.contains("5")
      || string.contains("6")
      || string.contains("7")
      || string.contains("8")
      || string.contains("9"));
  }

  bool checkCheckBox() {
    return true;
  }

}

class _RegisterBodyState extends State<RegisterBody>{

  final editTextUsername = TextEditingController();
  final editTextPassword = TextEditingController();
  final editTextEmail = TextEditingController();
  final editTextRePassword = TextEditingController();

  final FirebaseAuth firebaseAuth=FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    // Screen size.
    Size size = MediaQuery.of(context).size;

    // Check if user is connected.
    firebaseAuth
        .authStateChanges()
        .listen((User user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });

    return Column(
      children: <Widget>[
        Container(
          // This container covers 5% of the screen,
          // starting from the top.
            height: size.height * 0.05,
            margin: EdgeInsets.only(bottom: 20),
            child: Stack(
              children: [
                Container(
                  // Start after the taskbar is over.
                  height: size.height * 0.05 - 10,
                  decoration: BoxDecoration(
                      color: Constants.TASKBAR_COLOR,

                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: Constants.SHADOW_COLOR,
                          offset: Offset(10, 10),
                          blurRadius: 35,
                        )
                      ]
                  ),
                ),
              ],
            )
        ),

        // Input fields, padding is pre-set.
        InputTextField.n(AppLocalizations.of(context).translate("NAME"),editTextUsername),
        Offstage(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: Constants.PARENT_PADDING),
            alignment: Alignment.centerLeft,
            child: Text(
              widget.errorUsername,
              style: TextStyle(
                color: Constants.ACCENT_COLOR,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          offstage: false,
        ),

        // Email field and the corresponding error text.
        InputTextField.n(AppLocalizations.of(context).translate("EMAIL"),editTextEmail),
        Offstage(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: Constants.PARENT_PADDING),
            alignment: Alignment.centerLeft,
            child: Text(
              widget.errorEmail,
              style: TextStyle(
                color: Constants.ACCENT_COLOR,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          // Set to false if the email is invalid.
          offstage: false,
        ),

        // First password field and the "Password must be 8 characters" text.
        InputTextPassword.n(AppLocalizations.of(context).translate("PASSWORD"), true, editTextPassword),
        Offstage(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: Constants.PARENT_PADDING),
            alignment: Alignment.centerLeft,
            child: Text(
              widget.errorPassword,
              style: TextStyle(
                color: Constants.ACCENT_COLOR,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          offstage: false,
        ),

        // The second password field and the "Passwords don't match" text.
        InputTextPassword.n(AppLocalizations.of(context).translate("REENTER_PASSWORD"), true,editTextRePassword),
        Offstage(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: Constants.PARENT_PADDING),
            alignment: Alignment.centerLeft,
            child: Text(
              widget.errorRePassword,
              style: TextStyle(
                color: Constants.ACCENT_COLOR,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          offstage: false,
        ),

        // Leave a small gap between input field and the register button.
        SizedBox(height: 30),

        // The "register" button.
        RaisedButton(
          child: Text(AppLocalizations.of(context).translate("REGISTER")),
          elevation: Constants.BUTTON_ELEVATION,
          color: Constants.ACCENT_COLOR,
          textColor: Colors.white,
          splashColor: Colors.grey.withOpacity(0.4),

          // Check inputs. If all is well, sign the user in.
          onPressed: () async {
            if (checkEntries()) {
              signUp(editTextEmail.text, editTextPassword.text);
            }
          }
          )
      ]
    );
  }


  /// Cleans up the controllers when the widget is disposed.
  @override
  void dispose() {
    editTextUsername.dispose();
    editTextEmail.dispose();
    editTextPassword.dispose();
    editTextRePassword.dispose();
    super.dispose();
  }


  /// Adds user to the database.
  Future<bool>signUp(String email,String password) async{
    try{
      await firebaseAuth.createUserWithEmailAndPassword(email: editTextEmail.text, password: editTextPassword.text);
      //UserCredential userCredential=await auth.createUserWithEmailAndPassword(email: editTextEmail.text, password: editTextPassword.text);
      //User user=userCredential.user;

      User user= FirebaseAuth.instance.currentUser;
      await user.updateProfile(displayName: editTextUsername.text);

      if(!user.emailVerified){
        Fluttertoast.showToast(msg: "A verification link has been sent to your email address.");
        await user.sendEmailVerification();
      }
      return Future.value(true);
    }

    /// Deal with errors. Each error throws the corresponding toast message.
    catch(e){
      switch(e.code){
        case 'invalid-email':
          Fluttertoast.showToast(
              msg: "Email is not valid.",
              toastLength: Toast.LENGTH_SHORT
          );
          break;
        case 'email-already-in-use':
          Fluttertoast.showToast(
              msg: "Email is already registered.",
              toastLength: Toast.LENGTH_SHORT
          );
          break;
        case 'weak-password':
          Fluttertoast.showToast(
              msg: "Password is weak.",
              toastLength: Toast.LENGTH_SHORT
          );
          break;
        default:
          print(e.toString());
          break;
      }
      return Future.value(false);
    }
  }


  /// Ensures every input is valid.
  /// Returns False if not.
  bool checkEntries() {
    bool returnedValue=true;
    setState(() {
      if(widget.checkUsername(editTextUsername.text))
        widget.errorUsername="";
      else{
        widget.errorUsername="Username must be between 4 and 20 characters long.";
        returnedValue=false;
      }

      if(widget.checkEmail(editTextEmail.text))
        widget.errorEmail="";
      else{
        widget.errorEmail=AppLocalizations.of(context).translate("CHECK_EMAIL");
        returnedValue=false;
      }

      if(widget.checkPassword(editTextPassword.text))
        widget.errorPassword="";
      else{
        widget.errorPassword=AppLocalizations.of(context).translate("REGISTER_PASSWORD");
        returnedValue=false;
      }

      if(widget.checkReEnterPassword(editTextPassword.text, editTextRePassword.text))
        widget.errorRePassword="";
      else{
        widget.errorRePassword=AppLocalizations.of(context).translate("PASSWORD_NOT_MATCH");
        returnedValue=false;
      }
    });

    return returnedValue;
  }
}