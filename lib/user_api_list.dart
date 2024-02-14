import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';


class MyApiPage extends StatefulWidget {
    @override
    _MyApiPageState createState() => new _MyApiPageState();
    }
class _MyApiPageState extends State<MyApiPage>{
    Future<List<User>> _getUsers() async {
        var data = await http.get("https://jsonplaceholder.typicode.com/posts");
        var jsonData = json.decode(data.body);
        List<User> users =[];
        for(var u in jsonData){
            User user = User(u["userId"],u["id"],u["title"],u["body"]);
            users.add(user);
        }
        print(users.length);
        return users;

    }
  @override
  Widget build(BuildContext context) {
    return  Container(  
            child: FutureBuilder(
                future: _getUsers(),
                builder: (BuildContext context, AsyncSnapshot snapshot){
            
                        if(snapshot.data == null){
                            return Container(
                                child: Center(
                                    child:Text("Loading...."),
                                )//Center
                            );// Container
                        }//if
                        else{
                        return ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index){
                            return ListTile(
                                title: Text(snapshot.data[index].title),
                                subtitle: Text(snapshot.data[index].body),
                            );
                        },
                        );
                        }
                },//builder
            ),//child:Futurebuilder
    );//Container
}}

class User{
    final int userId;
    final String title;
    final int id;
    final String body;
    User(this.userId, this.id, this.title, this.body);
}
