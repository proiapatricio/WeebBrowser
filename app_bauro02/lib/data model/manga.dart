import 'dart:convert';
import 'dart:ffi';

class Manga {
  String baseUrl;
  String urlRule;
  String image;
  String title;
  String lastReadVolume = '0';
  String? lastReadChapter;
  String? lastChapter;
  bool hasNewChapter = false;
  String? lastCheckedOn;
  String? nextChapterUrl;

  Manga(
      {required this.baseUrl,
      required this.urlRule,
      required this.title,
      required this.image});

  Manga.empty() : this(baseUrl: '', urlRule: '', title: '', image: '');

  Manga.full(
      {required this.baseUrl,
      required this.urlRule,
      required this.title,
      required this.image,
      required this.lastReadVolume,
      required this.lastReadChapter});

  Manga.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        baseUrl = json['baseUrl'],
        urlRule = json['urlRule'],
        image = json['image'],
        lastReadChapter = json['lastReadChapter'],
        lastReadVolume = json['lastReadVolume'],
        lastChapter = json['lastChapter'],
        hasNewChapter = json['hasNewChapter'],
        lastCheckedOn = json['lastCheckedOn'],
        nextChapterUrl = json['nextChapterUrl'];

  String mangaToString() {
    return jsonEncode(toJson());
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'baseUrl': baseUrl,
      'urlRule': urlRule,
      'image': image,
      'lastReadChapter': lastReadChapter,
      'lastReadVolume': lastReadVolume,
      'lastChapter': lastChapter,
      'hasNewChapter': hasNewChapter,
      'lastCheckedOn': lastCheckedOn,
      'nextChapterUrl': nextChapterUrl,
    };
  }

  bool hasVolumes() {
    return lastReadVolume != '';
  }
}
