import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fulbito_app/repositories/user_repository.dart';
import 'package:fulbito_app/utils/check_auth.dart';
import 'package:fulbito_app/utils/constants.dart';
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
                  SafeArea(
                    top: false,
                    bottom: false,
                    child: Scaffold(
                      resizeToAvoidBottomInset: false,
                      body: AnnotatedRegion<SystemUiOverlayStyle>(
                        value: Platform.isIOS
                            ? SystemUiOverlayStyle.light
                            : SystemUiOverlayStyle.dark,
                        child: Center(
                          child: Container(
                            decoration: horizontalGradient,
                            child: LayoutBuilder(
                              builder:
                                  (BuildContext context, BoxConstraints constraints) {
                                return Stack(
                                  children: [
                                    Center(
                                      child: Text(
                                        'Update app',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 30.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  ],
                                );
                              },
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
