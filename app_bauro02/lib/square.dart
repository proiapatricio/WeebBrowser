import 'package:app_weeb_browser/data%20model/manga.dart';
import 'package:flutter/material.dart';

class MySquare extends StatelessWidget {
  final Manga manga;
  final void Function(Manga) onDelete;
  final void Function(Manga) onUpdate;
  final void Function(Manga) onRefresh;
  final void Function(Manga) onPlay;

  const MySquare(
      {super.key,
      required this.manga,
      required this.onDelete,
      required this.onUpdate,
      required this.onRefresh,
      required this.onPlay});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: Colors.deepPurple[200],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _imagen(manga.image, width * 0.2),
            Expanded(
              //informacion del capitulo.
              child: Container(
                color: Colors.blue,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _text('Title: ${manga.title}'),
                    _text('Last read chapter: ${manga.lastReadChapter ?? ''}'),
                    _text('Latest chapter: ${manga.lastChapter ?? ''}'),
                    _text('Has new chapter: ${manga.hasNewChapter}'),
                    _text('Last checked on: ${manga.lastCheckedOn}',
                        fontsize: 10),
                  ],
                ),
              ),
            ),
            //iconos de opciones.
            Container(
              width: width * 0.1,
              //color: Colors.blue,
              child: Column(
                children: [
                  _icon(const Icon(Icons.delete), onDelete),
                  _icon(const Icon(Icons.update_sharp), onUpdate),
                  _icon(const Icon(Icons.refresh), onRefresh),
                  _icon(const Icon(Icons.play_circle), onPlay),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  _imagen(String url, double? columnSize) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
          minHeight: 100, maxHeight: 200, minWidth: 100, maxWidth: 200),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Image.network(
          url,
          width: columnSize,
        ),
      ),
    );
  }

  _text(String data, {double? width, double? fontsize = 20}) {
    return Container(
      width: width,
      //color: Colors.red,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
        child: Text(
          data,
          style: TextStyle(fontSize: fontsize, color: Colors.white),
        ),
      ),
    );
  }

  _icon(Icon myIcon, void Function(Manga) action) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
          onTap: () {
            action(manga);
          },
          child: InkWell(child: myIcon)),
    );
  }
}
