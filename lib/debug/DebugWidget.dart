import 'package:erzmobil_driver/Constants.dart';
import 'package:erzmobil_driver/debug/Console.dart';
import 'package:erzmobil_driver/debug/Logger.dart';
import 'package:erzmobil_driver/model/User.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:erzmobil_driver/utils/StoreManager.dart';
import 'package:erzmobil_driver/utils/Utils.dart';
import 'package:tuple/tuple.dart';

class DebugScreen extends StatefulWidget {
  @override
  _DebugScreenState createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  bool _status = false;
  String? _logFiles;
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
    _initLogfileInfo();
    _initializeSwitch();
  }

  Future<void> _initializeSwitch() async {
    bool status = await _isLoggingActive();
    setState(() {
      _status = status;
    });
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  Future<void> _initLogfileInfo() async {
    String logFiles = await _logStatistics();
    setState(() {
      _logFiles = logFiles;
    });
  }

  Future<String> _logStatistics() async {
    Tuple2<int, int> tuple = await User().sizeLogs();
    String textLogs = AppLocalizations.of(context)!.numberLogfiles +
        ": " +
        tuple.item1.toString() +
        " | " +
        AppLocalizations.of(context)!.totalSizeLogFiles +
        ": " +
        Utils.formatBytes(tuple.item2);

    return textLogs;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<User>(
      builder: (context, user, child) => _buildWidgets(context),
    );
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
          foregroundColor: CustomColors.white,
          centerTitle: true,
          title: Text('Debug'),
          iconTheme: IconThemeData(
              color: CustomColors.marine, opacity: 1.0, size: 40.0),
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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                alignment: Alignment.center,
                margin: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 10.0),
                child: Text(
                  _status
                      ? AppLocalizations.of(context)!.loggingActive
                      : AppLocalizations.of(context)!.loggingInctive,
                  style: _status
                      ? CustomTextStyles.bodyGreen
                      : CustomTextStyles.bodyRed,
                )),
            Container(
                alignment: Alignment.center, child: Text(_logFiles ?? "")),
            Container(
              margin: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 10.0),
              child: TextButton(
                style: CustomButtonStyles.themeButtonyStyle(context),
                child: User().isDebugProcessing
                    ? new CircularProgressIndicator()
                    : Text(
                        'Send Logs',
                        style: CustomTextStyles.bodyWhite,
                      ),
                onPressed: User().isDebugProcessing
                    ? null
                    : () {
                        _submit();
                      },
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 10.0),
              child: TextButton(
                style: CustomButtonStyles.themeButtonyStyle(context),
                child: User().isDebugProcessing
                    ? new CircularProgressIndicator()
                    : Text(
                        'Clear Logs',
                        style: CustomTextStyles.bodyWhite,
                      ),
                onPressed: User().isDebugProcessing
                    ? null
                    : () {
                        _deleteLogs();
                      },
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: _buildLoggingButton(),
            ),
            Container(
              alignment: Alignment.center,
              child: Text('Version: ${_packageInfo.version}'),
            )
          ],
        ));
  }

  void _submit() async {
    //TODO: show feedback?
    Logger.info("Version: " + _packageInfo.version);
    await User().sendLogs();
  }

  void _deleteLogs() async {
    _showDialog(AppLocalizations.of(context)!.confirmDeleteLogs,
        AppLocalizations.of(context)!.explanationDeleteLogs, context);
  }

  Widget _buildLoggingButton() {
    Widget loggingSwitch = Switch(
      value: _status,
      activeColor: CustomColors.mint,
      inactiveTrackColor: CustomColors.anthracite,
      onChanged: (value) {
        setState(() {
          print('Switch value: ' + value.toString());
          _status = value;
          _setLoggingActive(value);
        });
      },
    );

    return InkWell(
      child: Container(
        margin: EdgeInsets.only(left: 15, right: 15),
        child: Row(
          children: <Widget>[
            // _buildIcon(Icons.contrast),
            Flexible(
              fit: FlexFit.loose,
              child: Container(
                margin: EdgeInsets.fromLTRB(15, 15, 15, 15),
                child: Text(
                  AppLocalizations.of(context)!.loggingStatus,
                  style:
                      CustomTextStyles.themeStyleWhiteForDarkOrAzure(context),
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            loggingSwitch,
          ],
        ),
      ),
      onTap: null,
    );
  }

  void _setLoggingActive(bool active) async {
    _status = active;
    StorageManager.setLoggingActive(active);
    Logger.init();
  }

  Future<bool> _isLoggingActive() async {
    bool result = await StorageManager.isLoggingActive();
    return result;
  }

  Future<void> _showDialog(
      String title, String message, BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: CustomTextStyles.title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  message,
                  style: CustomTextStyles.bodyGrey,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: CustomTextStyles.bodyAzure,
              ),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              child: Text(
                'Ja',
                style: CustomTextStyles.bodyAzure,
              ),
              onPressed: () {
                User().deleteLogs();
                Navigator.of(context).pop();
                _initLogfileInfo();
              },
            ),
          ],
        );
      },
    );
  }
}
