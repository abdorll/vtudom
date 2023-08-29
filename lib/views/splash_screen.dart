// // ignore_for_file: prefer_const_constructors, unused_local_variable

// import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';
// import 'package:vtudom/screen/intro_screens.dart';
// import 'package:vtudom/utils/color.dart';
// import 'package:vtudom/utils/constants.dart';
// import 'package:vtudom/utils/images.dart';
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({Key? key}) : super(key: key);

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   void nextPage() async {
//     var openBox = await Hive.openBox(userBox);
//     print('USER RECOGNIZED STATUS IS --------- $recognizedUser');
//     bool recognized = openBox.get(recognizedUser) ?? false;
//     bool userType = openBox.get(userIsCustomer) ?? true;
//     Future.delayed(Duration(seconds: 3), () {
//       recognized == false
//           ? Navigate.forwardForever(context, IntroScreen())
//           : Navigate.forwardForever(context, SelectLoginType());
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     nextPage();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: white,
//       body: Center(
//         child: Image.asset(
//           Img.logo,
//           height: 150,
//         ),
//       ),
//     );
//   }
// }
