import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:erzmobil_driver/Constants.dart';
import 'package:erzmobil_driver/debug/DebugWidget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:erzmobil_driver/model/User.dart';
import 'package:provider/provider.dart';
import 'package:erzmobil_driver/debug/Logger.dart';
import 'package:url_launcher/url_launcher.dart';

class InformationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 25),
          ),
          _buildRow(AppLocalizations.of(context)!.about, _buildIcon(Icons.info),
              () {
            _launchAboutErzmobil();
          }),
          _buildRow(AppLocalizations.of(context)!.licenses,
              _buildIcon(Icons.library_books), () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => new LicensePage(),
            ));
          }),
          _buildRow(AppLocalizations.of(context)!.imprintLabel,
              _buildIcon(Icons.privacy_tip), () {
            _launchImprint();
          }),
          _buildRow(AppLocalizations.of(context)!.dataprivacyLabel,
              _buildIcon(Icons.policy), () {
            _launchDataprivacy();
          }),
          _buildDebug(context),
        ],
      ),
    );
  }

  void _launchImprint() async {
    if (await canLaunch(Strings.IMPRINT_URL)) {
      await launch(Strings.IMPRINT_URL);
    } else {
      Logger.info('Could not launch $Strings.IMPRINT_URL');
    }
  }

  void _launchAboutErzmobil() async {
    if (await canLaunch(Strings.ABOUT_ERZMOBIL_URL)) {
      await launch(Strings.ABOUT_ERZMOBIL_URL);
    } else {
      Logger.info('Could not launch $Strings.ABOUT_ERZMOBIL_URL');
    }
  }

  void _launchDataprivacy() async {
    if (await canLaunch(Strings.DATAPRIVACY_URL)) {
      await launch(Strings.DATAPRIVACY_URL);
    } else {
      Logger.info('Could not launch $Strings.DATAPRIVACY_URL');
    }
  }

  Widget _buildDebug(BuildContext context) {
    return /*!kReleaseMode || Logger.debugMode
        ? */
        _buildRow('Debug', _buildIcon(Icons.library_books), () {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) =>
            ChangeNotifierProvider.value(value: User(), child: DebugScreen()),
      ));
    });
  }

  Widget _buildIcon(IconData data) {
    return Icon(
      data,
      color: CustomColors.marine,
      size: 30,
    );
  }

  Widget _buildImage(String asset) {
    return Container(
      width: 50,
      height: 50,
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
        repeat: ImageRepeat.noRepeat,
      ),
    );
  }

  Widget _buildRow(String text, Widget icon, Function()? onPressed) {
    return InkWell(
      child: Container(
        margin: EdgeInsets.only(left: 15, right: 15),
        child: Row(
          children: <Widget>[
            icon,
            Flexible(
              fit: FlexFit.loose,
              child: Container(
                margin: EdgeInsets.fromLTRB(15, 15, 15, 15),
                child: Text(
                  text,
                  style: CustomTextStyles.bodyAzure,
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
          ],
        ),
      ),
      onTap: onPressed,
    );
  }
}
