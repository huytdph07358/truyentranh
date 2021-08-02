import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'main.dart';

class NavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              'Oflutter.com',
              style: TextStyle(color: Colors.purple),
            ),
            accountEmail: Text(
              'Trandinhhuy980@gmail.com',
              style: TextStyle(color: Colors.black,fontWeight: FontWeight.w700,fontSize: 18),
            ),
            decoration: BoxDecoration(
              color: Colors.pinkAccent,
              image: DecorationImage(
                  fit: BoxFit.fill,
                  image: NetworkImage('https://vnw-img-cdn.popsww.com/api/v2/containers/file2/cms_topic/doraemons9_02_sbsmarttv-e73982260c40-1609395345843-63UWkTZR.png?v=0')),
            ),
          ),

          ListTile(
            leading: Icon(Icons.star, color: Colors.yellow,size: 30,),
            title: Text('Đánh giá'),
            onTap: () => null,
          ),
          ListTile(
            leading: Icon(
              Icons.search,
              color: Colors.blue,size: 30,
            ),
            title: Text('Danh sách app hay'),
              onTap: () async {
                if (await canLaunch("https://play.google.com/store/apps")) {
                  await launch("https://play.google.com/store/apps");
                }
              }
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.attach_email_rounded, color: Colors.purple,size: 30,),
            title: Text('Góp ý'),
            onTap: () => launch('https://docs.google.com/forms/d/e/1FAIpQLScqGwrTwWzG5eHGJRnMiCvQx6_Bv8HUN-V1kq-XXatvt55SGg/viewform'),
          ),
          SizedBox(height: 20,),
          ListTile(
            leading: Icon(Icons.exit_to_app, color: Colors.red,size: 30,),
            title: Text('Exit'),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Thoát'),
                    content: Text('Bạn có đồng ý thoát'),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("No"),
                        onPressed: () => Navigator.pop(context),
                      ),
                      FlatButton(
                        child: Text("Yes"),
                        onPressed: () => exit(1),
                      ),
                    ],
                  ));
            },
          ),
        ],
      ),
    );
  }
}
