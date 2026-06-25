import 'package:url_launcher/url_launcher.dart';

const supportFormUrl =
    'https://docs.google.com/forms/d/e/1FAIpQLSfGEb33E9roKbqrNscM-qE7utyI5Df3NO_WiNSb69C2Rr-nOw/viewform?usp=publish-editor';

Future<bool> openSupportForm() {
  final uri = Uri.parse(supportFormUrl);
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
