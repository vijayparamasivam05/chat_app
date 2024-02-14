import 'dart:async';
import 'dart:io';
import 'package:bubble/bubble.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/const.dart';
import 'package:chat_app/widget/full_photo.dart';
import 'package:chat_app/widget/loading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';

import 'api/messaging.dart';
import 'first_screen.dart';
import 'other_user_profile.dart';

class Chat extends StatelessWidget {
  final String peerId;
  final String peerAvatar;
  final String peerName;
  final String peerAboutMe;
  final String peerDeviceToken;

  Chat({Key key, @required this.peerId, @required this.peerAvatar, @required this.peerName,@required this.peerAboutMe,@required this.peerDeviceToken})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChatScreen(
      peerId: peerId,
      peerAvatar: peerAvatar,
      peerName: peerName,
      peerAboutMe:peerAboutMe,
      peerDeviceToken:peerDeviceToken,
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String peerId;
  final String peerAvatar;
  final String peerName;
  final String peerAboutMe;
  final String peerDeviceToken;
  ChatScreen({Key key, @required this.peerId, @required this.peerAvatar, @required this.peerName, @required this.peerAboutMe,@required this.peerDeviceToken})
      : super(key: key);

  @override
  State createState() =>
      ChatScreenState(peerId: peerId, peerAvatar: peerAvatar,peerName: peerName, peerAboutMe:peerAboutMe,peerDeviceToken:peerDeviceToken);
}

class ChatScreenState extends State<ChatScreen> {
  ChatScreenState({Key key, @required this.peerId, @required this.peerAvatar,@required this.peerName, @required this.peerAboutMe,@required this.peerDeviceToken});

  String peerId;
  String peerAvatar;
  String peerName;
  String peerAboutMe;
  String peerDeviceToken;
  String id;
  String name;
  int flag=0;
  List<QueryDocumentSnapshot> listMessage = new List.from([]);
  int _limit = 20;
  final int _limitIncrement = 20;
  String groupChatId;
  SharedPreferences prefs;

  File imageFile;
  bool isLoading;
  String imageUrl;

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  _scrollListener() {
    if (listScrollController.offset >=
        listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      print("reach the bottom");
      setState(() {
        print("reach the bottom");
        _limit += _limitIncrement;
      });
    }
    if (listScrollController.offset <=
        listScrollController.position.minScrollExtent &&
        !listScrollController.position.outOfRange) {
      print("reach the top");
      setState(() {
        print("reach the top");
      });
    }
  }

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    listScrollController.addListener(_scrollListener);
    groupChatId = '';
    isLoading = false;
    imageUrl = '';
    readLocal();
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    print("BACK BUTTON!"); // Do some stuff.
    FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .update({'chattingWith': null});
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return FirstScreen(userId:id);
        },
      ),
    );// Do some stuff.
    return true;
  }

  int calculateDifference(DateTime date) {
    DateTime now = DateTime.now();
    return DateTime(date.year, date.month, date.day).difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  readLocal() async {
    prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id') ?? '';
    name=prefs.getString('nickname') ?? '';
    if (id.hashCode <= peerId.hashCode) {
      groupChatId = '$id-$peerId';
    } else {
      groupChatId = '$peerId-$id';
    }

    FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .update({'chattingWith': peerId});
    setState(() {});
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;

    pickedFile = await imagePicker.getImage(source: ImageSource.gallery);
    imageFile = File(pickedFile.path);

    if (imageFile != null) {
      setState(() {
        isLoading = true;
      });
      uploadFile(1);
    }
  }

  Future getVideo() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;

    pickedFile = await imagePicker.getVideo(source: ImageSource.gallery);
    imageFile = File(pickedFile.path);
    print("After picked file $imageFile");
    if (imageFile != null) {
      setState(() {
        isLoading = true;
      });
      uploadFile(2);
    }
  }

  Future uploadFile(int type) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, type);
      });
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'This file is not an image');
    });
  }

  Future<void> onSendMessage(String content, int type) async {
    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      textEditingController.clear();

      var documentReference = FirebaseFirestore.instance
          .collection('messages')
          .doc(groupChatId)
          .collection(groupChatId)
          .doc(DateTime.now().millisecondsSinceEpoch.toString());

      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(
          documentReference,
          {
            'idFrom': id,
            'idTo': peerId,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'type': type
          },
        );
      });
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      print("title: $name body: $content fcmToken $peerDeviceToken");
      final response = await Messaging.sendTo(
        title: name,
        body:
        type == 0?
        content:'image',
        fcmToken: peerDeviceToken,
        id: id,
      );

      if (response.statusCode != 200) {
        print('[${response.statusCode}] Error message: ${response.body}');
      }
    } else {
      Fluttertoast.showToast(
          msg: 'Nothing to send',
          backgroundColor: Colors.white54,
          textColor: Colors.black);
    }
  }

  Widget buildDay(int index, DocumentSnapshot document, DocumentSnapshot document1)  {
    String cd =  DateFormat('dd MMMM yyyy').format(DateTime.fromMillisecondsSinceEpoch(int.parse(document.data()['timestamp'])));
    String whichDay = DateFormat('dd MMMM yyyy').format(DateTime.fromMillisecondsSinceEpoch(int.parse(document1.data()['timestamp'])));
    if(whichDay == cd){
      return Container(
        child:buildItem(index, document),
      );
    }
    else {
      return Column(
        children: <Widget>[
           Container(
              padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
              margin: EdgeInsets.only(
                  top: 10.0, bottom: 5.0, left: 0.0, right: 0.0),
              decoration: BoxDecoration(
                color: greyColor2,
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
              ),
              child: Text(cd)
          ),
          Container(
            child: buildItem(index, document),
          )
        ],
      );
    }
  }

  Widget buildDay1(int index, DocumentSnapshot document)  {
    String cd =  DateFormat('dd MMMM yyyy').format(DateTime.fromMillisecondsSinceEpoch(int.parse(document.data()['timestamp'])));
      return Column(
        children: <Widget>[
          Container(
              padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
              margin: EdgeInsets.only(
                  top: 10.0, bottom: 5.0, left: 0.0, right: 0.0),
              decoration: BoxDecoration(
                color: greyColor2,
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
              ),
              child: Text(cd)
          ),
          Container(
            child: buildItem(index, document),
          )
        ],
      );
  }

  Widget buildItem(int index, DocumentSnapshot document) {

    double pixelRatio = MediaQuery.of(context).devicePixelRatio;
    double px = 1 / pixelRatio;

    BubbleStyle styleSomebody = BubbleStyle(
      nip: BubbleNip.leftTop,
      color: Colors.white,
      elevation: 1 * px,
      margin: BubbleEdges.only(top: 3.0, right: 50.0),
      alignment: Alignment.topLeft,
    );
    BubbleStyle styleMe = BubbleStyle(
      nip: BubbleNip.rightTop,
      color: Color.fromARGB(255, 225, 255, 199),
      elevation: 1 * px,
      margin: BubbleEdges.only(top: 3.0, left: 50.0),
      alignment: Alignment.topRight,
    );

    if (document.data()['idFrom'] == id) {
      // Right (my message)
      return Row(
        children: <Widget>[
          document.data()['type'] == 0
          // Text
              ? Flexible(
            child: FlatButton(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        child: Text(
                          DateFormat('hh:mm a').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  int.parse(document.data()['timestamp']))),
                          style: TextStyle(
                              fontSize: 13, color: Colors.black.withOpacity(0.8)),
                        ),
                      ),
                      Container(
                          child:Bubble(
                            style: styleMe,
                            child:Text(
                              document.data()['content'],
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                            ),
                          ))
                    ]),
                onLongPress: () {deleteBuild(context,document.id);}
            ),
          )
              : Container(
              child: FlatButton(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        child: Text(
                          DateFormat('hh:mm a').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  int.parse(document.data()['timestamp']))),
                          style: TextStyle(
                              fontSize: 13, color: Colors.black.withOpacity(0.8)),
                        ),
                      ),
                      Container(
                        child: FlatButton(
                          child: Material(
                            child: CachedNetworkImage(
                              placeholder: (context, url) => Container(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      themeColor),
                                ),
                                width: 200.0,
                                height: 200.0,
                                padding: EdgeInsets.all(70.0),
                                decoration: BoxDecoration(
                                  color: greyColor2,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  Material(
                                    child: Image.asset(
                                      'images/img_not_available.jpeg',
                                      width: 200.0,
                                      height: 200.0,
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                  ),
                              imageUrl: document.data()['content'],
                              width: 200.0,
                              height: 200.0,
                              fit: BoxFit.cover,
                            ),
                            borderRadius:
                            BorderRadius.all(Radius.circular(8.0)),
                            clipBehavior: Clip.hardEdge,
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FullPhoto(
                                        url: document.data()['content'])));
                          },
                          padding: EdgeInsets.all(0),
                        ),
                        margin: EdgeInsets.only(left: 10.0),
                      )],
                  ),
                  onLongPress: () {deleteBuild(context,document.id);}
              )),
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      // Left (peer message)
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                document.data()['type'] == 0
                    ? Flexible(
                    child: FlatButton(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                child: Text(
                                  DateFormat('hh:mm a').format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                          int.parse(document.data()['timestamp']))),
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.black.withOpacity(0.8)),
                                ),
                              ),
                              Container(
                                  child:Bubble(
                                    style: styleSomebody,
                                    child:Text(
                                      document.data()['content'],
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                                    ),
                                  ))
                            ]),
                        onLongPress: () {deleteBuild(context,document.id);}
                    )
                )
                    : Container(
                    child: FlatButton(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              child: Text(
                                DateFormat('hh:mm a').format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        int.parse(document.data()['timestamp']))),
                                style: TextStyle(
                                    fontSize: 13, color: Colors.black.withOpacity(0.8)),
                              ),
                            ),
                            Container(
                              child: FlatButton(
                                child: Material(
                                  child: CachedNetworkImage(
                                    placeholder: (context, url) => Container(
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                            themeColor),
                                      ),
                                      width: 200.0,
                                      height: 200.0,
                                      padding: EdgeInsets.all(70.0),
                                      decoration: BoxDecoration(
                                        color: greyColor2,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8.0),
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Material(
                                          child: Image.asset(
                                            'images/img_not_available.jpeg',
                                            width: 200.0,
                                            height: 200.0,
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8.0),
                                          ),
                                          clipBehavior: Clip.hardEdge,
                                        ),
                                    imageUrl: document.data()['content'],
                                    width: 200.0,
                                    height: 200.0,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                                  clipBehavior: Clip.hardEdge,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => FullPhoto(
                                              url: document.data()['content'])));
                                },
                                padding: EdgeInsets.all(0),
                              ),
                              margin: EdgeInsets.only(left: 10.0),
                            )],
                        ),
                        onLongPress: () {deleteBuild(context,document.id);}
                    )),
              ],
            ),
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
        listMessage != null &&
        listMessage[index - 1].data()['idFrom'] == id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
        listMessage != null &&
        listMessage[index - 1].data()['idFrom'] != id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> onBackPress() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .update({'chattingWith': null});
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return FirstScreen(userId:id);
        },
      ),
    );// Do some stuff.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title:  FlatButton(
            onPressed: () {
             Navigator.of(context).push(
              MaterialPageRoute(
              builder: (context) {
                  return OtherUserProfile(peerName: peerName,peerAvatar: peerAvatar, peerAboutMe: peerAboutMe);
                        },
                  ),
                );
                  },
            child: Text(peerName,
                style: new TextStyle(color: const Color(0xFFFFFFFF),
                    fontSize: 20)),),
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: handleClick,
              itemBuilder: (BuildContext context) {
                return {'Delete All'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
        ),
        body: WillPopScope(
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  // List of messages
                  buildListMessage(),
                  // Input content
                  buildInput(),
                ],
              ),
              // Loading
              buildLoading()
            ],
          ),
          onWillPop: onBackPress,
        ));
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading ? const Loading() : Container(),
    );
  }

  Widget buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          // Button send image
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.image),
                onPressed: getImage,
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),

          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.ondemand_video),
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),
          // Edit text
          Flexible(
            child: Container(
              child: TextField(
                onSubmitted: (value) {
                  onSendMessage(textEditingController.text, 0);
                },
                style: TextStyle(color: primaryColor, fontSize: 15.0),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: greyColor),
                ),
                focusNode: focusNode,
              ),
            ),
          ),
          // Button send message
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: () => onSendMessage(textEditingController.text, 0),
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: greyColor2, width: 0.5)),
          color: Colors.white),
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: groupChatId == ''
          ? Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(themeColor)))
          : StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('messages')
            .doc(groupChatId)
            .collection(groupChatId)
            .orderBy('timestamp', descending: true)
            .limit(_limit)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
                    valueColor:
                    AlwaysStoppedAnimation<Color>(themeColor)));
          } else {
            listMessage.addAll(snapshot.data.documents);
            int itemLength = snapshot.data.documents.length - 1;
            return ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) {
                if(index != itemLength){
                return buildDay(index, snapshot.data.documents[index], snapshot.data.documents[index+1]);}
                else{
                  return buildDay1(index, snapshot.data.documents[index]);
                }
              },
              reverse: true,
              controller: listScrollController,
            );
          }
        },
      ),
    );
  }

  void handleClick(String value){
    switch (value) {
      case 'Delete All':
        {
          deleteAllBuild(context);
        }
        break;
    }
  }

  void deleteAll() async {

    var collectionReference = await FirebaseFirestore.instance.collection("messages");
    Future<QuerySnapshot> group = collectionReference.doc(groupChatId).collection(groupChatId).get();
    group.then((value) {
      value.docs.forEach((element) {
        collectionReference
            .doc(groupChatId)
            .collection(groupChatId)
            .doc(element.id)
            .delete()
            .then((value) => print("success"));
      });
    });
  }

  deleteAllBuild(BuildContext context) {

    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        deleteAll();
        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed:  () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      content: Text("Do you want to delete all the messages?"),
      actions: [
        cancelButton,
        okButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void onDelete(String timestamp) async{

    var documentReference = FirebaseFirestore.instance;
    documentReference.collection("messages").doc(groupChatId).collection(groupChatId)
        .doc(timestamp).delete();
  }

  deleteBuild(BuildContext context,String timestamp){
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        onDelete(timestamp);
        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed:  () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      content: Text("Do you want to delete this message?"),
      actions: [
        cancelButton,
        okButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

}
