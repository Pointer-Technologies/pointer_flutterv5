import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:pointer_flutter/activities/app_center_activity.dart';
import 'package:pointer_flutter/activities/register_activity.dart';
import 'package:pointer_flutter/components/input_text_field.dart';
import 'package:pointer_flutter/components/input_text_password.dart';

import 'package:pointer_flutter/constants.dart' as Constants;
import 'package:shared_preferences/shared_preferences.dart';

import '../app_localizations.dart';


/// The body of the sign in activity.
// ignore: must_be_immutable
class SignInBody extends StatefulWidget {

  final String errorEmail = "";
  final String errorPassword = "";

  /// Boolean that keeps the "Remember me" preference.
  bool rememberMe = false;

  @override
  State<StatefulWidget> createState() {
    return _SignInBodyState();
  }

}

class _SignInBodyState extends State<SignInBody> {
  /// The input field controllers.
  TextEditingController forgotPassword = TextEditingController();
  TextEditingController editTextEmail = TextEditingController();
  TextEditingController editTextPassword = TextEditingController();

  /// The boolean that disables the sign in button once it's pressed.
  bool isSignInDisabled = true;

  /// Firebase instance.
  final FirebaseAuth auth=FirebaseAuth.instance;

  @override
  void initState() {
    rememberButton();
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    // Screen size.
    Size size = MediaQuery.of(context).size;

    return Column(
      children: <Widget>[

        // The rounded corner box.
        Container(
          // This container covers the 17% of the screen,
          // starting from the top.
          height: size.height * 0.17,
          margin: EdgeInsets.only(bottom: 20),
          child: Stack(
            children: <Widget>[
              Container(
                // Start after the taskbar is over.
                height: size.height * 0.17 - 60,
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

              // Position logo to the bottom of the container.
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: new BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Image.asset(
                    'assets/images/pointer.jpg',
                    width: 120,
                    height: 120
                  ),
                )
              )
            ],
          )
        ),

        // The POINTER TECHNOLOGIES text.
        Container(
          margin: EdgeInsets.only(bottom: 20),
          child: Text(
            AppLocalizations.of(context).translate("POINTER_TECHNOLOGIES"),
            textScaleFactor: 1.2,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              fontSize: 20
            ),
          ),
        ),

        // Name input field.
        InputTextField.n(AppLocalizations.of(context).translate("EMAIL"),editTextEmail),

        // Password input field.
        InputTextPassword.n(AppLocalizations.of(context).translate("PASSWORD"), true, editTextPassword),

        // The "Wrong email/password" text.
        // Appears if the email-password pair doesn't match.
        Offstage(
          child: Text(
            widget.errorPassword,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Constants.ACCENT_COLOR,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
            ),
          ),

          // offstage: (Set to true if the email and password don't match)
          offstage: false,
        ),


        /// The "Remember me" checkbox and "Forgot password" button row.
        /// Put in expanded boxes to flex accordingly.
        /// "Remember me" takes twice as much space as "Forgot Password"
        Container(
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              // Bind the checkbox and "remember me" text.
              Expanded(
                flex: 2,
                child: Container(
                  child: Row(
                    children:[
                      Checkbox(
                        value: widget.rememberMe,

                        /// Signs the user in.
                        /// Keeps the credentials if "rememeber me" is checked.
                        onChanged:(bool newValue) async {
                          final prefs = await SharedPreferences.getInstance();
                          prefs.setBool("remember", newValue);
                          setState(() {
                            widget.rememberMe=newValue;
                          });
                        },
                        activeColor: Constants.ACCENT_COLOR,
                      ),

                      Text(
                        AppLocalizations.of(context).translate("REMEMBER_ME"),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ]
                  )
                ),
              ),

              // "Forgot Password" button.
              Expanded(
                flex: 1,
                child: FlatButton(
                  /// Call the "Forgot Password" dialog.
                  onPressed: _forgotPassword,

                  child: Text(
                    AppLocalizations.of(context).translate("FORGOT_PASSWORD"),
                    style: TextStyle(
                      color: Constants.ACCENT_COLOR,
                      fontStyle: FontStyle.italic,
                    )
                  )
                ),
              ),
            ],
          ),
        ),

        // Sign in button.
        Container(
          padding: EdgeInsets.symmetric(
            vertical: Constants.PARENT_PADDING / 2,
            horizontal: Constants.PARENT_PADDING
          ),

          child: RaisedButton(
            child: Text(AppLocalizations.of(context).translate("SIGN_IN")),
            color: Constants.ACCENT_COLOR,
            elevation: Constants.BUTTON_ELEVATION,
            splashColor: Colors.grey.withOpacity(0.4),
            textColor: Colors.white,

            // Navigate to the app center activity.
            // Immediately disable the sign in button.
            onPressed: () async {
              // Show a progress indicator until the sign in progress is over.
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    backgroundColor: Colors.transparent.withOpacity(0.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                      heightFactor: 0.5,
                      widthFactor: 0.5,
                    )
                  );
                }
              );

              if(editTextEmail.text.trim() != "" && editTextPassword.text.trim() != "") {
                if (await _signIn(editTextEmail.text.trim(), editTextPassword.text.trim())) {
                  Navigator.pop(context);
                  Navigator.of(context).push(_createRoute(
                    child: AppCenterActivity(),
                    dx: 1.0,
                    dy: 0.0,
                  ));
                }
                else{
                  Navigator.pop(context);
                }
                return null;
              }
              else {
                Fluttertoast.showToast(msg: "Fields can't be empty.");
                Navigator.pop(context);
              }
            },
          ),
        ),

        // The two sign up buttons.
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              children: <Widget>[
                // Margin after the sign in button.
                SizedBox(height: 30),

                // "Sign up using email"
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 20),

                  child: RaisedButton(
                    child: Text(AppLocalizations.of(context).translate("SIGN_UP")),
                    textColor: Constants.ACCENT_COLOR,
                    color: Colors.white,

                    // Navigate to the register activity.
                    onPressed: () {
                      Navigator.of(context).push(_createRoute(
                        child: RegisterActivity(),
                        dx: -1.0,
                        dy: 0.0,
                      ));
                    },
                  )
                ),

                SizedBox(height: 10),

                // "Sign up with Google"
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: SignInButton(
                    Buttons.Google,
                    mini: false,
                    onPressed: () async {
                      if(await _googleSignIn()){
                        Navigator.of(context).push(_createRoute(
                          child: AppCenterActivity(),
                          dx: 1.0,
                          dy: 0.0,
                        ));
                      }
                    },
                  ),
                ),
              ]
            ),
          ),
        ),
      ]
    );
  }


  /// Uses a Google account to sign the user in.
  /// Used for the "Sign up with Google" button.
  Future<bool> _googleSignIn() async {
    try {
      GoogleSignInAccount googleSignInAccount = await GoogleSignIn().signIn();

      if (googleSignInAccount != null) {
        GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount
            .authentication;

        AuthCredential authCredential = GoogleAuthProvider.credential(
            idToken: googleSignInAuthentication.idToken,
            accessToken: googleSignInAuthentication.accessToken
        );

        await auth.signInWithCredential(authCredential);
        return Future.value(true);
      }
      }
      catch(e) {
        switch(e.code) {
          case 'account-exists-with-different-credential':
            Fluttertoast.showToast(
                msg: "There is already an account registered with this email.",
                toastLength: Toast.LENGTH_SHORT
            );
            break;
          case 'user-not-found':
            Fluttertoast.showToast(
                msg: "User is not found.",
                toastLength: Toast.LENGTH_SHORT
            );
            break;
          case 'wrong-password':
            Fluttertoast.showToast(
                msg: "Password is wrong for this email.",
                toastLength: Toast.LENGTH_SHORT
            );
            break;
          default:
            print(e.code);
            break;
        }
        return Future.value(false);
      }
    return Future.value(false);
  }


  /// Used for the custom email and password authentication
  /// (Sign in button).
  Future<bool> _signIn(String email,String password) async {
    try{
      await auth.signInWithEmailAndPassword(email: email, password: password);
      if(FirebaseAuth.instance.currentUser.emailVerified)
        return Future.value(true);
      else{
        Fluttertoast.showToast(msg: "User is not verified yet.");
        return Future.value(false);
      }
    }
    catch(e) {
      switch(e.code) {
        case 'invalid-email':
          Fluttertoast.showToast(
              msg: "Email is not valid.",
              toastLength: Toast.LENGTH_SHORT
          );
          break;
        case 'user-not-found':
          Fluttertoast.showToast(
              msg: "There is no user with this email address.",
              toastLength: Toast.LENGTH_SHORT
          );
          break;
        case 'wrong-password':
          Fluttertoast.showToast(
              msg: "Password is wrong.",
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


  /// Drives all the animations that start from the sign in activity.
  /// Visualizes a sliding effect, directed by the vertical and horizontal offsets.
  /// @Param:
  /// Child: The activity the animation is guided to.
  /// dx: The child's horizontal offset.
  /// dy: The child's vertical offset.
  Route _createRoute({Widget child, double dx, double dy}) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: Duration(milliseconds: 400),
      reverseTransitionDuration: Duration(milliseconds: 400),

      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Set the initial and final position of the transitioning element.
        var begin = Offset(dx, dy);
        var end = Offset.zero;

        // Set the sliding transition effect speed.
        var curve = Curves.easeInOutSine;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }


  /// Disposes of inputs after signing in.
  @override
  void dispose() {
    editTextEmail.dispose();
    editTextPassword.dispose();
    forgotPassword.dispose();
    super.dispose();
  }


  /// Signs the user out depending on the sign in method.
  Future<void> signOut() async{
    try {
      if (await GoogleSignIn().isSignedIn()) {
        await GoogleSignIn().disconnect();
      }
      await FirebaseAuth.instance.signOut();
    }
    catch(e){
      Fluttertoast.showToast(msg: e.code);
    }
  }


  /// Keeps the "Remember me" boolean in SharedPreferences.
  Future<void> rememberButton() async{
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool("remember");

    // Sign the user in.
    if(rememberMe && FirebaseAuth.instance.currentUser != null){
      Navigator.of(context).push(_createRoute(
        child: AppCenterActivity(),
        dx: 1.0,
        dy: 0.0,
      ));
    }
  }


  /// Builds the "Forgot password" dialog, which prompts the user
  /// to give an email address to which a backup code will be sent.
  Future<void> _forgotPassword() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          elevation: Constants.BUTTON_ELEVATION,
          insetAnimationDuration: Duration(milliseconds: 200),
          clipBehavior: Clip.hardEdge,

          child: Padding(
            padding: const EdgeInsets.all(Constants.PARENT_PADDING),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // The "provide us with an email" text.
                Text(
                  AppLocalizations.of(context).translate("EMAIL_FOR_PASSWORD"),
                  style: TextStyle(
                    color: Constants.ACCENT_COLOR
                  ),
                ),

                // The email input field.
                InputTextField.n(AppLocalizations.of(context).translate("EMAIL"), forgotPassword),

                // The "send email" button.
                RaisedButton(
                  child: Text(AppLocalizations.of(context).translate("SEND_EMAIL")),
                  color: Constants.ACCENT_COLOR,
                  textColor: Colors.white,
                  elevation: Constants.BUTTON_ELEVATION,
                  splashColor: Colors.grey.withOpacity(0.4),

                  // Send an email with a backup password.
                  onPressed: () async {
                    if(forgotPassword.text.isEmpty) {
                      Fluttertoast.showToast(msg: "Email can't be empty.");
                    }
                    else if(!forgotPassword.text.contains("@"))
                      Fluttertoast.showToast(msg: "This doesn't seem as a valid email address.");
                    else{
                      Fluttertoast.showToast(msg: "An email has been sent to " + forgotPassword.text);
                      await sendPasswordResetEmail(forgotPassword.text);
                    }
                    Navigator.pop(context);
                  },
                )
              ],
            ),
          )
        );
      }
    );
    return Future.value();
  }


  /// Sends a backup password to the given email address.
  Future sendPasswordResetEmail(String email)async {
    return FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

}