import 'package:erzmobil_driver/Constants.dart';
import 'package:erzmobil_driver/model/User.dart';
import 'package:flutter/material.dart';

class ConsoleScreen extends StatelessWidget {
  const ConsoleScreen({required this.logs, Key? key}) : super(key: key);

  final String logs;

  @override
  Widget build(BuildContext context) {
    return _buildWidgets(context);
  }

  Widget _buildWidgets(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[CustomColors.mint, CustomColors.marine])),
        ),
        automaticallyImplyLeading: !User().isDebugProcessing,
        centerTitle: true,
        title: Text('Debug'),
        iconTheme:
            IconThemeData(color: CustomColors.marine, opacity: 1.0, size: 40.0),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: CustomColors.backButtonIconColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Text(logs),
        ),
      ),
    );
  }
}
