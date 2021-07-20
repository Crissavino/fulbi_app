import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

class ManualLocation extends StatelessWidget {
  const ManualLocation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Center(
      child: Transform.translate(
          offset: Offset(0, -10),
          child: BounceInDown(
              from: 200,
              child: Icon( Icons.location_on, size: 50 )
          )
      ),
    );
  }
}
