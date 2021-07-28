import 'package:flutter/material.dart';
import './stories_page.dart';
import './routes.dart';
import 'package:flutter/rendering.dart' as rendering;
import './database.dart' as db;
import './settings.dart' as settings;
import './theme.dart';
import './about.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

void main() {
  rendering.debugPaintSizeEnabled = false;

  Future.wait([
    db.init(),
    settings.instance.init(),
  ]).then((x) {
    runApp(LovecraftLibrary());
  });
}

final ThemeData lightTheme = new ThemeData(
  primarySwatch: Colors.purple,
  brightness: Brightness.light,
  accentColor: Colors.purpleAccent[100],
  primaryColor: Colors.white,
  primaryColorLight: Colors.purple[700],
  textSelectionHandleColor: Colors.purple[700],
  dividerColor: Colors.grey[200],
  bottomAppBarColor: Colors.grey[200],
  buttonColor: Colors.purple[700],
  iconTheme: new IconThemeData(color: Colors.white),
  primaryIconTheme: new IconThemeData(color: Colors.black),
  accentIconTheme: new IconThemeData(color: Colors.purple[700]),
  disabledColor: Colors.grey[500],
);

final ThemeData darkTheme = new ThemeData(
  primarySwatch: Colors.purple,
  brightness: Brightness.dark,
  accentColor: Colors.deepPurpleAccent[100],
  primaryColor: Color.fromRGBO(50, 50, 57, 1.0),
  primaryColorLight: Colors.deepPurpleAccent[100],
  textSelectionHandleColor: Colors.deepPurpleAccent[100],
  buttonColor: Colors.deepPurpleAccent[100],
  iconTheme: new IconThemeData(color: Colors.white),
  accentIconTheme: new IconThemeData(color: Colors.deepPurpleAccent[100]),
  cardColor: Color.fromRGBO(55, 55, 55, 1.0),
  dividerColor: Color.fromRGBO(60, 60, 60, 1.0),
  bottomAppBarColor: Colors.black26,
);

class LovecraftLibraryState extends State<LovecraftLibrary> implements settings.ThemeChangeListener {
  static FirebaseAnalytics _analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver _observer =
      FirebaseAnalyticsObserver(analytics: _analytics);

  AppTheme _theme;

  LovecraftLibraryState() {
    _theme = settings.instance.theme;
    settings.instance.themeChangeListener = this;
  }

  @override
  void initState() {
    super.initState();

    precacheImage(AssetImage('assets/drawer.jpg'), context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [LovecraftLibraryState._observer],
      title: 'Lovecraft Library',
      theme: _theme == AppTheme.Dark ? darkTheme : lightTheme,
      home: new StoryPage(),
      routes: {
        '${Routes.Stories}': (context) => StoryPage(),
        '${Routes.About}': (context) => AboutPage(),
      },
    );
  }

  @override
  void onThemeChange() {
    setState(() {
      _theme = settings.instance.theme;
    });
  }
}

class LovecraftLibrary extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LovecraftLibraryState();
  }
}
