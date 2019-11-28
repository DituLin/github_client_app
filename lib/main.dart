import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:github_client_app/i10n/localization_intl.dart';
import 'package:github_client_app/routes/home_page.dart';
import 'package:github_client_app/routes/language.dart';
import 'package:github_client_app/routes/login.dart';
import 'package:github_client_app/routes/theme_change.dart';
import 'package:github_client_app/states/ProfileChangeNotifier.dart';
import 'package:provider/provider.dart';

import 'common/Global.dart';

void main() => Global.init().then((e) =>runApp(MyApp()));

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers:<SingleChildCloneableWidget>[
          ChangeNotifierProvider.value(value: ThemeModel()),
          ChangeNotifierProvider.value(value: UserModel()),
          ChangeNotifierProvider.value(value: LocaleModel())
        ],
      child: Consumer2<ThemeModel,LocaleModel>(
        builder: (BuildContext context,themeModel,localeModel,Widget child){
          return MaterialApp(
            theme: ThemeData(
              primarySwatch: themeModel.theme,
            ),
            onGenerateTitle: (context){
              return GmLocalizations.of(context).title;
            },
            home: HomeRoute(),// home page
            locale: localeModel.getLocale(),
            //我们只支持美国英语和中文简体
            supportedLocales: [
              const Locale('en','US'),
              const Locale('zh','CN'),
            ],
            localizationsDelegates: [
              // 本地化的代理类
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              // 注册我们的Delegate
              GmLocalizationsDelegate()
            ],
            localeResolutionCallback: (Locale _locale,Iterable<Locale> supportedLocales){
                if(localeModel.getLocale() != null) {
                  //如果已经选定语言，则不跟随系统
                  return localeModel.getLocale();
                }else{
                  Locale locale;
                  if(supportedLocales.contains(_locale)) {
                    locale = _locale;
                  }else{
                    //如果系统语言不是中文简体或美国英语，则默认使用美国英语
                    locale= Locale('en', 'US');
                  }
                  return locale;
                }
            },
            // 注册路由表
            routes: <String,WidgetBuilder>{
              "login": (context) => LoginRoute(),
              "themes": (context) => ThemeChangeRoute(),
              "language": (context) => LanguageRoute(),
            },
          );
        },
      )
    );
  }
}

