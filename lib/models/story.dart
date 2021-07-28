import './story_meta.dart';
import './../story_element.dart';
import './story_config.dart';
import 'package:flutter/foundation.dart';

class Story {
  final StoryMetaData metadata;
  final StoryConfig config;
  final List<StoryElement> body;

  Story({ @required this.body, @required this.metadata, @required this.config });
}
