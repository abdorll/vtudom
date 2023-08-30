import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:vtudom/routes/app_routes.dart';
import 'package:vtudom/utils/color.dart';
import 'package:vtudom/utils/constants.dart';
import 'package:vtudom/views/splash_screen.dart';
import 'package:vtudom/views/web_view_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: true, ignoreSsl: true);
  await Permission.notification.request();
  await Permission.storage.request();
  var path = await getApplicationDocumentsDirectory();
  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
  Hive.init(path.path);
  await Hive.openBox(Constants.userBox);

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: primaryColor,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final botToastBuilder = BotToastInit();
    return MaterialApp(
      title: 'VTUDOM',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),

      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return botToastBuilder(context, child);
      },
      initialRoute: SplashScreen.splashScreen,
      // home: Scaffold(
      //   body: Container(
      //     child: Center(
      //       child: Text("data"),
      //     ),
      //   ),
      // ),
      onGenerateRoute: AppRoutes.generateRoute,
      navigatorObservers: [
        BotToastNavigatorObserver(),
      ],
    );
  }
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
