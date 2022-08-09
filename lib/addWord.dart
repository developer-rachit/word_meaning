import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'main.dart';
import 'databaseHelper.dart';
import 'package:http/http.dart' as http;

class AddWord extends StatefulWidget {
  AddWord({Key? key}) : super(key: key);

  @override
  State<AddWord> createState() => _AddWordState();
}

class _AddWordState extends State<AddWord> {
  final String _url = "https://owlbot.info/api/v4/dictionary/";
  final String _token = "82a721ddd156a58683e45253eb3a99c0a8ca0a13";

  TextEditingController word = TextEditingController();

  late StreamController _streamController;
  late Stream _stream;

  late String meaning;

  late Timer _debounce;

  _search() async {
    if (word.text == null || word.text.isEmpty) {
      _streamController.add(null);
      return;
    }

    _streamController.add("waiting");
    Response response = await get(Uri.parse(_url + word.text.trim()),
        headers: {"Authorization": "Token " + _token});
    _streamController.add(json.decode(response.body));
  }

  @override
  void initState() {
    super.initState();

    _streamController = StreamController();
    _stream = _streamController.stream;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Word"),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  margin:
                      const EdgeInsets.only(left: 12.0, bottom: 8.0, top: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      hintText: "Search for a word",
                      contentPadding: EdgeInsets.only(left: 24.0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4.0))),
                    ),
                    onChanged: (String text) {
                      if (_debounce?.isActive ?? false) _debounce.cancel();
                      _debounce = Timer(const Duration(milliseconds: 1000), () {
                        _search();
                      });
                    },
                    controller: word,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.search,
                  color: Colors.blue,
                ),
                onPressed: () {
                  _search();
                },
              )
            ],
          ),
          Container(
            margin: const EdgeInsets.all(8.0),
            child: StreamBuilder(
              stream: _stream,
              builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                if (snapshot.data == null) {
                  return const Center(child: Text(""));
                }

                if (snapshot.data == "waiting") {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                meaning = snapshot.data["definitions"][0]["definition"];

                return Text(
                  snapshot.data["definitions"][0]["definition"],
                  style: TextStyle(
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
              onPressed: () async {
                await DatabaseHelper.instance.add(
                  Words(
                    word: word.text,
                    meaning: meaning,
                  ),
                );
              },
              child: Text('Add Word'))
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   child: const Icon(Icons.save),
      //   onPressed: () async {
      //     await DatabaseHelper.instance.add(
      //       Words(
      //         word: word.text,
      //         meaning: meaning,
      //       ),
      //     );
      //   },
      // ),
    );
  }
}
