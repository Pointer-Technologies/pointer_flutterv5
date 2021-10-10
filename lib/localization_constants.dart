import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

/// ---------- LANGUAGES ---------- ///
const String ENGLISH="en";
const String GREEK="el";

const String LANGUAGE_CODE="languageCode";

Future<Locale> setLocale(String languageCode) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  await _prefs.setString(LANGUAGE_CODE,languageCode);
  return _locale(languageCode);
}

Locale _locale(String languageCode){
  Locale _temp;
  switch(languageCode){
    case ENGLISH:
      _temp=Locale(languageCode,"US");
      break;
    case GREEK:
      _temp=Locale(languageCode,"GR");
      break;
    default:
      _temp=Locale(languageCode,"US");
  }
  return _temp;
}

Future<Locale> getLocale() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  String languageCode= _prefs.getString(LANGUAGE_CODE) ?? ENGLISH;
  return _locale(languageCode);
}