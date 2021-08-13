import 'package:flutter/material.dart';

class CustomError extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  const CustomError({
    required this.errorDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5.0,
      child: Column(
        children: [
          Padding(
            child: Text(
              "Something is not right here...",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            padding: const EdgeInsets.all(8.0),
          ),
          Padding(
            child: Text(
              errorDetails.exceptionAsString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 10,
            ),
            padding: const EdgeInsets.all(8.0),
          ),
        ],
      ),
      color: Colors.red,
      margin: EdgeInsets.only(
          top: 100.0,
          left: 60.0,
          right: 60.0,
          bottom: 200.0
      ),
    );
  }
}