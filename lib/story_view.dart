import 'package:flutter/material.dart';
import './story_manager.dart' as StoryManager;
import './models/story_meta.dart';
import './models/story.dart';
import './models/story_config.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;
import './settings.dart' as settings;

class StoryView extends StatefulWidget {
  final Story story;

  StoryView(this.story);

  @override
  _StoryViewState createState() => _StoryViewState(story);
}

class ListController extends ScrollController {
  ListController({ double initialScrollOffset })
    : super(initialScrollOffset: initialScrollOffset);
}

Widget createTitleWidget(BuildContext context, StoryMetaData metadata) {
  var accentColor = Theme.of(context).accentColor;
  return Column(
    children: <Widget>[
      Container(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
        child: Text(
          metadata.title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'WieynkFraktur',
            fontSize: 30,
          ),
        ),
      ),
      Container(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
        child: Text(
          metadata.authorship,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
      Hero(
        tag: metadata.imageAssetName,
        child: Image.asset('assets/story_images/${metadata.imageAssetName}'),
      ),
      GestureDetector(
        onTap: () {
          launch(metadata.imageSourceUri);
        },
        child: Container(
          padding: EdgeInsets.fromLTRB(0, 6, 0, 0),
          child: SizedBox(
            height: 48,
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.body1,
                children: [
                  TextSpan(text: 'Image by '),
                  TextSpan(
                    text: metadata.imageAuthorName,
                    style: TextStyle(color: accentColor, decoration: TextDecoration.underline),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

var _fontSizes = [.8, 1.0, 1.2, 1.4, 1.6];

class _StoryViewState extends State<StoryView> {
  final Story _story;
  final ListController _listController;

  int _fontSizeIndex;
  bool _canIncreaseSize = false;
  bool _canDecreaseSize = false;

  _StoryViewState(this._story) :
    _listController = ListController(initialScrollOffset: _story.config.scrollPosition),
    _fontSizeIndex = settings.instance.fontSize;

  @override
  void deactivate() {
    super.deactivate();

    var newStoryConfig = StoryConfig(scrollPosition: _listController.offset);
    StoryManager.setStoryConfig(_story.metadata, newStoryConfig);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_story.metadata.title.toUpperCase()),
      ),
      body: GestureDetector(
        onScaleStart: (scaleStartDetails) {
          _canDecreaseSize = true;
          _canIncreaseSize = true;
        },
        onScaleUpdate: (scaleUpdateDetails) {
          var extent = math.max(scaleUpdateDetails.verticalScale, scaleUpdateDetails.horizontalScale);
          if (_canIncreaseSize && extent > 1 && _fontSizeIndex != _fontSizes.length - 1) {
            setState(() {
              ++_fontSizeIndex;
              _canIncreaseSize = false;
              _canDecreaseSize = true;
              settings.instance.fontSize =_fontSizeIndex;
            });
          }

          if (_canDecreaseSize && extent < 1 && _fontSizeIndex != 0) {
            setState(() {
              --_fontSizeIndex;
              _canDecreaseSize = false;
              _canIncreaseSize = true;
              settings.instance.fontSize =_fontSizeIndex;
            });
          }
        },
        child: Scrollbar(
          child: ListView.builder(
            controller: _listController,
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            itemCount: (_story == null ? 0 : _story.body.length) + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return createTitleWidget(context, _story.metadata);
              }

              TextStyle baseTextStyle = Theme.of(context).textTheme.body1.apply(fontSizeFactor: _fontSizes[_fontSizeIndex]);
              return _story.body[index - 1].generateWidget(baseTextStyle);
            },
          ),
        ),
      ),
    );
  }
}
