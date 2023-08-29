const assetPath = 'assets/images';
String image(String imageName, {String type = 'png'}) {
  return '$assetPath/$imageName.$type';
}

String svgImage(String imageName) {
  return '$assetPath/$imageName';
}

class Img {
  static String network = image('network');
  static String halalWayToTransact = image('halal_way_to_transact');
  static String ethicalInvesting = image('ethical_investing');
  static String takafulInsuranceSimplified =
      image('takaful_insurance_simplified');
  static String savingsRedefined = image('savings_redefined', type: 'jpg');
  static String halalFinancingUnleashed =
      image('halal_financing_unleashed', type: 'jpg');
  static String donationsDemocratized = image('donations_democratized');
  static String videoPreview = image('video_preview', type: 'mp4');
  static String website = image('website');
  static String office = image('office');
  static String sms = image('sms');
  static String individual = image('individual');
  static String aggregator = image('aggregator');
  static String telegram = image('telegram');
  static String agent = image('agent');
  static String merchant = image('merchant');
  static String staff = image('staff');
  static String contactUs = image('contact_us');
  static String logo = image('logo');
  static String conversation = image('conversation');
  static String email = image('email');
  static String message = image('message_logo');
  static String whatsapp = image('whatsapp');
  static String phone = image('phone');
  static String home = image("home");
  static String refresh = image("refresh");
  static String back = image("back");
  static String forward = image("forward");
}
