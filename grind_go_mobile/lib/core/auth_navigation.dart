import 'package:flutter/material.dart';

/// Закрывает экраны авторизации и показывает [MainShell] через [AuthGate].
void completeAuthFlow(BuildContext context) {
  Navigator.of(context).popUntil((route) => route.isFirst);
}
