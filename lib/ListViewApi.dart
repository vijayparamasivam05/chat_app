/*The data which is in the form of json fetched from the url is displayed as listview*/
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//import 'dart:async';

class Content {
  final int userId;
  final int id;
  final String title;
  final String body;


  Content({this.userId, this.id, this.title, this.body});

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
      body: json['body'],
    );
  }
}

class ListViewApi extends StatefulWidget{
  @override
  _ListViewApiState createState() => _ListViewApiState();
}

class _ListViewApiState extends State<ListViewApi> {
  List<Content> data = new List<Content>();
  List<Content> searchData = new List<Content>();

  @override
  void initState() {
    _getDetails().then((value) {
      setState(() {
        data.addAll(value);
        searchData = data;
      });
    });
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView.builder(
          itemBuilder: (context, index) {
            return index == 0 ? _searchBar() : _listItem(index-1);
          },
          itemCount: searchData.length+1,
        )
    );
  }

  Future<List<Content>>_getDetails() async {
    final url = 'https://jsonplaceholder.typicode.com/posts';
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((details) => new Content.fromJson(details)).toList();
    } else {
      throw Exception('Failed to load Details');
    }


  }
  _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
            hintText: 'Search...'
        ),
        onChanged: (text) {
          text = text.toLowerCase();
          setState(() {
            searchData = data.where((Content) {
              var title = Content.userId.toString();
              return title.contains(text);
            }).toList();
          });
        },
      ),
    );
  }

  _listItem(index) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.only(top: 32.0, bottom: 32.0, left: 16.0, right: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              searchData[index].userId.toString(),
              style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'OpenSans',
                  fontWeight: FontWeight.bold
              ),
            ),
            Text(
              searchData[index].title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontFamily: 'OpenSans',
              ),
            ),
          ],
        ),
      ),
    );
  }

}


