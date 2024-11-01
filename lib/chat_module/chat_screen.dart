import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:women_safety_app/chat_module/message_text_field.dart';
import 'package:women_safety_app/chat_module/singleMessage.dart';
import 'package:women_safety_app/utils/constants.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String friendId;
  final String friendName;
  const ChatScreen({super.key, required this.currentUserId, required this.friendId, required this.friendName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String? type;
  String? myName;
  getStatus() async {
    await FirebaseFirestore.instance.collection('users').doc(widget.currentUserId).get().then((value) {
      setState(() {
        type = value.data()!['type'];
        myName = value.data()!['name'];
      });
    });
  }

  @override
  void initState() {
    getStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.friendName),
        backgroundColor: primaryColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('users').doc(widget.currentUserId).collection('messages').doc(widget.friendId).collection('chats').orderBy('date', descending: false).snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data!.docs.length < 1) {
                        return Center(
                          child: Text(type == 'parent' ? "Talk with Users" : "Talk with Parent", style: TextStyle(fontSize: 30)),
                        );
                      }
                      return Container(
                        child: ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (BuildContext context, int index) {
                            bool isMe = snapshot.data!.docs[index]['senderId'] == widget.currentUserId;
                            final data = snapshot.data!.docs[index];
                            // Something has to be newly added...
                            return Dismissible(
                              key: UniqueKey(),
                              onDismissed: (direction) async {
                                await FirebaseFirestore.instance.collection('users').doc(widget.currentUserId).collection('messages').doc(widget.friendId).collection('chats').doc(data.id).delete();
                                await FirebaseFirestore.instance.collection('users').doc(widget.friendId).collection('messages').doc(widget.currentUserId).collection('chats').doc(data.id).delete().then((value) => Fluttertoast.showToast(msg: 'Messages deleted successfully'));
                              },
                              child: SingleMessage(
                                message: data['message'],
                                isMe: isMe,
                                type: data['type'],
                                myName: myName,
                                friendName: widget.friendName,
                                date: data['date'],
                              ),
                            );
                          },
                        ),
                      );
                    }
                    return progressIndicator(context);
                }
            ),
          ),
          MessageTextField(
            currentId: widget.currentUserId,
            friendId: widget.friendId,
          ),
        ],
      ),
    );
  }
}
