import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Chat extends StatelessWidget {
  final String peerId;
  final String userId;
  Chat({Key key, @required this.peerId, @required this.userId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CHAT',
        ),
        centerTitle: true,
      ),
      body: ChatScreen(
        peerId: peerId,
        userId: userId,
      ),
    );
  }
}
class ChatScreen extends StatefulWidget {
  final String peerId;
  final String userId;
  ChatScreen({Key key, @required this.peerId, @required this.userId})
      : super(key: key);

  @override
  State createState() =>
      ChatScreenState(peerId: peerId,userId: userId);
}

class ChatScreenState extends State<ChatScreen> {
  final String peerId;
  final String userId;

  ChatScreenState({Key key, @required this.peerId, @required this.userId});

  TextEditingController messageController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            ChatMessageList(),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: messageController,
                        decoration: InputDecoration(
                            hintText: "Enter message...",
                            suffixIcon: new IconButton(icon: new Icon(
                                Icons.send), onPressed: sendMessage),
                            border: InputBorder.none),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  createChatRoom(String chatRoomId, chatRoomMap) {
    FirebaseFirestore.instance.collection("ChatRoom").doc(chatRoomId).set(
        chatRoomMap).catchError((e) {
      print(e.toString());
    });
  }

  createChatRoomAndStartConversation(String userId, String peerId) {
    String chatRoomId = getChatRoomId(userId, peerId);
    List<String> users = [userId, peerId];
    Map<String, dynamic> chatRoomMap = {
      "users": users,
      "chatRoomId": chatRoomId
    };
    createChatRoom(chatRoomId, chatRoomMap);
  }

  getChatRoomId(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    }
    else {
      return "$a\_$b";
    }
  }

  addConversationMessages(String chatRoomId, Map<String, dynamic> messageMap) {
    FirebaseFirestore.instance.collection("ChatRoom").doc(chatRoomId)
        .collection("chats").add(messageMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  sendMessage() {
    String chatRoomId = getChatRoomId(userId, peerId);
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> messageMap = {
        "message": messageController.text,
        "sendBy": userId,
        "time": DateTime
            .now()
            .millisecondsSinceEpoch
      };
      addConversationMessages(chatRoomId, messageMap);
      messageController.text = "";
    }
  }
  getConversationMessages(String chatRoomId) async{
    return await FirebaseFirestore.instance
        .collection('ChatRoom')
        .doc(chatRoomId)
        .collection('chats')
        .orderBy('time', descending: true);
  }
  Widget ChatMessageList() {
    var chatRoomId = getChatRoomId(userId, peerId);
    return StreamBuilder(
        stream: getConversationMessages(chatRoomId).snapshots,
        builder: (context, snapshot) {
          return snapshot.hasData ? ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) {
                return MessageTile(snapshot.data.doc[index].data["message"],
                    snapshot.data.doc[index].data["sendBy"] == userId);
              }
          ) : Container();
        });
  }
}

class MessageTile extends StatelessWidget{
  final String message;
  final bool isSendByMe;
  MessageTile(this.message, this.isSendByMe);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      alignment: isSendByMe?Alignment.centerRight:Alignment.centerLeft,
      child: Text(
          message,
          style: TextStyle(color: Colors.black,
              fontSize: 17
          )
      ),
    );

  }

}