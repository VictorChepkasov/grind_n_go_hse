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
