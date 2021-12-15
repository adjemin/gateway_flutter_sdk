import 'package:flutter/material.dart';

class CustomProgressWidget extends StatelessWidget {

  const CustomProgressWidget();

  @override
  Widget build(BuildContext context) {
    return new Stack(
      children: [
        new Container(
          color: Colors.white,
        ),
        new Container(
          color: Colors.white,
        ),
        new Center(
          child: new CircularProgressIndicator(),
        ),
      ],
    );

  }

}
