import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

MaskTextInputFormatter createPhoneMaskFormatter() {
  return MaskTextInputFormatter(
    mask: '+7 (###) ###-##-##',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );
}

bool isPhoneComplete(String phone, MaskTextInputFormatter formatter) =>
    formatter.getUnmaskedText().length == 10;

/// Приводит номер к формату +79991234567 для API.
String normalizePhone(String phone) {
  final digits = phone.replaceAll(RegExp(r'\D'), '');

  if (digits.length == 10) {
    return '+7$digits';
  }
  if (digits.length == 11 && digits.startsWith('7')) {
    return '+$digits';
  }
  if (digits.length == 11 && digits.startsWith('8')) {
    return '+7${digits.substring(1)}';
  }

  return phone.trim();
}
