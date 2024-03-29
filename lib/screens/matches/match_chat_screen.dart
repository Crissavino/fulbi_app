import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fulbito_app/models/message.dart';
import 'package:fulbito_app/models/user.dart';
import 'package:fulbito_app/repositories/chat_repository.dart';
import 'package:fulbito_app/screens/matches/match_info_screen.dart';
import 'package:fulbito_app/screens/matches/match_participants_screen.dart';
import 'package:fulbito_app/screens/matches/matches_screen.dart';
import 'package:fulbito_app/screens/matches/my_matches_screen.dart';
import 'package:fulbito_app/services/push_notification_service.dart';
import 'package:fulbito_app/utils/constants.dart';
import 'package:fulbito_app/utils/translations.dart';
import 'package:fulbito_app/models/match.dart';
import 'package:fulbito_app/widgets/chat_message.dart';
import 'package:fulbito_app/widgets/header_message.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class MatchChatScreen extends StatefulWidget {
  Match match;
  User currentUser;
  bool calledFromMatchInfo;

  MatchChatScreen({
    required this.match,
    required this.currentUser,
    required this.calledFromMatchInfo,
  });

  @override
  _MatchChatScreenState createState() => _MatchChatScreenState();
}

class _MatchChatScreenState extends State<MatchChatScreen>
    with TickerProviderStateMixin {
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
    if (mounted) {
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
    if (this.mounted) ChatRepository().readMessages(widget.match.id);
    this.isLoading = true;
    loadFromLocalStorage();
    _loadHistory();
    _textController.addListener(_getLatestValue);

    silentNotificationListener();
  }

  void silentNotificationListener() {
    PushNotificationService.messageStream.listen((notificationData) {
      if (notificationData.containsKey('silentUpdateChat')) {
        AnimationController _animationController = AnimationController(
          vsync: this,
          duration: Duration(
            milliseconds: 0,
          ),
        )..forward();

        final Message message = notificationData['newMessage'];

        if (message.type == Message.TYPES['text']) {
          final messageToInsert = ChatMessage(
              text: message.text,
              sender: message.owner,
              currentUser: widget.currentUser,
              time: message.createdAt.toString(),
              animationController: _animationController,
              matchOwnerId: widget.match.ownerId);

          this._messages.insert(0, messageToInsert);
          if (!messagesStreamController.isClosed)
            messagesStreamController.sink.add(this._messages);
          messageToInsert.animationController.forward();
        } else if (message.type == Message.TYPES['header']) {
          final messageToInsert = HeaderMessage(
              text: message.text,
              time: message.createdAt.toString(),
              animationController: _animationController);

          this._messages.insert(0, messageToInsert);
          if (!messagesStreamController.isClosed)
            messagesStreamController.sink.add(this._messages);
        }
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if (this.mounted) ChatRepository().readMessages(widget.match.id);
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
            child: Hero(
              tag: 'matchChat',
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
                          if (widget.calledFromMatchInfo) {
                            Navigator.of(context)
                                .push(
                                  MaterialPageRoute(
                                    builder: (context) => MatchInfoScreen(
                                      match: widget.match,
                                      calledFromMatchInfo: widget.calledFromMatchInfo,
                                    ),
                                  ),
                                )
                                .then((_) => setState(() {}));
                          } else {
                            Navigator.of(context)
                                .push(
                                  MaterialPageRoute(
                                    builder: (context) => MatchesScreen(),
                                  ),
                                )
                                .then((_) => setState(() {}));
                          }
                        },
                        icon: Platform.isIOS
                            ? Icon(Icons.arrow_back_ios)
                            : Icon(Icons.arrow_back),
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
                body: Container(
                  color: Colors.white,
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
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
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
                    (scrollInfo.metrics.maxScrollExtent / 2) &&
                this.noMoreMessages == false &&
                !this.isLoadingMoreMessage) {
              final lastMessage = this._messages.last;
              timeLastMessage = lastMessage.time!;
              _loadMoreMessages(timeLastMessage!);
            }
            return true;
          },
          child: ListView.separated(
              reverse: true,
              separatorBuilder: (
                BuildContext _,
                int index,
              ) =>
                  buildSeparator(index, messages,
                      timeLastMessage: timeLastMessage),
              padding: EdgeInsets.only(top: 15.0),
              itemCount: messages.length,
              itemBuilder: (BuildContext context, int index) =>
                  messages[index]),
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

  void loadFromLocalStorage() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    if (localStorage.containsKey('matchChat.myMessages.${widget.match.id}')) {
      var thisMessages = json.decode(json.decode(
          localStorage.getString('matchChat.myMessages.${widget.match.id}')!));

      List messages = thisMessages;
      thisMessages =
          messages.map((message) => Message.fromJson(message)).toList();

      AnimationController _animationController = AnimationController(
        vsync: this,
        duration: Duration(
          milliseconds: 0,
        ),
      )..forward();

      final history = thisMessages.map((message) {
        if (message.type == Message.TYPES['text']) {
          return ChatMessage(
              text: message.text,
              sender: message.owner,
              currentUser: widget.currentUser,
              time: message.createdAt.toString(),
              animationController: _animationController,
              matchOwnerId: widget.match.ownerId);
        } else if (message.type == Message.TYPES['header']) {
          return HeaderMessage(
              text: message.text,
              time: message.createdAt.toString(),
              animationController: _animationController);
        }
      }).toList();

      this._messages.insertAll(0, history);
      if (!messagesStreamController.isClosed)
        messagesStreamController.sink.add(this._messages);
      setState(() {
        this.isLoading = false;
      });
    }
  }

  void _loadHistory() async {
    final historyResponse =
        await ChatRepository().getMyChatMessages(widget.match.id, null);
    if (historyResponse['messages'].length > 0) {
      List<Message> myMessages = historyResponse['messages'];
      AnimationController _animationController = AnimationController(
        vsync: this,
        duration: Duration(
          milliseconds: 0,
        ),
      )..forward();

      SharedPreferences localStorage = await SharedPreferences.getInstance();
      var jsonMessages = myMessages.map((e) => json.encode(e)).toList();
      await localStorage.setString('matchChat.myMessages.${widget.match.id}',
          json.encode(jsonMessages.toString()));

      final history = myMessages.map((message) {
        if (message.type == Message.TYPES['text']) {
          return ChatMessage(
              text: message.text,
              sender: message.owner,
              currentUser: widget.currentUser,
              time: message.createdAt.toString(),
              animationController: _animationController,
              matchOwnerId: widget.match.ownerId);
        } else if (message.type == Message.TYPES['header']) {
          return HeaderMessage(
              text: message.text,
              time: message.createdAt.toString(),
              animationController: _animationController);
        }
      }).toList();

      this._messages.clear();
      this._messages.insertAll(0, history);
      if (!messagesStreamController.isClosed)
        messagesStreamController.sink.add(this._messages);
      setState(() {
        this.isLoading = false;
      });
    } else {
      setState(() {
        this.isLoading = false;
      });
    }
  }

  void _loadMoreMessages(String timeLastMessage) async {
    this.isLoadingMoreMessage = true;
    final historyResponse = await ChatRepository()
        .getMyChatMessages(widget.match.id, timeLastMessage);
    if (historyResponse['messages'].length > 0) {
      List<Message> myMessages = historyResponse['messages'];
      AnimationController _animationController = AnimationController(
        vsync: this,
        duration: Duration(
          milliseconds: 0,
        ),
      )..forward();

      final history = myMessages.map((message) {
        if (message.type == Message.TYPES['text']) {
          return ChatMessage(
              text: message.text,
              sender: message.owner,
              currentUser: widget.currentUser,
              time: message.createdAt.toString(),
              animationController: _animationController,
              matchOwnerId: widget.match.ownerId);
        } else if (message.type == Message.TYPES['header']) {
          return HeaderMessage(
              text: message.text,
              time: message.createdAt.toString(),
              animationController: _animationController);
        }
      });

      this._messages.insertAll(_messages.length, history);
      if (!messagesStreamController.isClosed)
        messagesStreamController.sink.add(this._messages);
      setState(() {
        this.isLoadingMoreMessage = false;
      });
    } else {
      setState(() {
        this.isLoadingMoreMessage = false;
        this.noMoreMessages = true;
      });
    }
  }

  Widget _buildMessageComposer() {
    return Container(
      margin: EdgeInsets.only(top: 8.0),
      padding: EdgeInsets.all(8.0),
      height: 80.0,
      // add a line on the top of the container
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          // IconButton(
          //   icon: Icon(Icons.photo),
          //   iconSize: 25.0,
          //   color: Colors.green[400],
          //   onPressed: () {},
          // ),

          Expanded(
            child: Container(
              // add a border to simulate input field
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: TextField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                controller: _textController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration.collapsed(
                  hintText: translations[localeName]!['match.chat.sendMessage'],
                ),
                focusNode: _focusNode,
              ),
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
        matchOwnerId: widget.match.ownerId);
    this._messages.insert(0, newMessage);
    if (!messagesStreamController.isClosed)
      messagesStreamController.sink.add(this._messages);
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
}
