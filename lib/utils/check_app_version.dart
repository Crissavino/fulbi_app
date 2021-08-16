import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fulbito_app/repositories/user_repository.dart';
import 'package:fulbito_app/utils/check_auth.dart';
import 'package:fulbito_app/utils/constants.dart';
import 'package:fulbito_app/utils/translations.dart';
import 'package:launch_review/launch_review.dart';
import 'package:package_info_plus/package_info_plus.dart';

class CheckAppVersion extends StatefulWidget {
  const CheckAppVersion({Key? key}) : super(key: key);

  @override
  _CheckAppVersionState createState() => _CheckAppVersionState();
}

class _CheckAppVersionState extends State<CheckAppVersion> {
  String versionNumber = '';
  int versionMajor = 0;
  int versionMinor = 0;
  int versionPatch = 0;

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    this.versionNumber = info.version;

    List<int> versionList =
        this.versionNumber.split('.').map((e) => int.parse(e)).toList();
    this.versionMajor = versionList[0];
    this.versionMinor = versionList[1];
    this.versionPatch = versionList[2];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return FutureBuilder(
      future: UserRepository().getAppMinimumVersion(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          int versionMajor = snapshot.data['versionMajor'];
          int versionMinor = snapshot.data['versionMinor'];
          int versionPatch = snapshot.data['versionPatch'];
          if (this.versionMajor == versionMajor &&
              this.versionMinor == versionMinor &&
              this.versionPatch >= versionPatch) {
            return CheckAuth();
          } else {
            return GestureDetector(
              child: Stack(
                children: [
                  Scaffold(
                    resizeToAvoidBottomInset: false,
                    body: SafeArea(
                      top: false,
                      bottom: false,
                      child: AnnotatedRegion<SystemUiOverlayStyle>(
                        value: Platform.isIOS
                            ? SystemUiOverlayStyle.light
                            : SystemUiOverlayStyle.dark,
                        child: Center(
                          child: Container(
                            decoration: verticalGradient,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: width,
                                  height: height - 200,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                            'assets/update_app.png'
                                        ),
                                      )
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    translations[localeName]!['general.updateText']!,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Container(
                                    margin: EdgeInsets.only(top: 20.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                    ),
                                    width: width * .40,
                                    height: 50.0,
                                    child: Center(
                                      child: TextButton(
                                        onPressed: () => LaunchReview.launch(
                                          androidAppId: "com.crissavino.fulbito.fulbito_app",
                                          iOSAppId: "585027354",
                                        ),
                                        child: Text(
                                          translations[localeName]!['general.update']!.toUpperCase(),
                                          style: TextStyle(
                                            color: Color(0xFF527DAA),
                                            letterSpacing: 1.5,
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'OpenSans',
                                          ),
                                        ) ,
                                      ),
                                    ),
                                  ),
                                )
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
        } else {
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/splash_screen.png'
                ),
                fit: BoxFit.cover
              )
            ),
          );
        }

    });
  }
}
