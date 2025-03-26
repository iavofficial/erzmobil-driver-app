import 'package:erzmobil_driver/Constants.dart';
import 'package:erzmobil_driver/account/LoginScreen.dart';
import 'package:erzmobil_driver/account/RegisterScreen.dart';
import 'package:erzmobil_driver/model/RequestState.dart';
import 'package:erzmobil_driver/model/User.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:erzmobil_driver/debug/Logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<User>(
      builder: (context, user, child) => _buildWidgets(context),
    );
  }

  Widget _buildWidgets(BuildContext context) {
    if (User().isLoggedIn()) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              showLogo(),
              Padding(padding: EdgeInsets.only(bottom: 30)),
              Container(
                margin: EdgeInsets.only(left: 25, right: 25),
                child: Text(
                  AppLocalizations.of(context)!.loggedInAsLabel,
                  style: CustomTextStyles.themeStyleWhiteForDarkOrGrey(context),
                ),
              ),
              Flexible(
                fit: FlexFit.loose,
                child: Container(
                  margin: EdgeInsets.only(left: 25, right: 25),
                  child: Text(
                    User().email!,
                    style:
                        CustomTextStyles.themeStyleWhiteForDarkOrGrey(context),
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(25.0, 30.0, 25.0, 15.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 15.0),
                    backgroundColor:
                        CustomColors.themeStyleMintForDarkOrMarine(context),
                    foregroundColor: CustomColors.lightGrey,
                    shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(10.0),
                    ),
                  ),
                  child: User().isProgressLogout
                      ? new CircularProgressIndicator()
                      : Text(
                          AppLocalizations.of(context)!.signout,
                          style: CustomTextStyles.bodyWhite,
                        ),
                  onPressed: User().isProcessing
                      ? null
                      : () {
                          _logout(context);
                        },
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 30.0),
            child: RichText(
              textAlign: TextAlign.left,
              text: TextSpan(
                style: CustomTextStyles.themeStyleWhiteForDarkOrGrey(context),
                children: <TextSpan>[
                  TextSpan(
                      text: AppLocalizations.of(context)!.deleteAccountText1),
                  TextSpan(
                      style: CustomTextStyles.bodyMintBold,
                      text: AppLocalizations.of(context)!.deleteAccountText2,
                      recognizer: TapGestureRecognizer()
                        ..onTap = User().isProcessing
                            ? null
                            : () {
                                _confirmDeleteDialog(context);
                              })
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          showLogo(),
          _buildButton(
            AppLocalizations.of(context)!.signup,
            ChangeNotifierProvider.value(
                value: User(), child: RegisterScreen()),
          ),
          _buildButton(
            AppLocalizations.of(context)!.signin,
            ChangeNotifierProvider.value(value: User(), child: LoginScreen()),
          ),
        ],
      );
    }
  }

  Widget showLogo() {
    return Container(
      margin: EdgeInsets.fromLTRB(25.0, 30, 50.0, 10),
      alignment: Alignment.topLeft,
      child: new Image.asset(
        Strings.assetPathLogo,
        fit: BoxFit.cover,
        repeat: ImageRepeat.noRepeat,
      ),
    );
  }

  void _logout(BuildContext context) async {
    RequestState state = await User().logout();
    if (state != RequestState.SUCCESS) {
      Logger.debug("Error occured during logout");
    }
  }

  void _delete(BuildContext context) async {
    RequestState state = await User().deleteUser();
    if (state == RequestState.ERROR_FAILED_NO_INTERNET) {
      _showDialog(AppLocalizations.of(context)!.dialogErrorTitle,
          AppLocalizations.of(context)!.dialogMessageNoInternet, context);
    } else if (state != RequestState.SUCCESS) {
      _showDialog(AppLocalizations.of(context)!.dialogErrorTitle,
          AppLocalizations.of(context)!.dialogGenericErrorText, context);
    } else {
      _showDialog(AppLocalizations.of(context)!.dialogInfoTitle,
          AppLocalizations.of(context)!.dialogDeleteAccountText, context);
    }
  }

  Future<void> _confirmDeleteDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.dialogDeleteAccountTitle,
              style: CustomTextStyles.title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  AppLocalizations.of(context)!.dialogDeleteAccountMessage,
                  style: CustomTextStyles.bodyGrey,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                AppLocalizations.of(context)!.buttonConfirmDelete,
                style: CustomTextStyles.bodyAzure,
              ),
              onPressed: () {
                _delete(context);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: CustomTextStyles.bodyAzure,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
                'OK',
                style: CustomTextStyles.bodyAzure,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildButton(String text, Widget screen) => Container(
        margin: EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 15.0),
        child: TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 15.0),
            backgroundColor:
                CustomColors.themeStyleMintForDarkOrMarine(context),
            disabledBackgroundColor: CustomColors.lightGrey,
            shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(10.0),
            ),
          ),
          child: Text(
            text,
            style: CustomTextStyles.bodyWhite,
          ),
          // Routes must be rebuild after usage, reuse is not possible so we must use a closure and not one route object
          onPressed: User().isProcessing
              ? null
              : () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => screen));
                },
        ),
      );
}
