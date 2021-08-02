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

import 'NavBar.dart';
import 'comic.dart';
class MyAppcommic extends StatelessWidget {
  FirebaseApp app;
  MyAppcommic({this.app});
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
      home: Comic_all(
        title: "Truyện Tranh",
        app: app,
      ),
    );
  }
}
class Comic_all extends StatefulWidget {

  Comic_all({Key key, this.title, this.app}) : super(key: key);
  final FirebaseApp app;
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Comic_all> {

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
          // drawer: Icon(Icons.arrow_back_ios_sharp),
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

                                  itemCount: listComicFromFirebase.length,
                                  padding: EdgeInsets.all(8),
                                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 250,
                                      childAspectRatio: 3 /4,
                                      crossAxisSpacing: 5,
                                      mainAxisSpacing: 10),

                                  itemBuilder: (context, index) {
                                    return  GestureDetector(
                                      onTap: () {
                                        print("length ${listComicFromFirebase[index].name}");
                                        context.read(comicSelected).state = listComicFromFirebase[index];
                                        Navigator.pushNamed(context, "/chapter");

                                        // Navigator.push(context, MaterialPageRoute(builder: (context) => ChapterScreen(comic),));
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(20),
                                        ),
                                        child: Card(
                                          elevation: 10,
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              Image.network(
                                                  listComicFromFirebase[index].image,
                                                  fit: BoxFit.cover,
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
                                      ),
                                    );
                                  },
                                ));
                          }
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }),

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
  void comic_all()
  {
    Navigator.push(context, MaterialPageRoute(builder: (context)=>Comic_all()),);
  }
}