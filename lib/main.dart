import 'package:flutter/material.dart';
import 'databaseHelper.dart';
import 'addWord.dart';

main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Favourite Words',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Favourite Words!'),
      ),
      body: FutureBuilder<List<Words>>(
          future: DatabaseHelper.instance.getWords(),
          builder: (BuildContext context, AsyncSnapshot<List<Words>> snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: Text('Loading...'),
              );
            }
            return snapshot.data!.isEmpty
                ? const Center(child: Text('No Words in List.'))
                : ListView(
                    children: snapshot.data!.map((words) {
                      return Padding(
                        padding:
                            const EdgeInsets.only(top: 20, left: 20, right: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              color: Colors.blue,
                              padding: EdgeInsets.all(10),
                              child: Text(
                                words.meaning,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              color: Color.fromARGB(255, 116, 189, 248),
                              padding: EdgeInsets.all(10),
                              child: Text(
                                words.word,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
          }),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddWord()));
        },
      ),
    );
  }
}

class Words {
  final int? id;
  final String word;
  final String meaning;

  Words({this.id, required this.word, required this.meaning});

  factory Words.fromMap(Map<String, dynamic> json) => Words(
        id: json['id'],
        word: json['word'],
        meaning: json['meaning'],
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'meaning': meaning,
    };
  }
}
