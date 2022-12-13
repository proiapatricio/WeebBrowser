import 'package:flutter/material.dart';

import 'data model/manga.dart';

class MangaForm extends StatefulWidget {
  Manga? localData;

  MangaForm({super.key});
  MangaForm.fromManga(this.localData, {super.key});

  @override
  MangaFormState createState() {
    return MangaFormState();
  }
}

class MangaFormState extends State<MangaForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  Manga? manga;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleEC = TextEditingController();
  final TextEditingController baseURLEC = TextEditingController();
  final TextEditingController volumeEC = TextEditingController();
  final TextEditingController chapterEC = TextEditingController();
  final TextEditingController ruleEC = TextEditingController();
  final TextEditingController imageEC = TextEditingController();

  @override
  void initState() {
    super.initState();
    manga = widget.localData;

    if (manga != null) {
      final Manga m = manga!;

      titleEC.text = m.title;
      baseURLEC.text = m.baseUrl;
      volumeEC.text = m.lastReadVolume;
      chapterEC.text = m.lastReadChapter ?? '';
      ruleEC.text = m.urlRule;
      imageEC.text = m.image;
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    titleEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Title'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _formField(titleEC, 'Title'),
              _formField(baseURLEC, 'Base URL'),
              _formField(volumeEC, 'Volume', validate: false),
              _formField(chapterEC, 'Chapter'),
              _formField(ruleEC, 'Chapter progression Rule'),
              _formField(imageEC, 'Manga image url'),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Validate returns true if the form is valid, or false otherwise.
                    if (_formKey.currentState!.validate()) {
                      // If the form is valid, display a snackbar. In the real world,
                      // you'd often call a server or save the information in a database.
                      manga ??= Manga.empty();

                      manga?.title = titleEC.text;
                      manga?.baseUrl = baseURLEC.text;
                      manga?.urlRule = ruleEC.text;
                      manga?.image = imageEC.text;
                      manga?.lastReadChapter = chapterEC.text;
                      manga?.lastReadVolume = volumeEC.text;

                      Navigator.pop(context, manga);
                    }
                  },
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _formField(TextEditingController controller, String placeholderText,
      {bool validate = true}) {
    return TextFormField(
      controller: controller,
      // The validator receives the text that the user has entered.
      decoration: InputDecoration(hintText: placeholderText),
      validator: (value) {
        if (validate && (value == null || value.isEmpty)) {
          return 'Please enter some text';
        }
        return null;
      },
    );
  }
}
