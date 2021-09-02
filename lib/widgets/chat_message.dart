import 'package:flutter/material.dart';
import 'package:fulbito_app/models/user.dart';
import 'package:fulbito_app/widgets/simple_url_preview_custom.dart';
import 'package:linkable/linkable.dart';
import 'package:simple_url_preview/simple_url_preview.dart';
import 'package:flutter_parsed_text/flutter_parsed_text.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatMessage extends StatelessWidget {
  final String? text;
  final User? sender;
  final User? currentUser;
  final String? time;
  final AnimationController animationController;
  final int matchOwnerId;

  const ChatMessage({
    required this.text,
    required this.sender,
    required this.currentUser,
    required this.time,
    required this.animationController,
    required this.matchOwnerId
  });

  @override
  Widget build(BuildContext context) {

    final userId = this.sender!.id;

    return FadeTransition(
      opacity: animationController,
      child: SizeTransition(
        sizeFactor: CurvedAnimation(
          parent: animationController,
          curve: Curves.elasticOut,
        ),
        child: Container(
          child: userId == currentUser!.id
              ? _myMessage(context, currentUser!)
              : _notMyMessage(context, this.sender),
          // : _notMyMessage(context, sender),
        ),
      ),
    );
  }

  Widget _myMessage(BuildContext context, User currentUser) {
    final DateTime? parsedTime = DateTime.tryParse(this.time!)!.toLocal();
    final messageHour = parsedTime!.hour;
    final messageMinute = parsedTime.minute < 10 ? '0${parsedTime.minute}' : parsedTime.minute;
    final messageTime = '$messageHour:$messageMinute';
    String messageText = this.text!;
    final isMatchOwner = currentUser.id == this.matchOwnerId;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Container()),
        Container(
          margin: EdgeInsets.only(
            top: 8.0,
            bottom: 8.0,
          ),
          padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
          width: MediaQuery.of(context).size.width * 0.85,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0),
              bottomLeft: Radius.circular(15.0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currentUser.name,
                    style: TextStyle(
                      color: isMatchOwner ? Colors.blueGrey[800] : Colors.blueGrey,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    messageTime.toString(),
                    // message.time.toString(),
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              FormattedText(messageText,)
            ],
          ),
        ),
      ],
    );
  }

  Widget _notMyMessage(BuildContext context, dynamic senderUser) {
    final userFullName = senderUser is User ? senderUser.name : senderUser['fullName'];
    final isMatchOwner = senderUser is User
        ? senderUser.id == this.matchOwnerId
        : senderUser['id'] == this.matchOwnerId;
    final DateTime? parsedTime = DateTime.tryParse(this.time!)!.toLocal();
    final messageHour = parsedTime!.hour;
    final messageMinute = parsedTime.minute < 10 ? '0${parsedTime.minute}' : parsedTime.minute;
    final messageTime = '$messageHour:$messageMinute';
    String messageText = this.text!;

    return Container(
      margin: EdgeInsets.only(
        top: 8.0,
        bottom: 8.0,
      ),
      padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
      width: MediaQuery.of(context).size.width * 0.85,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(15.0),
          bottomRight: Radius.circular(15.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                userFullName,
                style: TextStyle(
                  color: isMatchOwner ? Colors.blueGrey[800] : Colors.blueGrey,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                messageTime.toString(),
                // message.time.toString(),
                style: TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          SizedBox(height: 8.0),
          FormattedText(messageText,)
          // Linkable(
          //   text: this.text!,
          //   style: TextStyle(
          //     color: Colors.blueGrey,
          //     fontSize: 16.0,
          //     fontWeight: FontWeight.w400,
          //   ),
          // )
        ],
      ),
    );
  }
}

class FormattedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final TextOverflow? overflow;
  final int? maxLines;

  FormattedText(
      this.text, {
        Key? key,
        this.style,
        this.textAlign,
        this.textDirection,
        this.overflow,
        this.maxLines,
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    Widget showPreview({required String pattern, required String text}) {
      return SimpleUrlPreviewCustom(
        url: text,
        bgColor: Colors.grey[350],
        // isClosable: false,
        // imageLoaderColor: Colors.white,
        previewContainerPadding: EdgeInsets.all(0.0),
        titleLines: 1,
        // descriptionLines: 2,
        titleStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600
        ),
        descriptionStyle: TextStyle(
          fontSize: 12,
        ),
        siteNameStyle: TextStyle(
          fontSize: 12,
        ),
      );
    }

    return ParsedText(
      text: this.text,
      style: style ?? TextStyle(
        color: Colors.blueGrey,
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
      ),
      overflow: TextOverflow.clip,
      maxLines: maxLines ?? 15,
      parse: [
        MatchText(
          renderWidget: showPreview,
          pattern: '([(http(s)?):\/\/(www\.)?a-zA-Z0-9@:._\+-~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:_\+.~#?&\/\/=]*))',
          type: ParsedType.URL,
          style: TextStyle(
            color: Colors.blue,
            fontSize: 16.0,
            fontWeight: FontWeight.w400,
          ),
          onTap: (url) async {
            var a = await canLaunch(url);

            if (a) {
              launch(url);
            }
          },
        )
      ],
      regexOptions: RegexOptions(caseSensitive: false),
    );
  }
}