import 'package:flutter/material.dart';
import './models/story_meta.dart';
import './drawer.dart';
import './story_manager.dart' as StoryManager;
import './routes.dart';
import './story_view.dart';

bool loading = false;

class _StoryCard extends StatelessWidget {
  final StoryMetaData _metadata;

  _StoryCard(this._metadata);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Hero(
              tag: _metadata.imageAssetName,
              child: SizedBox(
                width: 80,
                child: ClipRect(
                  child: OverflowBox(
                    minHeight: 0,
                    minWidth: 0,
                    maxWidth: double.infinity,
                    child: Image.asset('assets/story_images/${_metadata.imageAssetName}'),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListTile(
                title: Container(
                  child: Text(_metadata.title.toUpperCase()),
                  padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                ),
                subtitle: Container(
                  child: Text(_metadata.description),
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget createStoriesScrollView(List<StoryMetaData> metadatas) {
  return Scrollbar(
    child: ListView.builder(
      padding: EdgeInsets.only(top: 5),
      itemCount: metadatas.length,
      itemBuilder: (context, index) {
        var metadata = metadatas[index];
        return Container(
          padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
          child: InkWell(
            onTap: () async {
              if (loading) {
                return;
              }
              loading = true;
              try {
                var story = await StoryManager.getStory(metadata);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => StoryView(story))
                );
                
                StoryManager.markStoryViewed(metadata);
              } finally {
                loading = false;
              }
            },
            child: _StoryCard(metadata),
          ),
        );
      },
    ),
  );
}

List<StoryMetaData> search(String query, List<StoryMetaData> allMeta) {
  query = query.toLowerCase();

  var hasInTitle = allMeta.where((meta) => meta.title.toLowerCase().contains(query));
  var hasOnlyInDesc = allMeta.where((meta) => !meta.title.toLowerCase().contains(query) && meta.description.toLowerCase().contains(query));
  var results = hasInTitle.followedBy(hasOnlyInDesc).toList();

  results.sort((a, b) {
    var aTitleIndex = a.title.toLowerCase().indexOf(query);
    var bTitleIndex = b.title.toLowerCase().indexOf(query);

    if (aTitleIndex == -1 && bTitleIndex == -1) {
      return 0;
    }

    if (aTitleIndex == -1) {
      return 1;
    }

    if (bTitleIndex == -1) {
      return -1;
    }

    return aTitleIndex - bTitleIndex;
  });

  return results;
}

class StorySearchDelegate extends SearchDelegate<StoryMetaData> {
  final List<StoryMetaData> _storyData;

  StorySearchDelegate(this._storyData);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.close),
        tooltip: 'Close',
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    ];
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context);
  }

  @override
  Widget buildLeading(BuildContext context) {
    return const Icon(Icons.search);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    var searchResults = search(query, _storyData);
    return createStoriesScrollView(searchResults);
  }

  @override
  Widget buildResults(BuildContext context) {
    var searchResults = search(query, _storyData);
    return createStoriesScrollView(searchResults);
  }

  @override
  String get query => super.query ?? '';
}

class StoryPage extends StatefulWidget {
  StoryPage({Key key}) : super(key: key);

  @override
  _StoryPageState createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> with SingleTickerProviderStateMixin {
  final List<StoryMetaData> _storyMetadata = [];
  final List<StoryMetaData> _recentStoryMetadata = [];

  TabController _tabController;

  _StoryPageState() {
    _tabController = TabController(vsync: this, length: 2);

    StoryManager.getMetadata().then(_updateAvailableStories);
    StoryManager.getRecentMetadata().then(_updateRecentStories);

    StoryManager.recentStoriesChangedStream.listen(_updateRecentStories);
  }

  void _updateRecentStories(List<StoryMetaData> newStories) async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _recentStoryMetadata.clear();
      _recentStoryMetadata.addAll(newStories);
    });
  }

  void _updateAvailableStories(List<StoryMetaData> newStories) {
    setState(() {
      _storyMetadata.clear();
      _storyMetadata.addAll(newStories);
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      drawer: AppDrawer(Routes.Stories),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.search),
                  tooltip: 'Search',
                  onPressed: () {
                    showSearch(context: context, delegate: StorySearchDelegate(_storyMetadata));
                  },
                ),
              ],
              title: Text('Library'),
              floating: true,
              pinned: false,
              snap: true,
              forceElevated: innerBoxIsScrolled,
              bottom: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: 'All'),
                  Tab(text: 'Recent'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            createStoriesScrollView(_storyMetadata),
            _recentStoryMetadata.length == 0
              ? Center(child: Text('You have not viewed any stories yet.'))
              : createStoriesScrollView(_recentStoryMetadata),
          ],
        ),
      ),
    );
  }
}
