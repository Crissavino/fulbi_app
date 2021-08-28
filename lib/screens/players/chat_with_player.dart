import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fulbito_app/models/match.dart';
import 'package:fulbito_app/models/message.dart';
import 'package:fulbito_app/models/user.dart';
import 'package:fulbito_app/repositories/chat_repository.dart';
import 'package:fulbito_app/screens/matches/match_participants_screen.dart';
import 'package:fulbito_app/screens/profile/public_profile_screen.dart';
import 'package:fulbito_app/utils/constants.dart';
import 'package:fulbito_app/utils/translations.dart';
import 'package:fulbito_app/widgets/chat_message.dart';
import 'package:fulbito_app/widgets/header_message.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class ChatWithPlayer extends StatefulWidget {
  User currentUser;
  bool calledFromMatch;
  Match? match;

  ChatWithPlayer({
    required this.currentUser,
    required this.calledFromMatch,
    this.match,
  });

  @override
  _ChatWithPlayerState createState() => _ChatWithPlayerState();
}

class _ChatWithPlayerState extends State<ChatWithPlayer> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String textMessage = '';
  List _messages = [];
  bool isLoading = false;
  bool noMoreMessages = false;
  bool isLoadingMoreMessage = false;
  StreamController messagesStreamController = StreamController.broadcast();

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  _getLatestValue() {
    setState(() {
      textMessage = _textController.text;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // ChatRepository().readMessages(widget.match!.id);
    this.isLoading = true;
    // loadFromLocalStorage();
    _loadHistory();
    _textController.addListener(_getLatestValue);

    silentNotificationListener();
  }

  void silentNotificationListener() {

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    // ChatRepository().readMessages(widget.match!.id);
    _textController.dispose();
    messagesStreamController.close();
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
                    leading: IconButton(
                      onPressed: () {
                        if (widget.calledFromMatch) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                  builder: (context) => MatchParticipantsScreen(
                                    match: widget.match!,
                                    calledFromMyMatches: false,
                                  ),
                                ),
                          ).then((_) => setState(() {}));
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PublicProfileScreen(
                                    userId: widget.currentUser.id,
                                  ),
                                ),
                          ).then((_) => setState(() {}));
                        }
                      },
                      icon: Platform.isIOS ? Icon(Icons.arrow_back_ios) : Icon(Icons.arrow_back),
                      splashColor: Colors.transparent,
                    ),
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
                value: Platform.isIOS
                    ? SystemUiOverlayStyle.light
                    : SystemUiOverlayStyle.dark,
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
          : messageStreamBuilder(),
    );
  }

  messageStreamBuilder() {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    return StreamBuilder(
      initialData: this._messages,
      stream: messagesStreamController.stream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {

        if (!snapshot.hasData) {

          this.isLoading = true;

          return Container(
            width: _width,
            height: _height,
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              crossAxisAlignment:
              CrossAxisAlignment.center,
              children: [circularLoading],
            ),
          );
        }

        final messages = snapshot.data;

        this.isLoading = false;

        String? timeLastMessage;
        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (!isLoading &&
                scrollInfo.metrics.pixels >=
                    (scrollInfo.metrics.maxScrollExtent/2) &&
                this.noMoreMessages == false && !this.isLoadingMoreMessage) {
              final lastMessage = this._messages.last;
              timeLastMessage = lastMessage.time!;
              _loadMoreMessages(timeLastMessage!);
            }
            return true;
          },
          child: ListView.separated(
              reverse: true,
              separatorBuilder: (BuildContext _, int index,) => buildSeparator(index, messages, timeLastMessage: timeLastMessage),
              padding: EdgeInsets.only(top: 15.0),
              itemCount: messages.length,
              itemBuilder: (BuildContext context, int index) => messages[index]),
        );
      },
    );
  }

  Widget buildSeparator(index, messages, {String? timeLastMessage}) {
    if (index < messages.length - 1) {
      dynamic message = messages[index];
      DateTime today = DateTime.now();
      DateTime messageDate = DateTime.parse(message.time!);
      bool itsTodayMessage = today.day == messageDate.day;
      bool itsYesterdayMessage = today.day - 1 == messageDate.day;
      String messageDay = DateFormat('EEEE').format(messageDate);
      bool itsSamePreviousMessageDay = false;
      if (timeLastMessage != null) {
        DateTime previousMessageDate = DateTime.parse(timeLastMessage);
        itsSamePreviousMessageDay = previousMessageDate.day == messageDate.day;
      }
      if (!itsTodayMessage &&
          !itsYesterdayMessage &&
          !itsSamePreviousMessageDay) {
        bool itsSameDayMessage = false;
        dynamic nextMessage = messages[index + 1];
        DateTime nextMessageDate = DateTime.parse(nextMessage.time!);
        itsSameDayMessage = messageDate.day == nextMessageDate.day;
        if (!itsSameDayMessage) {
          AnimationController _animationController = AnimationController(
            vsync: this,
            duration: Duration(
              milliseconds: 0,
            ),
          )..forward();

          return HeaderMessage(
            text:
            '${translations[localeName]!['general.day.${messageDay.toLowerCase()}']!} ${DateFormat('dd/MM').format(messageDate)}',
            time: messageDate.toString(),
            animationController: _animationController,
          );
        } else {
          return Container();
        }
      } else if (!itsTodayMessage &&
          itsYesterdayMessage &&
          !itsSamePreviousMessageDay) {
        bool itsSameDayMessage = false;
        dynamic nextMessage = messages[index + 1];
        DateTime nextMessageDate = DateTime.parse(nextMessage.time!);
        itsSameDayMessage = messageDate.day == nextMessageDate.day;
        if (!itsSameDayMessage) {
          AnimationController _animationController = AnimationController(
            vsync: this,
            duration: Duration(
              milliseconds: 0,
            ),
          )..forward();

          return HeaderMessage(
            text:
            '${translations[localeName]!['general.day.${messageDay.toLowerCase()}']!} ${DateFormat('dd/MM').format(messageDate)}',
            time: messageDate.toString(),
            animationController: _animationController,
          );
        } else {
          return Container();
        }
      } else if (itsTodayMessage &&
          !itsYesterdayMessage &&
          !itsSamePreviousMessageDay) {
        bool itsSameDayMessage = false;
        dynamic nextMessage = messages[index + 1];
        DateTime nextMessageDate = DateTime.parse(nextMessage.time!);
        itsSameDayMessage = messageDate.day == nextMessageDate.day;
        if (!itsSameDayMessage) {
          AnimationController _animationController = AnimationController(
            vsync: this,
            duration: Duration(
              milliseconds: 0,
            ),
          )..forward();

          return HeaderMessage(
            text:
            '${translations[localeName]!['general.day.${messageDay.toLowerCase()}']!} ${DateFormat('dd/MM').format(messageDate)}',
            time: messageDate.toString(),
            animationController: _animationController,
          );
        } else {
          return Container();
        }
      } else {
        return Container();
      }
    } else {
      return Container();
    }
  }

  void _loadHistory() async {
    // final historyResponse =
    // await ChatRepository().getMyChatMessages(widget.match.id, null);
    // if (historyResponse['messages'].length > 0) {
    //   List<Message> myMessages = historyResponse['messages'];
    //   AnimationController _animationController = AnimationController(
    //     vsync: this,
    //     duration: Duration(
    //       milliseconds: 0,
    //     ),
    //   )..forward();
    //
    //   final history = myMessages.map((message) {
    //     if (message.type == Message.TYPES['text']) {
    //       return ChatMessage(
    //         text: message.text,
    //         sender: message.owner,
    //         currentUser: widget.currentUser,
    //         time: message.createdAt.toString(),
    //         animationController: _animationController,
    //       );
    //     } else if(message.type == Message.TYPES['header']) {
    //       return HeaderMessage(
    //           text: message.text,
    //           time: message.createdAt.toString(),
    //           animationController: _animationController
    //       );
    //     }
    //   }).toList();
    //
    //   this._messages.clear();
    //   this._messages.insertAll(0, history);
    //   if (!messagesStreamController.isClosed) messagesStreamController.sink.add(this._messages);
    //   setState(() {
    //     this.isLoading = false;
    //   });
    // } else {
    //   setState(() {
    //     this.isLoading = false;
    //   });
    // }
  }

  void _loadMoreMessages(String timeLastMessage) async {
    this.isLoadingMoreMessage = true;
    // final historyResponse =
    // await ChatRepository().getMyChatMessages(widget.match.id, timeLastMessage);
    // if (historyResponse['messages'].length > 0) {
    //   List<Message> myMessages = historyResponse['messages'];
    //   AnimationController _animationController = AnimationController(
    //     vsync: this,
    //     duration: Duration(
    //       milliseconds: 0,
    //     ),
    //   )..forward();
    //
    //   final history = myMessages.map((message) {
    //     if (message.type == Message.TYPES['text']) {
    //       return ChatMessage(
    //         text: message.text,
    //         sender: message.owner,
    //         currentUser: widget.currentUser,
    //         time: message.createdAt.toString(),
    //         animationController: _animationController,
    //       );
    //     } else if(message.type == Message.TYPES['header']) {
    //       return HeaderMessage(
    //           text: message.text,
    //           time: message.createdAt.toString(),
    //           animationController: _animationController
    //       );
    //     }
    //   });
    //
    //   this._messages.insertAll(_messages.length, history);
    //   if (!messagesStreamController.isClosed) messagesStreamController.sink.add(this._messages);
    //   setState(() {
    //     this.isLoadingMoreMessage = false;
    //   });
    // } else {
    //   setState(() {
    //     this.isLoadingMoreMessage = false;
    //     this.noMoreMessages = true;
    //   });
    // }
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      height: 80.0,
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
                  textInputAction: Platform.isIOS ? TextInputAction.newline : TextInputAction.newline,
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
    if (!messagesStreamController.isClosed) messagesStreamController.sink.add(this._messages);
    newMessage.animationController.forward();

    // ChatRepository().sendMessage(
    //   widget.match.id,
    //   newMessage.text!,
    //   newMessage.currentUser!.id,
    //   widget.match.chatId,
    // );

    this._focusNode.requestFocus();
    this._textController.clear();
  }
}
