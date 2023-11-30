import 'package:flutter/material.dart';
import 'package:erzmobil_driver/Constants.dart';
import 'package:erzmobil_driver/model/RequestState.dart';
import 'package:erzmobil_driver/model/User.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class VerifyScreen extends StatefulWidget {
  @override
  _VerifyScreenState createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final _nameFormKey = GlobalKey<FormState>();
  final _codeFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  bool _mailEntered = false;
  bool _codeEntered = false;
  bool _pwdEntered = false;

  String? _tmpPwd;
  String? _tmpMail;
  String? _tmpCode;

  final RegExp _regExpUpperCase = RegExp(r'[A-Z]');
  final RegExp _regExpLowerCase = RegExp(r'[a-z]');
  final RegExp _regExpNumbers = RegExp(r'\d');
  final RegExp _regExpSpecial = RegExp(r'\W');

  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
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
        centerTitle: true,
        title: Text(AppLocalizations.of(context)!.forgotPassword),
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
        actions: null,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(50.0, 30.0, 50.0, 10.0),
              alignment: Alignment.topCenter,
              child: new Image.asset(
                Strings.assetPathLogo,
                fit: BoxFit.cover,
                repeat: ImageRepeat.noRepeat,
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 30.0),
              child: Text(AppLocalizations.of(context)!.changePwdInfoLabel,
                  style: CustomTextStyles.bodyGrey),
            ),
            Form(
              key: _nameFormKey,
              onChanged: () => setState(
                  () => _mailEntered = _nameFormKey.currentState!.validate()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 10.0),
                    child: TextFormField(
                      style: CustomTextStyles.bodyGrey,
                      keyboardType: TextInputType.emailAddress,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      autocorrect: false,
                      enabled: !User().isProcessing,
                      decoration: new InputDecoration(
                          labelText:
                              AppLocalizations.of(context)!.placeholderEmail,
                          labelStyle: CustomTextStyles.bodyLightGrey,
                          errorMaxLines: 2),
                      validator: (value) {
                        if (value!.isEmpty ||
                            !Expressions.regExpName.hasMatch(value)) {
                          return AppLocalizations.of(context)!.eMailValidation;
                        }
                        return null;
                      },
                      onSaved: (String? name) {
                        _tmpMail = name;
                      },
                    ),
                  )
                ],
              ),
            ),
            Form(
              key: _codeFormKey,
              onChanged: () => setState(
                  () => _codeEntered = _codeFormKey.currentState!.validate()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 10.0),
                    child: TextFormField(
                      style: CustomTextStyles.bodyGrey,
                      keyboardType: TextInputType.number,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      autocorrect: false,
                      enabled: !User().isProcessing,
                      decoration: new InputDecoration(
                          labelText: AppLocalizations.of(context)!.codeHint,
                          labelStyle: CustomTextStyles.bodyLightGrey,
                          errorMaxLines: 2),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return AppLocalizations.of(context)!.codeValidation;
                        }
                        return null;
                      },
                      onSaved: (String? code) {
                        _tmpCode = code;
                      },
                    ),
                  )
                ],
              ),
            ),
            Form(
              key: _passwordFormKey,
              onChanged: () => setState(() =>
                  _pwdEntered = _passwordFormKey.currentState!.validate()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 20.0),
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      obscureText: true,
                      style: CustomTextStyles.bodyGrey,
                      autocorrect: false,
                      enabled: !User().isProcessing,
                      controller: controller,
                      decoration: new InputDecoration(
                          labelText:
                              AppLocalizations.of(context)!.placeholderPassword,
                          labelStyle: CustomTextStyles.bodyLightGrey,
                          errorMaxLines: 3),
                      validator: (value) {
                        if (value!.isEmpty ||
                            value.length < 8 ||
                            !_regExpLowerCase.hasMatch(value) ||
                            !_regExpUpperCase.hasMatch(value) ||
                            !_regExpNumbers.hasMatch(value) ||
                            !_regExpSpecial.hasMatch(value)) {
                          return AppLocalizations.of(context)!.passwordHint;
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
              margin: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0),
              child: FlatButton(
                padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 15.0),
                color: CustomColors.marine,
                disabledColor: CustomColors.lightGrey,
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(10.0),
                ),
                child: User().isProgressReset
                    ? new CircularProgressIndicator()
                    : Text(
                        AppLocalizations.of(context)!.buttonSendPwd,
                        style: CustomTextStyles.bodyWhite,
                      ),
                onPressed: _mailEntered &&
                        _pwdEntered &&
                        _codeEntered &&
                        !User().isProcessing
                    ? () {
                        _nameFormKey.currentState!.save();
                        _passwordFormKey.currentState!.save();
                        _codeFormKey.currentState!.save();

                        _changePwd(context);
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _changePwd(BuildContext context) async {
    RequestState state =
        await User().completeForgotPwd(_tmpMail, _tmpCode, _tmpPwd);
    if (state == RequestState.SUCCESS) {
      _showDialog(
          AppLocalizations.of(context)!.dialogInfoTitle,
          AppLocalizations.of(context)!.dialogResetPwdSuccessText,
          context,
          true);
    } else if (state == RequestState.ERROR_EXPIRED_CODE) {
      _showDialog(
          AppLocalizations.of(context)!.dialogErrorTitle,
          AppLocalizations.of(context)!.dialogExpiredCodeErrorText,
          context,
          false);
    } else if (state == RequestState.ERROR_WRONG_CODE) {
      _showDialog(
          AppLocalizations.of(context)!.dialogErrorTitle,
          AppLocalizations.of(context)!.dialogWrongCodeErrorText,
          context,
          false);
    } else {
      _showDialog(AppLocalizations.of(context)!.dialogErrorTitle,
          AppLocalizations.of(context)!.dialogGenericErrorText, context, false);
    }
  }

  Future<void> _showDialog(String title, String message, BuildContext context,
      bool popToFirst) async {
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
            FlatButton(
              child: Text(
                'OK',
                style: CustomTextStyles.bodyAzure,
              ),
              onPressed: () {
                popToFirst
                    ? Navigator.of(context).popUntil((route) => route.isFirst)
                    : Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
