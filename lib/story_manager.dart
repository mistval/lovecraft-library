import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'dart:convert';
import './models/story_meta.dart';
import './models/story.dart';
import './models/story_config.dart';
import './story_element.dart';
import './database.dart' as database;
import 'dart:async';
import 'dart:math' as math;

const RECENT_DB_KEY = 'recent stories';
const SCROLL_POSITION_KEY = 'scroll position';

enum SpanType {
  Normal,
  Bold,
  Italics,
}

SpanType getStringStartSpanType(String text) {
  if (text.startsWith('<i>')) {
    return SpanType.Italics;
  } else if (text.startsWith('<b>')) {
    return SpanType.Bold;
  } else {
    return SpanType.Normal;
  }
}

int getCurrentSpanEndIndex(String text, SpanType currentSpanType) {
  var italicsEndIndex = text.indexOf('</i>');
  var boldEndIndex = text.indexOf('</b>');

  if (currentSpanType == SpanType.Italics) {
    return italicsEndIndex == -1 ? text.length - 1 : italicsEndIndex + 4;
  } else if (currentSpanType == SpanType.Bold) {
    return boldEndIndex == -1 ? text.length - 1 : boldEndIndex + 4;
  } else {
    var italicsStartIndex = text.indexOf('<i>');
    var boldStartIndex = text.indexOf('<b>');

    if (italicsStartIndex == -1) {
      if (boldStartIndex != -1) {
        return boldStartIndex;
      }

      return text.length;
    }

    if (boldStartIndex == -1) {
      if (italicsStartIndex != -1) {
        return italicsStartIndex;
      }

      return text.length;
    }

    return math.min(boldStartIndex, italicsStartIndex) + 3;
  }
}

List<TextSpan> getTextInfo(String text) {
  var remainingText = text;
  var spans = List<TextSpan>();

  while (remainingText.length > 0) {
    var spanType = getStringStartSpanType(remainingText);
    var spanEndIndex = getCurrentSpanEndIndex(remainingText, spanType);

    var spanText = remainingText.substring(0, spanEndIndex).replaceAll(new RegExp(r'<.*?>'), '');
    remainingText = remainingText.substring(spanEndIndex);

    spans.add(
      TextSpan(
        text: spanText,
        style: TextStyle(
          fontWeight: spanType == SpanType.Bold ? FontWeight.bold : FontWeight.normal,
          fontStyle: spanType == SpanType.Italics ? FontStyle.italic : FontStyle.normal,
        ),
      ),
    );
  }

  return spans;
}

Widget _createTextWidget(String text, TextAlign align, TextStyle baseTextStyle) {
  text = text.replaceAll('\t', '      ').replaceAll('<sup>', '(').replaceAll('</sup>', ')');

  return RichText(
    textAlign: align,
    text: TextSpan(
      style: baseTextStyle,
      children: getTextInfo(text),
    ),
  );
}

class _Paragraph extends StoryElement {
  final String text;
  final TextAlign align;

  _Paragraph({ this.text, this.align });

  @override
  Widget generateWidget(TextStyle baseTextStyle) {
    return Row(
      children: [
        Expanded(
          child: _createTextWidget(text, align, baseTextStyle),
        )
      ],
    );
  }
}

class _BreakLine extends StoryElement {
  @override
  Widget generateWidget(TextStyle baseTextStyle) {
    return SizedBox(
      child: null,
      height: 10,
    );
  }
}

class _ParentElement extends StoryElement {
  final List<StoryElement> children;
  final EdgeInsets insets;

  _ParentElement({ this.children, this.insets });

  @override
  Widget generateWidget(TextStyle baseTextStyle) {
    return Container(
      padding: this.insets,
        child: Column(
        children: children.map((child) => child.generateWidget(baseTextStyle)).toList(),
      ),
    );
  }
}

StoryElement _createChild(Map<String, dynamic> rawChild, TextAlign align) {
  final type = rawChild['type'];

  if (type == 'paragraph') {
    return _Paragraph(text: rawChild['text'], align: align);
  } else if (type == 'center')  {
    final children = createChildren(List<Map<String, dynamic>>.from(rawChild['children']), TextAlign.center);
    return _ParentElement(children: children);
  } else if (type == 'right') {
    final children = createChildren(List<Map<String, dynamic>>.from(rawChild['children']), TextAlign.right);
    return _ParentElement(children: children);
  } else if (type == 'blockquote') {
    final children = createChildren(List<Map<String, dynamic>>.from(rawChild['children']), align);
    return _ParentElement(
      children: children,
      insets: EdgeInsets.symmetric(horizontal: 20),
    );
  } else if (type == 'breakline') {
    return _BreakLine();
  } else if (type == 'horizontal-rule') {
    return _BreakLine();
  }

  throw StateError('Unexpected child type');
}

List<StoryElement> createChildren(List<Map<String, dynamic>> rawChildren, TextAlign align) {
  return rawChildren.map((rawChild) => _createChild(rawChild, align)).toList();
}

String createStoryConfigKeyForFileName(String storyFileName) {
  return '${storyFileName}_config';
}

Future<Map<String, StoryMetaData>> _loadMetadata = rootBundle.loadString('assets/stories/meta.json').then((metadataAsString) async {
  Map json = jsonDecode(metadataAsString);
  Map rawMetaDataForStoryFileName = json['metaDataForStoryFileName'];
  Iterable<String> storyFileNames = rawMetaDataForStoryFileName.keys;
  Map<String, StoryMetaData> metaDataForFileName = Map();

  for (var storyFileName in storyFileNames) {
    var rawStoryMetaData = rawMetaDataForStoryFileName[storyFileName];
    var storyMetaData = StoryMetaData(
      title: rawStoryMetaData['title'],
      order: rawStoryMetaData['order'],
      year: rawStoryMetaData['published'],
      description: rawStoryMetaData['description'],
      imageSourceUri: rawStoryMetaData['imageSourceUri'],
      imageAuthorName: rawStoryMetaData['imageAuthor'],
      imageAssetName: rawStoryMetaData['image'],
      authorship: rawStoryMetaData['authorship'],
      fileName: storyFileName,
    );

    metaDataForFileName[storyFileName] = storyMetaData;
  }

  return metaDataForFileName;
});

final _recentStoriesChangedStreamController = StreamController<List<StoryMetaData>>();
final recentStoriesChangedStream = _recentStoriesChangedStreamController.stream.asBroadcastStream();

void setStoryConfig(StoryMetaData metadata, StoryConfig config) {
  var storyConfigMap = Map<String, dynamic>();
  storyConfigMap[SCROLL_POSITION_KEY] = config.scrollPosition;

  database.setValueForKey(createStoryConfigKeyForFileName(metadata.fileName), storyConfigMap);
}

void markStoryViewed(StoryMetaData metadata) async {
  List<String> recentStoryFileNames = List<String>.from(database.getValueForKey(RECENT_DB_KEY) ?? List());
  recentStoryFileNames.insert(0, metadata.fileName);

  for (int i = 1; i < recentStoryFileNames.length; ++i) {
    if (recentStoryFileNames[i] == metadata.fileName) {
      recentStoryFileNames.removeAt(i);
      break;
    }
  }

  if (recentStoryFileNames.length > 10) {
    recentStoryFileNames.removeLast();
  }

  database.setValueForKey(RECENT_DB_KEY, recentStoryFileNames);
  _recentStoriesChangedStreamController.add(await getRecentMetadata());
}

Future<List<StoryMetaData>> getRecentMetadata() async {
  List<String> recentStoryFileNames = List<String>.from(await database.getValueForKey(RECENT_DB_KEY) ?? []);
  if (recentStoryFileNames == null) {
    return null;
  }

  var metaDataForFileName = await _loadMetadata;
  return recentStoryFileNames.map((f) => metaDataForFileName[f]).toList();
}

Future<List<StoryMetaData>> getMetadata() async {
  var metaDataForFileName = await _loadMetadata;
  var list = metaDataForFileName.values.toList();
  list.sort((a, b) => a.order - b.order);
  return list;
}

Future<Story> getStory(StoryMetaData metadata) async {
  var storyConfigRaw = database.getValueForKey(createStoryConfigKeyForFileName(metadata.fileName));
  var jsonText = await rootBundle.loadString('assets/stories/${metadata.fileName}');

  StoryConfig config;
  if (storyConfigRaw == null) {
    config = StoryConfig(scrollPosition: 0);
  } else {
    config = StoryConfig(scrollPosition: storyConfigRaw[SCROLL_POSITION_KEY]);
  }

  var json = jsonDecode(jsonText);

  return Story(
    metadata: metadata,
    config: config,
    body: createChildren(List<Map<String, dynamic>>.from(json['body']), TextAlign.justify),
  );
}
