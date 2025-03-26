import 'package:flutter/material.dart';
import 'package:erzmobil_driver/Constants.dart';
import 'package:erzmobil_driver/account/VerifyScreen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:erzmobil_driver/model/RequestState.dart';
import 'package:erzmobil_driver/model/User.dart';
import 'package:provider/provider.dart';

import 'ResetScreen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  String? _tmpPwd;
  bool obscurePwd = true;

  void _submit(BuildContext context) async {
    //check system state

    RequestState state = await User().login(_tmpPwd, context);
    if (state != RequestState.SUCCESS) {
      if (state == RequestState.ERROR_WRONG_CREDENTIALS) {
        _showDialog(
            AppLocalizations.of(context)!.dialogErrorTitle,
            AppLocalizations.of(context)!.dialogWrongCredentialsErrorText,
            context,
            false);
      } else if (state == RequestState.ERROR_CONFIRMATION_NECESSARY) {
        _showDialog(
            AppLocalizations.of(context)!.dialogInfoTitle,
            AppLocalizations.of(context)!.dialogConfirmNecessaryText,
            context,
            true);
      } else if (state == RequestState.ERROR_USER_UNKNOWN) {
        _showDialog(AppLocalizations.of(context)!.dialogErrorTitle,
            AppLocalizations.of(context)!.userNotAvailable, context, false);
      } else {
        _showDialog(
            AppLocalizations.of(context)!.dialogErrorTitle,
            AppLocalizations.of(context)!.dialogGenericErrorText,
            context,
            false);
      }
      return;
    }
    RequestState result = await User().registerToken();
    await User().showFCMErrorIfnecessary(context, result);
    Navigator.of(context).pop();
  }

  void _sendMail() async {
    RequestState state = await User().resendConfirmationCode(User().email);
    if (state == RequestState.SUCCESS) {
      _showDialog(AppLocalizations.of(context)!.dialogInfoTitle,
          AppLocalizations.of(context)!.dialogSendMailText, context, false);
    } else {
      _showDialog(AppLocalizations.of(context)!.dialogErrorTitle,
          AppLocalizations.of(context)!.dialogGenericErrorText, context, false);
    }
  }

  Future<void> _showDialog(String title, String message, BuildContext context,
      bool isConfirmNecessary) async {
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
                isConfirmNecessary
                    ? AppLocalizations.of(context)!.buttonSend
                    : 'OK',
                style: CustomTextStyles.bodyAzure,
              ),
              onPressed: () {
                if (isConfirmNecessary) {
                  _sendMail();
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Consumer<User>(
            builder: (context, user, child) => _buildWidgets(context)),
        onWillPop: () async {
          return !User().isProcessing;
        });
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
        automaticallyImplyLeading: !User().isProcessing,
        foregroundColor: CustomColors.white,
        centerTitle: true,
        title: Text(AppLocalizations.of(context)!.signin),
        iconTheme:
            IconThemeData(color: CustomColors.azure, opacity: 1.0, size: 40.0),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(50.0, 30.0, 50.0, 10.0),
              alignment: Alignment.topCenter,
              child: Icon(
                Icons.account_circle,
                color: CustomColors.themeStyleWhiteForDarkOrMarine(context),
                size: 100,
              ),
            ),
            Form(
              key: _nameFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 10.0),
                    child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      style: CustomTextStyles.themeStyleWhiteForDarkOrGrey(
                          context),
                      autocorrect: false,
                      enabled: !User().isProcessing,
                      decoration: new InputDecoration(
                          labelText:
                              AppLocalizations.of(context)!.placeholderEmail,
                          labelStyle: CustomTextStyles.bodyLightGrey,
                          errorMaxLines: 2),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return AppLocalizations.of(context)!.placeholderEmail;
                        }
                        if (!Expressions.regExpName.hasMatch(value)) {
                          return AppLocalizations.of(context)!.eMailValidation;
                        }
                        return null;
                      },
                      onSaved: (String? email) {
                        User().email = email;
                      },
                    ),
                  )
                ],
              ),
            ),
            Form(
              key: _passwordFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 20.0),
                    child: TextFormField(
                      obscureText: obscurePwd,
                      style: CustomTextStyles.themeStyleWhiteForDarkOrGrey(
                          context),
                      autocorrect: false,
                      enabled: !User().isProcessing,
                      decoration: new InputDecoration(
                          suffixIcon: IconButton(
                              icon: Icon(
                                obscurePwd
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color:
                                    CustomColors.themeStyleWhiteForDarkOrBlack(
                                        context),
                                size: 18,
                              ),
                              onPressed: () {
                                setState(() {
                                  obscurePwd = !obscurePwd;
                                });
                              }),
                          labelText:
                              AppLocalizations.of(context)!.placeholderPassword,
                          labelStyle: CustomTextStyles.bodyLightGrey,
                          errorMaxLines: 3),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return AppLocalizations.of(context)!
                              .placeholderPassword;
                        }
                        return null;
                      },
                      onSaved: (String? pwd) {
                        _tmpPwd = pwd;
                      },
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 10.0),
              child: TextButton(
                style: TextButton.styleFrom(
                    padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 15.0),
                    backgroundColor:
                        CustomColors.themeStyleMintForDarkOrMarine(context),
                    disabledBackgroundColor: CustomColors.lightGrey,
                    shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(10.0),
                    )),
                child: User().isProgressLogin || User().isProgressConfirm
                    ? new CircularProgressIndicator()
                    : Text(
                        AppLocalizations.of(context)!.signin,
                        style: CustomTextStyles.bodyWhite,
                      ),
                onPressed: User().isProcessing
                    ? null
                    : () {
                        if (_nameFormKey.currentState!.validate() &&
                            _passwordFormKey.currentState!.validate()) {
                          _nameFormKey.currentState!.save();
                          _passwordFormKey.currentState!.save();
                          _submit(context);
                        }
                      },
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 15.0),
              child: TextButton(
                style: CustomButtonStyles.themeButtonyStyle(context),
                child: Text(
                  AppLocalizations.of(context)!.forgotPassword,
                  style: CustomTextStyles.bodyWhite,
                ),
                onPressed: User().isProcessing
                    ? null
                    : () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) =>
                              ChangeNotifierProvider.value(
                                  value: User(), child: ResetScreen()),
                        ));
                      },
              ),
            ),
            _buildVerifyContainer(context),
          ],
        ),
      ),
    );
  }

  Widget _buildVerifyContainer(BuildContext context) {
    if (User().isPwdVerificationMode()) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0),
            child: Text(AppLocalizations.of(context)!.verifyCodeInfoLabel,
                style: CustomTextStyles.bodyGrey),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0),
            child: TextButton(
              style: CustomButtonStyles.themeButtonyStyle(context),
              child: Text(
                AppLocalizations.of(context)!.enterRegistrationCode,
                style: CustomTextStyles.bodyWhite,
              ),
              onPressed: User().isProcessing
                  ? null
                  : () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) =>
                            ChangeNotifierProvider.value(
                                value: User(), child: VerifyScreen()),
                      ));
                    },
            ),
          ),
        ],
      );
    } else {
      return Container();
    }
  }
}
