import 'package:flutter/material.dart';
import 'package:trackmymarket_app/HomePage.dart';
import 'package:splashscreen/splashscreen.dart';


class MySplashPage extends StatefulWidget {
  const MySplashPage({Key? key}) : super(key: key);

  @override
  _MySplashPageState createState() => _MySplashPageState();
}

class _MySplashPageState extends State<MySplashPage> {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 12,
      navigateAfterSeconds: HomePage(),
      imageBackground: Image.asset("assets/supermarket1.jpg").image,
      useLoader: true,
      loaderColor: Colors.orange,
      loadingText: Text("loading...", style: TextStyle(color: Colors.white),),
    );
  }
}
