const assetPath = 'assets/images';
String image(String imageName, {String type = 'png'}) {
  return '$assetPath/$imageName.$type';
}

String svgImage(String imageName) {
  return '$assetPath/$imageName';
}

class ImageOf {
  static String logo = image('logo');
  static String network = image('network');
  static String splashScreenImage = image('splash_screen');
  static String slide1 = image('slide1');
  static String slide2 = image('slide2');
  static String slide3 = image('slide3');
}
