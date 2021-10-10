import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  /// Helper method to keep the code in the widgets concise.
  /// Localizations are accesed using an InheritedWidget "of" syntax
  static AppLocalizations of(BuildContext context){
    return Localizations.of(context, AppLocalizations);
  }

  /// Static number for instant access through MaterialApp
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
  Map <String,String> _localizedStrings;

  Future<bool> load() async{
    /// Load the language json file from the "lang" folder.
    String jsonString = await rootBundle.loadString('lang/${locale.languageCode}.json');

    Map<String,dynamic> jsonMap= json.decode(jsonString);

    _localizedStrings= jsonMap.map((key, value){
      return MapEntry(key, value.toString());
    });
    return true;
  }

  /// Method called from every widget which needs a localized text.
  String translate(String key){
    return _localizedStrings[key];
  }
}

/// localizationsDelegate is a factory for a set of localized resources.
/// In this case the localized strings will be gotten in an AppLocalizations object.
class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations>{

  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ["en","el"].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {

    //AppLocalizations class is where the JSON loading actually runs.
    AppLocalizations localizations=new AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}