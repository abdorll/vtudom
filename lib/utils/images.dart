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
}
