import 'dart:convert';

import 'package:app_weeb_browser/square.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data model/manga.dart';
import 'manga_modal.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  final List<Manga> _post = [];
  /*<Manga>[
    Manga(
        baseUrl: 'https://fanfox.net/',
        urlRule: 'https://fanfox.net/manga/naruto/',
        title: 'Naruto',
        image:
            'https://es.web.img2.acsta.net/pictures/13/12/13/08/50/378271.jpg'),
    Manga(
        baseUrl: 'https://fanfox.net/',
        urlRule: 'https://fanfox.net/manga/boku_no_hero_academia/',
        title: 'Boku no Hero',
        image:
            'https://pics.filmaffinity.com/Boku_no_Hero_Academia_Serie_de_TV-206305193-mmed.jpg'),
  ];*/

  @override
  void initState() {
    super.initState();

    loadMangasFromPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weeb Browser'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              onPushMangaForm();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
          itemCount: _post.length,
          itemBuilder: (context, index) {
            return MySquare(
              manga: _post[index],
              onDelete: onDelete,
              onUpdate: onUpdate,
              onRefresh: onRefresh,
              onPlay: onPlay,
            );
          }),
    );
  }

  void onDelete(Manga manga) {
    if (_post.contains(manga)) {
      setState(() {
        _post.remove(manga);
      });
    }
  }

  void onUpdate(Manga manga) {
    onPushMangaUpdate(manga);
  }

  void onRefresh(Manga manga) async {
    double nextChapter = double.parse(manga.lastReadChapter ?? '0') + 1;
    double nextVolume = 0;
    String chapterPath = '';
    String nextChapterUrl = '';
    DateTime checkDate = DateTime.now();

    chapterPath = getChapterPath(manga, nextChapter);

    nextChapterUrl = manga.baseUrl + chapterPath;

    bool nextChapterPageExist = await remotePageExists(nextChapterUrl);
    if (!nextChapterPageExist) {
      //Try with following chapter.
      chapterPath = manga.urlRule
          .replaceAll('{0}', nextVolume.toString())
          .replaceAll('{1}', nextChapter.toString());
    }

    nextChapterPageExist = await remotePageExists(nextChapterUrl);

    setState(() {
      if (nextChapterPageExist) {
        manga.lastChapter = nextChapter.toString();
      } else {
        manga.lastChapter = manga.lastReadChapter;
      }
      manga.hasNewChapter = nextChapterPageExist;
      manga.lastCheckedOn = checkDate.toString();
    });

    saveToPreferences();
  }

  void onPlay(Manga manga) {
    double nextChapter = double.parse(manga.lastReadChapter ?? '0');
    String lastChapterUrl = manga.baseUrl + getChapterPath(manga, nextChapter);
    _launchUrl(lastChapterUrl);
  }

  String getChapterPath(Manga manga, double nextChapter) {
    nextChapter = double.parse(manga.lastReadChapter ?? '0') + 1;
    double nextVolume = 0;
    String chapterPath = '';
    String nextChapterParsed = nextChapter.toString().replaceAll('.0', '');

    if (manga.hasVolumes()) {
      bool isVolumeNumeric = double.tryParse(manga.lastReadVolume) != null;
      if (isVolumeNumeric) {
        nextVolume = double.parse(manga.lastReadVolume) + 1;
      }
      chapterPath = manga.urlRule
          .replaceAll('{0}', manga.lastReadVolume)
          .replaceAll('{1}', nextChapterParsed);
    } else {
      chapterPath = manga.urlRule.replaceAll('{0}', nextChapterParsed);
    }

    print(nextChapterParsed);
    return chapterPath;
  }

  Future<bool> remotePageExists(String url) async {
    final response = await http.head(Uri.parse(url));

    return (response.statusCode == 200);
  }

  Future<void> _launchUrl(String url) async {
    Uri uri = Uri.parse(url);

    if (!await canLaunchUrl(uri)) {
      showDialog(
          context: context,
          builder: ((context) {
            return AlertDialog(
              title: const Text('Uri Error'),
              content: Text('Could not launch $uri'),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Ok'))
              ],
            );
          }));
    } else {
      launchUrl(uri);
    }
  }

  void onPushMangaUpdate(Manga manga) async {
    Manga? mangaResult = await Navigator.push(context,
        MaterialPageRoute(builder: ((context) => MangaForm.fromManga(manga))));

    if (mangaResult != null) {
      reflectChanges(mangaResult);
    }
  }

  void onPushMangaForm() async {
    Manga? mangaResult = await Navigator.push(
        context, MaterialPageRoute(builder: ((context) => MangaForm())));

    if (mangaResult != null) {
      reflectChanges(mangaResult);
    }
  }

  void reflectChanges(Manga mangaResult) async {
    setState(() {
      if (!_post.contains(mangaResult)) {
        _post.add(mangaResult);
      }
    });

    saveToPreferences();
  }

  void loadMangasFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    if (_post.isNotEmpty) {
      saveToPreferences();

      return;
    }

    List<String> mangaFromPreferences = prefs.getStringList('mangas') ?? [];
    for (String jsonString in mangaFromPreferences) {
      _post.add(Manga.fromJson(jsonDecode(jsonString)));
    }

    setState(() {});
  }

  void saveToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> mangaToPreferences = [];

    for (Manga data in _post) {
      mangaToPreferences.add(data.mangaToString());
    }
    prefs.setStringList('mangas', mangaToPreferences);
  }
}
