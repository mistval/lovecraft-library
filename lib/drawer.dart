import 'package:flutter/material.dart';
import './routes.dart';
import './settings.dart' as settings;
import './theme.dart';
import 'package:url_launcher/url_launcher.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  AppDrawer(this.currentRoute);

  @override
  Widget build(BuildContext context) {
    var navigator = Navigator.of(context);
    var currentAppTheme = settings.instance.theme;

    return Drawer(
      child: Scaffold(
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Theme.of(context).bottomAppBarColor,
              ),
            ),
          ),
          child: new ListTile(
            onTap: () {
              settings.instance.theme = currentAppTheme == AppTheme.Light ? AppTheme.Dark : AppTheme.Light;
            },
            leading: new Icon(
              currentAppTheme == AppTheme.Light ? Icons.brightness_7 : Icons.brightness_3,
              color: Theme.of(context).buttonColor
            ),
            title: new Text(
              currentAppTheme == AppTheme.Light ? 'Light' : 'Dark',
              style: Theme.of(context).textTheme.body2.apply(color: Theme.of(context).buttonColor)
            ),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Hero(
                tag: 'drawer_image',
                child: Image.asset('assets/drawer.jpg'),
              ),
            ),
            ListTile(
              leading: Icon(Icons.book),
              title: Text('Library'),
              onTap: () {
                if (currentRoute == Routes.Stories) {
                  navigator.pop();
                  return;
                }

                navigator.pushReplacementNamed(Routes.Stories);
              },
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('About'),
              onTap: () {
                navigator.pushNamed(Routes.About);
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('Privacy Policy'),
              onTap: () {
                launch('http://randallschmidt.com/privacy/lovecraft_library.html');
              },
            ),
          ],
        ),
      ),
    );
  }
}
