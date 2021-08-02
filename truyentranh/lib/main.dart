import 'dart:convert';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:truyentranh/State_manager.dart';
import 'package:truyentranh/chapter_screen.dart';
import 'package:truyentranh/read_screen.dart';

import 'Comic_all.dart';
import 'NavBar.dart';
import 'comic.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // final FirebaseApp app = await Firebase.initializeApp(
  //     name: "comic_reader_flutter",
  //     options: Platform.isMacOS || Platform.isIOS
  //         ? FirebaseOptions(
  //             appId: 'IOS KEY',
  //             apiKey: 'AIzaSyAn_r2z7T__0uynYt-KsSbIxKJFTFAkagg',
  //             projectId: 'cncapp-35dcf',
  //             measurementId: '1066336886372',
  //             databaseURL: 'https://cncapp-35dcf-default-rtdb.firebaseio.com/',
  //           )
  //         : FirebaseOptions(
  //             appId: '1:1066336886372:android:9f7686217d009be7724971',
  //             apiKey: 'AIzaSyAn_r2z7T__0uynYt-KsSbIxKJFTFAkagg',
  //             projectId: 'cncapp-35dcf',
  //             measurementId: '1066336886372',
  //             databaseURL: 'https://cncapp-35dcf-default-rtdb.firebaseio.com/',
  //           ));
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  FirebaseApp app;
  MyApp({this.app});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Comic_flutter',
      routes: {
        '/chapter': (context) => ChapterScreen(),
        '/read': (context) => ReadScreen(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(
        title: "Truyện Tranh",
        app: app,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.app}) : super(key: key);
  final FirebaseApp app;
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DatabaseReference _bannnerRef, _comicRef;
  List<Comic> listComicFromFirebase = new List<Comic>();
  @override
  void initState() {
    super.initState();
    final FirebaseDatabase _database = FirebaseDatabase(app: widget.app);
    _bannnerRef = _database.reference().child('Banners');
    _comicRef = _database.reference().child('Comic');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, _) {
      var searchEnable = watch(isSearch).state;
      return Scaffold(
          drawer: NavBar(),
          appBar: AppBar(
            backgroundColor: Colors.lightBlue,
            title: searchEnable
                ? Container(
                    height: 40,
                    child: TypeAheadField(
                        textFieldConfiguration: TextFieldConfiguration(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              hintText: 'Tên truyện',
                              helperStyle: TextStyle(color: Colors.white60)),
                          autofocus: false,
                          style: DefaultTextStyle.of(context).style.copyWith(
                              fontStyle: FontStyle.italic,
                              fontSize: 14,
                              color: Colors.black),
                        ),
                        suggestionsCallback: (seachString) async {
                          return await saerchComic(seachString);
                        },
                        itemBuilder: (context, comic) {
                          return ListTile(
                            leading: Image.network(comic.image),
                            title: Text('${comic.name}'),
                            subtitle: Text(
                                '${comic.category == null ? '' : comic.category}'),
                          );
                        },
                        onSuggestionSelected: (comic) {
                          context.read(comicSelected).state = comic;
                          Navigator.pushNamed(context, '/chapter');
                        }),
                  )
                : Text(
                    widget.title,
                    style: TextStyle(color: Colors.white),
                  ),
            actions: [
              IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => context.read(isSearch).state =
                      !context.read(isSearch).state),
            ],
          ),
          body: FutureBuilder<List<String>>(
            future: getBanners(_bannnerRef),
            builder: (context, snapshot) {
              if (snapshot.hasData)
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CarouselSlider(
                        items: snapshot.data
                            .map((e) => Builder(
                                  builder: (context) {
                                    return Image.network(e, fit: BoxFit.cover);
                                  },
                                ))
                            .toList(),
                        options: CarouselOptions(
                            autoPlay: true,
                            enlargeCenterPage: true,
                            viewportFraction: 1,
                            initialPage: 0,
                            height: MediaQuery.of(context).size.height /2.9)),
                    Row(
                      children: [
                        Expanded(
                            child: Container(
                          color: Colors.orange,
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              'Truyện Mới',
                              style: TextStyle(
                                color: Colors.white,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        )),
                        Expanded(
                          flex: 1,
                          child: Container(
                            color: Colors.black,
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(''),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    InkWell(
                        onTap: comic_all,
                        child: Text(
                          "Comic All",
                          style: TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: Colors.lightBlueAccent,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w500),
                        )),
                    SizedBox(
                      height: 2,
                    ),
                    FutureBuilder(
                        future: getComic(_comicRef),
                        builder: (context, snapshot) {
                          if (snapshot.hasError)
                            return Center(
                              child: Text('${snapshot.error}'),
                            );
                          else if (snapshot.hasData) {
                            listComicFromFirebase = new List<Comic>();
                            snapshot.data.forEach((item) {
                              var comic = Comic.fromJson(
                                  json.decode(json.encode(item)));
                              listComicFromFirebase.add(comic);
                            });

                            return Expanded(
                                child: GridView.builder(
                              itemCount: 8,
                              padding: EdgeInsets.all(8),
                              gridDelegate:
                                  SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 200,
                                      childAspectRatio: 3 / 3,
                                      crossAxisSpacing: 5,
                                      mainAxisSpacing: 5),
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    print(
                                        "length ${listComicFromFirebase[index].name}");
                                    context.read(comicSelected).state =
                                        listComicFromFirebase[index];
                                    Navigator.pushNamed(context, "/chapter");

                                    // Navigator.push(context, MaterialPageRoute(builder: (context) => ChapterScreen(comic),));
                                  },
                                  child: Card(
                                    elevation: 10,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Image.network(
                                            listComicFromFirebase[index].image,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Container(
                                              color: Color(0xAA434343),
                                              padding: EdgeInsets.all(8),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    '${listComicFromFirebase[index].name}',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ));
                          }
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 2,
                    ),
                  ],
                );
              else if (snapshot.hasError)
                return Center(
                  child: Text('${snapshot.error}'),
                );
              return Center(
                child: CircularProgressIndicator(),
              );
            },
          ));
    });
  }

  Future<List<dynamic>> getComic(DatabaseReference comicRef) {
    return comicRef.once().then((snapshot) => snapshot.value);
  }

  Future<List<String>> getBanners(DatabaseReference bannerRef) {
    return bannerRef
        .once()
        .then((snapshot) => snapshot.value.cast<String>().toList());
  }

  Future<List<Comic>> saerchComic(String seachString) async {
    return listComicFromFirebase
        .where((comic) =>
            comic.name.toLowerCase().contains(seachString.toLowerCase()) ||
            (comic.category != null &&
                comic.category
                    .toLowerCase()
                    .contains(seachString.toLowerCase())))
        .toList();
  }

  void comic_all() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyAppcommic()),
    );
  }
}
