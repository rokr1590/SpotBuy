import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotbuy/screens/message/components/message_bubble.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constants.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({
    Key? key,
    required this.toId,
    required this.name,
  }) : super(key: key);
  final String toId;
  final String name;

  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            color: Colors.white,
            onPressed: () {
              _makePhoneCall('tel:1234567890');
            },
            icon: const Icon(Icons.call),
          ),
        ],
        backgroundColor: const Color(0xff2E3C5D),
        toolbarHeight: 70,
        titleSpacing: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/images/user.png',
              fit: BoxFit.contain,
              height: 45,
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ), // You can add title here
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //   name,
            //   style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
            // ),
            // const Divider(
            //   height: 10,
            //   color: Colors.black,
            //   thickness: 2,
            // ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chatRoom')
                    .doc(formatId(cUser().uid, toId))
                    .collection(formatId(cUser().uid, toId))
                    .orderBy('timeStamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  var data = snapshot.data!.docs;

                  return data.isEmpty
                      ? const Center(
                          child: Text(
                            'No Chats!!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                            ),
                          ),
                        )
                      : ListView.builder(
                          reverse: true,
                          itemCount: data.length,
                          itemBuilder: (context, index) => MessageBubble(
                            isMe: data[index]['from'] == cUser().uid
                                ? true
                                : false,
                            message: data[index]['message'],
                          ),
                        );
                },
              ),
            ),
            const Divider(
              height: 10,
              color: Colors.grey,
            ),
            TypeMessage(
              id: toId,
              name: name,
            ),
          ],
        ),
      ),
    );
  }
}

class TypeMessage extends StatefulWidget {
  const TypeMessage({
    Key? key,
    required this.id,
    required this.name,
  }) : super(key: key);
  final String id;
  final String name;

  @override
  State<TypeMessage> createState() => _TypeMessageState();
}

class _TypeMessageState extends State<TypeMessage> {
  final TextEditingController _controller = TextEditingController();

  void _sendMessage(String _message, User user) async {
    FocusScope.of(context).unfocus();
    var time = DateTime.now().millisecondsSinceEpoch;
    await FirebaseFirestore.instance
        .collection('chatRoom')
        .doc(formatId(cUser().uid, widget.id))
        .collection(formatId(cUser().uid, widget.id))
        .doc(time.toString())
        .set({
      'from': user.uid,
      'to': widget.id,
      'message': _message,
      'timeStamp': time,
    });
    await FirebaseFirestore.instance
        .collection('users')
        .doc(cUser().uid)
        .collection('chats')
        .doc(widget.id)
        .set({'uid': widget.id, 'name': widget.name});
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.id)
        .collection('chats')
        .doc(cUser().uid)
        .set({'uid': cUser().uid, 'name': cUser().displayName});

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.cyan,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.1,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        border: Border.all(width: 1, color: Colors.black)),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: 'Type....',
                        hintStyle: TextStyle(fontSize: 18, color: Colors.black),
                        border: InputBorder.none,
                        errorBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    _controller.text.trim().isEmpty
                        ? null
                        : _sendMessage(_controller.text.trim(), cUser());
                    // var message = _controller.text.trim().isEmpty?null ;
                  },
                  // icon: const Icon(
                  //   Icons.send_rounded,
                  icon: Image.asset(
                    'assets/images/Send_icon.png',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
