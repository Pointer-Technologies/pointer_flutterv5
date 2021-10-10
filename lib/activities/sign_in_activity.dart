import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pointer_flutter/classes/Language.dart';
import 'package:pointer_flutter/main.dart';
import '../app_localizations.dart';
import '../components/sign_in_body.dart';
import 'package:pointer_flutter/localization_constants.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart' as Constants;
import '../utils.dart';


/// Initialization of the sign in activity,
/// which is the first activity that MyApp shows,
/// when the app is first opened.
class SignInActivity extends StatefulWidget {
  SignInActivity({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SignInActivityState createState() => _SignInActivityState();
}

class _SignInActivityState extends State<SignInActivity> {

  /// Sets the user selected language.
  void _changeLanguage(Language language) async{

    Locale _temp = await setLocale(language.languageCode);
    MyApp.setLocale(context,_temp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Constants.TASKBAR_COLOR,
        elevation: 0,

        // Actions presented in the taskbar.
        actions: [

          // Select language.
          Padding(
            padding: EdgeInsets.only(right: 20),

            child: GestureDetector(
              child: Icon(Icons.language_outlined),

              onTap:(){
              _languageDialog();
              },
            ),

            //SECOND VIEW//

            /*child: DropdownButton(
              onChanged: (lang) {
                _changeLanguage(lang);
              },
              underline: SizedBox(),

              icon: Icon(Icons.language_outlined),
              items:Language.languageList()
                  .map<DropdownMenuItem>((lang) => DropdownMenuItem(
                value: lang,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(lang.flag),
                    Text(lang.name,style: TextStyle(fontSize: 26),)
                  ],
                ),
              )).toList(),
            ),
             */

          ),

          // "Help" action.
          Padding(
            padding:EdgeInsets.only(right: 20),

            child: GestureDetector(
              child: Icon(Icons.help_outline_rounded),

              onTap: (){
                _helpDialog();
              },
            ),
          ),

          // "About us" acion.
          Padding(
              padding:EdgeInsets.only(right: 20),

              child: GestureDetector(
                child: Icon(Icons.info_outline_rounded),

                onTap: (){
                  _aboutDialog();
                },
              ),
          ),

        ],
      ),

      /// The activity body is formed in a second class
      /// to remain compact.
      body: SignInBody(),
    );
  }


  /// The "Select language" dialog.
  Future<void> _languageDialog() async{
    await showCupertinoDialog(
    context: context,
    barrierDismissible: true,

    builder: (BuildContext context) {
    return SimpleDialog(
        contentPadding: EdgeInsets.all(Constants.ELEMENT_MARGIN),

        title: Text(
          AppLocalizations.of(context).translate("CHOOSE_LANGUAGE"),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22
          ),
        ),

        children:
        Language.languageList().map((lang) => Container(
          padding: EdgeInsets.all(20),
          child: GestureDetector(
            onTap: (){
              _changeLanguage(lang);
              Navigator.pop(context);
              },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

              children: [
                Text(lang.name,style: TextStyle(fontSize: 26),),
                Text(lang.flag,style: TextStyle(fontSize: 20),)
              ],
            ),
          )
        )
        ).toList()

    );

  });
  }


  /// The "about us" dialog.
  /// Empty for now, who cares.
  void _aboutDialog() async{
    await showCupertinoDialog(
      context: context,
      barrierDismissible: true,

      builder: (BuildContext context){
        return SimpleDialog(
          contentPadding: EdgeInsets.all(Constants.ELEMENT_MARGIN),

          title: Text(
            AppLocalizations.of(context).translate("ABOUT_US"),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22)
            ),

          children: [
            Padding(padding: EdgeInsets.all(20),
              child: Text("Something here...\nMaybe a youtube video.",style: TextStyle(fontSize: 20),),
            )
          ],
        );
      }
    );
  }


  /// The "help" dialog.
  /// Contains an option to call support
  /// and another one to send a mail for help.
  void _helpDialog() async{
    await showCupertinoDialog(
      context: context,
      barrierDismissible: true,

      builder: (BuildContext context){
        return SimpleDialog(
          contentPadding: EdgeInsets.all(Constants.ELEMENT_MARGIN),

          title: Text(
            AppLocalizations.of(context).translate("CONTACT_US"),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22
            )
          ),

          children: [
            GestureDetector(
              child: Padding(
                padding: const EdgeInsets.all(8.0),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,

                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.mail_outline_outlined,
                        color: Colors.redAccent,
                        size: 40
                      ),
                    ),
                    Text(AppLocalizations.of(context).translate("EMAIL"))
                  ],
                ),
              ),

              onTap: () async{
                await Utils.openEmail("info@pointertrackers.com","","");
              },
            ),

            GestureDetector(
              child: Padding(
                padding: const EdgeInsets.all(8.0),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.phone_outlined,
                        color: Colors.green,
                        size: 40,
                      ),
                    ),
                    Text(AppLocalizations.of(context).translate("PHONE"))
                  ],
                ),
              ),

              onTap: (){
                Utils.openPhoneCall("+306900000000");
             },
            )
          ],
        );
      }
    );
  }

}
