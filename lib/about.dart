import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Hero(
              tag: 'drawer_image',
              child: Image.asset('assets/drawer.jpg'),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                launch('mailto:randall@randallschmidt.com?subject=Lovecraft%20Library%20App');
              },
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                    child: Text('Lovecraft Library © 2019 Mistball Technologies'),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 4, bottom: 36),
                    child: SizedBox(
                      child: RichText(
                        text: TextSpan(
                          text: 'randall@randallschmidt.com',
                          style: theme.textTheme.body1.apply(color: theme.accentColor),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: Text('Acknowledgements', style: theme.textTheme.title),
            ),
            Container(
              padding: EdgeInsets.only(top: 20, left: 20, right: 20),
              child: Text('In addition to the authors of the images used in stories (credited on the respective story page):', textAlign: TextAlign.center,),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                launch('http://www.hplovecraft.com/writings/texts/');
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(10, 30, 10, 0),
                child: SizedBox(
                  child: RichText(
                    text: TextSpan(
                      text: 'The H.P. Lovecraft Archive for story text',
                      style: theme.textTheme.body1.apply(color: theme.accentColor),
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                launch('https://commons.wikimedia.org/wiki/File:The_Temple_-_Lovecraftian_Concept_Art_by_Mihail_Bila.jpg');
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 30, 20, 24),
                child: SizedBox(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'Mihail Bila for \'The Temple\' image used for the app banner ',
                      style: theme.textTheme.body1.apply(color: theme.accentColor),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
