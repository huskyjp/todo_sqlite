import 'package:flutter/material.dart';

class TopTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      child: Column(
        children: <Widget>[
          Text(
            'Nice Day!',
            style: TextStyle(
              fontSize: 30,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
        ],
      ),
      tween: Tween<double>(
        begin: 0,
        end: 1,
      ),
      duration: Duration(
        milliseconds: 1000,
      ),
      curve: Curves.bounceIn,
      builder: (BuildContext context, double _val, Widget child) {
        return Opacity(
          opacity: _val,
          child: Padding(
            padding: EdgeInsets.only(top: _val * 20),
          ),
        );
      },
    );
  }
}
