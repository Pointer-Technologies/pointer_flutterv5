/*
 * Copyright 2020 Pointer Technologies
 * Using the Flutter Framework on Android Studio.
 *
 * Authored by:
 * Antonios Antoniou,
 * Konstantinos Gerogiannis.
 *
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pointer_flutter/localization_constants.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pointer_flutter/activities/sign_in_activity.dart';

import 'app_localizations.dart';
import 'constants.dart' as Constants;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  WidgetsFlutterBinding.ensureInitialized();

  /// Ensure function exclusively in portait mode.
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
    .then((_) {
      runApp(
        MyApp(
          model: AppModel(),
        ),
      );
    });
}

/// MyApp turns to a stateful widget to
/// listen to the changes in theming.
class MyApp extends StatefulWidget {

  final AppModel model;
  const MyApp({Key key, this.model}) : super(key: key);

  static void setLocale(BuildContext context, Locale temp) {
    _MyAppState state=context.findAncestorStateOfType();
    state.setLocale(temp);
  }


  @override
  State<MyApp> createState() {
    return _MyAppState();
  }

}

class _MyAppState extends State<MyApp> {
  Locale _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale=locale;
    });
  }


  @override
  void initState() {
    super.initState();
    widget.model.addListener(() {
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() async {
    await getLocale().then((locale){
      setState(() {
        this._locale=locale;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    startVisibilityMode();
    /*if (_locale==null){
      return Container(child:Center(child: CircularProgressIndicator()));
    }
    else{

     */
    return ScopedModel<AppModel>(
        model: widget.model,

        child: MaterialApp(
          title: 'Pointer Trackers',
          debugShowCheckedModeBanner: false,

          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.grey,
            accentColor: Constants.ACCENT_COLOR,
            backgroundColor: Colors.white,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),

          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.grey,
            accentColor: Constants.ACCENT_COLOR,
            backgroundColor: Colors.black,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),

          /// Change the theme depending on the model's properties.
          themeMode: widget.model._mode,

          locale: _locale,
          supportedLocales: [
            Locale("en","US"),
            Locale("el","GR"),
          ],
          //These delegates make sure that the localization data for the proper language is loaded
          localizationsDelegates: [
            //Custom function: Loads the translation from JSON files.
            AppLocalizations.delegate,

            //Built-in localization of basic text for material widgets
            GlobalMaterialLocalizations.delegate,

            //Built-in localization of basic text for cupertino widgets
            GlobalCupertinoLocalizations.delegate,

            //Built-in localization for text direction ( Right to left / left to right)
            GlobalWidgetsLocalizations.delegate,


          ],

          localeResolutionCallback: (locale,supportedLocales) {
            if(locale==null)
               locale=Localizations.localeOf(context);

              //Check if current device's locale is supported.
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale.languageCode
                    && supportedLocale.countryCode == locale.countryCode)
                  return supportedLocale;
              }
            //If the locale of the device is not supported return English.
            return supportedLocales.first;
          },

          // home: AppCenterActivity(),
          //home: SignInActivity(title: AppLocalizations.of(context).translate("SIGN_IN_TITLE")),
          home: SignInActivity(title: Constants.SIGN_IN_TITLE),
          // home: RegisterActivity(title: Constants.REGISTER_TITLE)
        )
    );
  }//}


  Future<void> startVisibilityMode() async{
    SharedPreferences preferences=await SharedPreferences.getInstance();
    bool light=preferences.getBool("light");

    if(light == false || light == null)
      widget.model._mode = ThemeMode.dark;
    else
      widget.model._mode = ThemeMode.light;
  }


}

/// This model class holds the theme information throughout the app.
/// The information is passed explicitly only when it is needed.
class AppModel extends Model {
  ThemeMode _mode;

  ThemeMode get mode => _mode;

  void toggleMode() {
    _mode = (_mode == ThemeMode.light) ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

