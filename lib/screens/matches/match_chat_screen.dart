import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fulbito_app/models/message.dart';
import 'package:fulbito_app/models/user.dart';
import 'package:fulbito_app/repositories/chat_repository.dart';
import 'package:fulbito_app/screens/matches/match_info_screen.dart';
import 'package:fulbito_app/screens/matches/match_participants_screen.dart';
import 'package:fulbito_app/utils/constants.dart';
import 'package:fulbito_app/utils/translations.dart';
import 'package:fulbito_app/models/match.dart';
import 'package:fulbito_app/widgets/chat_message.dart';
import 'package:fulbito_app/widgets/header_message.dart';

// ignore: must_be_immutable
class MatchChatScreen extends StatefulWidget {
  Match match;
  User currentUser;

  MatchChatScreen({Key? key, required this.match, required this.currentUser})
      : super(key: key);

  @override
  _MatchChatScreenState createState() => _MatchChatScreenState();
}

class _MatchChatScreenState extends State<MatchChatScreen>
    with TickerProviderStateMixin {
  String localeName = Platform.localeName.split('_')[0];
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String textMessage = '';
  List _messages = [];
  bool isLoading = false;

  _getLatestValue() {
    setState(() {
      textMessage = _textController.text;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadHistory();
    _textController.addListener(_getLatestValue);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          SafeArea(
            top: false,
            bottom: false,
            child: Scaffold(
              appBar: new PreferredSize(
                child: new Container(
                  decoration: horizontalGradient,
                  child: AppBar(
                    backwardsCompatibility: false,
                    systemOverlayStyle:
                        SystemUiOverlayStyle(statusBarColor: Colors.white),
                    backgroundColor: Colors.transparent,
                    elevation: 0.0,
                    title: Text(
                      'Chat',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                preferredSize: new Size(
                  MediaQuery.of(context).size.width,
                  70.0,
                ),
              ),
              resizeToAvoidBottomInset: true,
              body: AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle.light,
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: screenBorders,
                          ),
                          child: ClipRRect(
                            borderRadius: screenBorders,
                            child: _buildMessagesScreen(),
                          ),
                        ),
                      ),
                      _buildMessageComposer(),
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: _buildBottomNavigationBar(),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMessagesScreen() {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: this.isLoading
          ? Container(
              width: _width,
              height: _height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [circularLoading],
              ),
            )
          : ListView.builder(
              reverse: true,
              padding: EdgeInsets.only(top: 15.0),
              itemCount: _messages.length,
              itemBuilder: (BuildContext context, int index) =>
                  _messages[index]),
    );
  }

  void _loadHistory() async {
    this.isLoading = true;
    final historyResponse =
        await ChatRepository().getMyChatMessages(widget.match.id);
    if (historyResponse['messages'].length > 0) {
      List<Message> myMessages = historyResponse['messages'];
      AnimationController _animationController = AnimationController(
        vsync: this,
        duration: Duration(
          milliseconds: 0,
        ),
      )..forward();

      final history = myMessages.map((m) => ChatMessage(
            text: m.text,
            sender: m.owner,
            currentUser: widget.currentUser,
            time: m.createdAt.toString(),
            animationController: _animationController,
          ));

      this.isLoading = false;
      setState(() {
        _messages.insertAll(0, history);
        _messages.insert(3, HeaderMessage(text: 'Pepito se unio al partido', animationController: _animationController));
      });
    } else {
      setState(() {
        this.isLoading = false;
      });
    }
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      height: 60.0,
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: <Widget>[
              // IconButton(
              //   icon: Icon(Icons.photo),
              //   iconSize: 25.0,
              //   color: Colors.green[400],
              //   onPressed: () {},
              // ),
              SizedBox(
                width: 25.0,
              ),
              Expanded(
                child: TextField(
                  controller: _textController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration.collapsed(
                    hintText:
                        translations[localeName]!['match.chat.sendMessage'],
                  ),
                  focusNode: _focusNode,
                ),
              ),
              Platform.isIOS
                  ? CupertinoButton(
                      child: Text(
                        translations[localeName]!['match.chat.send']!,
                        style: TextStyle(color: Colors.green[400]),
                      ),
                      onPressed: () => _handleSubmit(),
                    )
                  : IconButton(
                      icon: Icon(Icons.send),
                      iconSize: 25.0,
                      color: Colors.green[400],
                      onPressed: () => _handleSubmit(),
                    ),
            ],
          )
        ],
      ),
    );
  }

  _handleSubmit() {
    if (this.textMessage == '' || this.textMessage.length == 0) {
      return;
    }

    final newMessage = ChatMessage(
      text: this.textMessage,
      sender: widget.currentUser,
      currentUser: widget.currentUser,
      time: DateTime.now().toString(),
      animationController: AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400),
      ),
    );
    this._messages.insert(0, newMessage);
    // desp de insertar el mensaje disparo la animacion
    newMessage.animationController.forward();

    ChatRepository().sendMessage(
      widget.match.id,
      newMessage.text!,
      newMessage.currentUser!.id,
      widget.match.chatId,
    );

    this._focusNode.requestFocus();
    this._textController.clear();
  }

  void _navigateToSection(index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MatchInfoScreen(
              match: widget.match,
            ),
          ),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MatchParticipantsScreen(
              match: widget.match,
            ),
          ),
        );
        break;
      default:
        return;
    }
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      elevation: 0.0,
      iconSize: 30,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      selectedItemColor: Colors.green[400],
      unselectedItemColor: Colors.green[900],
      backgroundColor: Colors.white,
      currentIndex: 2,
      onTap: (index) {
        if (index != 2) {
          _navigateToSection(index);
        }
      },
      items: [
        BottomNavigationBarItem(
          // ignore: deprecated_member_use
          title: Text('Informacion'),
          icon: Icon(Icons.info_outlined),
        ),
        BottomNavigationBarItem(
          // ignore: deprecated_member_use
          title: Text('Participantes'),
          icon: Icon(
            Icons.group_outlined,
          ),
        ),
        BottomNavigationBarItem(
          // ignore: deprecated_member_use
          title: Text('Chat'),
          icon: Icon(Icons.chat_bubble),
        ),
      ],
    );
  }
}
