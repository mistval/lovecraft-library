import 'package:flutter/foundation.dart';

class StoryMetaData {
  final String authorship;
  final String title;
  final String description;
  final String year;
  final String fileName;
  final String imageAuthorName;
  final String imageSourceUri;
  final String imageAssetName;
  final int order;

  StoryMetaData({
    @required this.title,
    @required this.description,
    @required this.year,
    @required this.fileName,
    @required this.order,
    @required this.imageAuthorName,
    @required this.imageSourceUri,
    @required this.imageAssetName,
    @required this.authorship,
  });
}
