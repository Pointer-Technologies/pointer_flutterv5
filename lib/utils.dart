import 'package:url_launcher/url_launcher.dart';

class Utils{
  static Future openLink({String url}) => _launchUrl(url);

  static Future _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  static Future openPhoneCall(String phoneNumber) async {
    final url = 'tel:$phoneNumber';

    await _launchUrl(url);
  }

  static Future openEmail(String toEmail, String subject, String body) async {
    final url = 'mailto:$toEmail?subject=${Uri.encodeFull(subject)}&body=${Uri.encodeFull(body)}';

    await _launchUrl(url);
  }
  
}