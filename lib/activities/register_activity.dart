import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../app_localizations.dart';
import '../components/register_body.dart';

import '../constants.dart' as Constants;


/// The register activity is called whenever a user
/// wants to sign up using a custom email and password.
class RegisterActivity extends StatefulWidget{
  RegisterActivity({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _RegisterActivityState createState(){
    return _RegisterActivityState();
  }
}

class _RegisterActivityState extends State<RegisterActivity>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          // Add a forward arrow instead of the back button.
          Padding(
            padding: EdgeInsetsDirectional.only(end: 20),
            child: GestureDetector(
              child: Icon(Icons.arrow_forward_ios_rounded),
              onTap: (){
                Navigator.pop(context);
              },
            )
          )
        ],

        // Disable the default back button.
        automaticallyImplyLeading: false,

        title: Text(AppLocalizations.of(context).translate("REGISTER_TITLE")),
        backgroundColor: Constants.TASKBAR_COLOR,
        elevation: 0,
      ),
      body: RegisterBody(),
    );
  }
}