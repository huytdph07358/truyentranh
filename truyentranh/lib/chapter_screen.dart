import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truyentranh/State_manager.dart';

class ChapterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Consumer(builder: (context, watch, _) {
      var comic = watch(comicSelected).state;
      return Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xFFF44A3E),
            title:  Text(
                '${comic.name.toUpperCase()}',
                style: TextStyle(color: Colors.white),
            ),
          ),
          body: comic.chapters.length != null && comic.chapters.length > 0
              ? Padding(
                  padding: EdgeInsets.all(8),
                  child: ListView.builder(
                    itemCount: comic.chapters.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          context.read(chapterSelected).state=comic.chapters[index];
                          Navigator.pushNamed(context, '/read');
                        },
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ListTile(
                                title: Text('${comic.chapters[index].name}'),
                              ),
                            ),

                           SizedBox(height: 10,),
                          ],
                        ),
                      );
                    },
                  ),
                )
              : Center(
                  child: Text("this comic"),
                ));
    });
  }
}
