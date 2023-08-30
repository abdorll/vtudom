import 'package:flutter/cupertino.dart';
import 'package:vtudom/utils/color.dart';
import 'package:vtudom/widget/spacing.dart';
import 'package:vtudom/widget/texts.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          YMargin(20),
          CupertinoActivityIndicator(
            radius: 25,
            color: primaryColor,
          ),
          YMargin(10),
          TextOf("Please wait...", 12, black,FontWeight.w500)
        ],
      ),
    ));
  }
}
