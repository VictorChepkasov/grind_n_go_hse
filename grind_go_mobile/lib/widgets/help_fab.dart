import 'package:flutter/material.dart';

class HelpFab extends StatelessWidget {
  const HelpFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Справка будет добавлена позже')),
        );
      },
      child: const Icon(Icons.help_outline_rounded),
    );
  }
}

class HelpFabLocation extends FloatingActionButtonLocation {
  const HelpFabLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    const padding = 16.0;
    const navBarHeight = kBottomNavigationBarHeight;

    final fabSize = scaffoldGeometry.floatingActionButtonSize;
    final scaffoldSize = scaffoldGeometry.scaffoldSize;

    return Offset(
      scaffoldSize.width - fabSize.width - padding,
      scaffoldSize.height - fabSize.height - navBarHeight - padding,
    );
  }
}
