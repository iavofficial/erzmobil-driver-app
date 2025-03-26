import 'package:erzmobil_driver/Constants.dart';
import 'package:erzmobil_driver/debug/Logger.dart';
import 'package:erzmobil_driver/model/RequestState.dart';
import 'package:erzmobil_driver/model/User.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstNameFormKey = GlobalKey<FormState>();
  final _lastNameFormKey = GlobalKey<FormState>();
  final _emailFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _passwordControlFormKey = GlobalKey<FormState>();
  final _phoneFormKey = GlobalKey<FormState>();
  final _addressFormKey = GlobalKey<FormState>();
  bool _firstNameEntered = false;
  bool _lastNameEntered = false;
  bool _addressEntered = false;
  bool _phoneNumberEntered = false;
  bool _emailEntered = false;
  bool _pwdEntered = false;
  bool _pwdControlEntered = false;

  String? _tmpEmail;
  String? _tmpPwd;
  String? _tmpFirstName;
  String? _tmpLastName;
  String? _tmpPhone;
  String? _tmpAddress;

  final RegExp _regExpUpperCase = RegExp(r'[A-Z]');
  final RegExp _regExpLowerCase = RegExp(r'[a-z]');
  final RegExp _regExpNumbers = RegExp(r'\d');
  final RegExp _regExpSpecial = RegExp(r'[\W_]');
  final RegExp _regExpPhoneNumber = RegExp(r'(^([+][0-9]{10,14})$)');

  TextEditingController controller = TextEditingController();

  String initialCountry = 'DE';
  PhoneNumber number = PhoneNumber(isoCode: 'DE');

  bool obscurePwd = true;
  bool obscureControlPwd = true;
  bool isPhoneNumberValid = true;

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
          User().resetViewedState();
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
        title: Text(AppLocalizations.of(context)!.signupTitle),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: CustomColors.backButtonIconColor,
          ),
        ),
        iconTheme:
            IconThemeData(color: CustomColors.mint, opacity: 1.0, size: 40.0),
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
            Form(
              key: _firstNameFormKey,
              onChanged: () => setState(
                () => _firstNameEntered =
                    _firstNameFormKey.currentState!.validate(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 5),
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      obscureText: false,
                      style: CustomTextStyles.themeStyleWhiteForDarkOrGrey(
                          context),
                      autocorrect: false,
                      enabled: !User().isProcessing,
                      decoration: new InputDecoration(
                          labelText: AppLocalizations.of(context)!
                              .placeholderGivenName,
                          labelStyle:
                              CustomTextStyles.themeStyleWhiteForDarkOrBlack(
                                  context),
                          errorMaxLines: 3),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return AppLocalizations.of(context)!
                              .firstNameValidation;
                        }
                        return null;
                      },
                      onSaved: (String? firstName) {
                        _tmpFirstName = firstName;
                      },
                    ),
                  ),
                ],
              ),
            ),
            Form(
              key: _lastNameFormKey,
              onChanged: () => setState(
                () => _lastNameEntered =
                    _lastNameFormKey.currentState!.validate(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 5.0),
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      obscureText: false,
                      style: CustomTextStyles.themeStyleWhiteForDarkOrGrey(
                          context),
                      autocorrect: false,
                      enabled: !User().isProcessing,
                      decoration: new InputDecoration(
                          labelText: AppLocalizations.of(context)!
                              .placeholderFamilyName,
                          labelStyle:
                              CustomTextStyles.themeStyleWhiteForDarkOrBlack(
                                  context),
                          errorMaxLines: 3),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return AppLocalizations.of(context)!
                              .lastNameValidation;
                        }
                        return null;
                      },
                      onSaved: (String? lastName) {
                        _tmpLastName = lastName;
                      },
                    ),
                  ),
                ],
              ),
            ),
            Form(
              key: _phoneFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 5.0),
                    child: InternationalPhoneNumberInput(
                      onInputChanged: (PhoneNumber number) {
                        Logger.debug("onInputChanged" + number.phoneNumber!);
                      },
                      onInputValidated: (bool value) {
                        setState(() {
                          isPhoneNumberValid = value;
                          _phoneNumberEntered = isPhoneNumberValid;
                        });
                      },
                      errorMessage: null,
                      selectorConfig: SelectorConfig(
                        selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                      ),
                      ignoreBlank: false,
                      autoValidateMode: AutovalidateMode.onUserInteraction,
                      hintText:
                          AppLocalizations.of(context)!.placeholderPhoneNumber,
                      textStyle: CustomTextStyles.themeStyleWhiteForDarkOrBlack(
                          context),
                      selectorTextStyle:
                          CustomTextStyles.themeStyleWhiteForDarkOrBlack(
                              context),
                      initialValue: number,
                      formatInput: false,
                      keyboardType: TextInputType.numberWithOptions(
                          signed: true, decimal: true),
                      inputBorder: OutlineInputBorder(),
                      onSaved: (PhoneNumber number) {
                        print('On Saved: $number.phoneNumber');
                        List<String> numbers =
                            number.phoneNumber!.split(number.dialCode!);
                        if (numbers.isNotEmpty) {
                          final RegExp regExpNum = RegExp(r'^0+(?!$)');
                          String phoneNumber =
                              numbers[1].replaceAll(regExpNum, "");
                          _tmpPhone = "${number.dialCode}" + "$phoneNumber";
                          print('Phone: $_tmpPhone');
                        }
                      },
                    ),
                  ),
                  Offstage(
                    offstage: isPhoneNumberValid,
                    child: Container(
                      margin: EdgeInsets.fromLTRB(20.0, 0, 20.0, 10),
                      child: Text(
                        AppLocalizations.of(context)!.phoneNumberValidation,
                        style: CustomTextStyles.bodyRedVerySmall,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Form(
              key: _addressFormKey,
              onChanged: () => setState(
                () =>
                    _addressEntered = _addressFormKey.currentState!.validate(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 5.0),
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      obscureText: false,
                      style: CustomTextStyles.themeStyleWhiteForDarkOrGrey(
                          context),
                      autocorrect: false,
                      enabled: !User().isProcessing,
                      decoration: new InputDecoration(
                          labelText:
                              AppLocalizations.of(context)!.placeholderAddress,
                          labelStyle:
                              CustomTextStyles.themeStyleWhiteForDarkOrBlack(
                                  context),
                          errorMaxLines: 3),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return AppLocalizations.of(context)!
                              .addressValidation;
                        }
                        return null;
                      },
                      onSaved: (String? address) {
                        _tmpAddress = address;
                      },
                    ),
                  ),
                ],
              ),
            ),
            Form(
              key: _emailFormKey,
              onChanged: () => setState(
                () => _emailEntered = _emailFormKey.currentState!.validate(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 5.0),
                    child: TextFormField(
                      style: CustomTextStyles.themeStyleWhiteForDarkOrGrey(
                          context),
                      keyboardType: TextInputType.emailAddress,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      autocorrect: false,
                      enabled: !User().isProcessing,
                      decoration: new InputDecoration(
                          labelText:
                              AppLocalizations.of(context)!.placeholderEmail,
                          labelStyle:
                              CustomTextStyles.themeStyleWhiteForDarkOrBlack(
                                  context),
                          errorMaxLines: 2),
                      validator: (value) {
                        if (value!.isEmpty ||
                            !Expressions.regExpName.hasMatch(value)) {
                          return AppLocalizations.of(context)!.eMailValidation;
                        }
                        return null;
                      },
                      onSaved: (String? email) {
                        _tmpEmail = email;
                      },
                    ),
                  ),
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
                    margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      obscureText: obscurePwd,
                      style: CustomTextStyles.themeStyleWhiteForDarkOrGrey(
                          context),
                      autocorrect: false,
                      enabled: !User().isProcessing,
                      controller: controller,
                      decoration: new InputDecoration(
                          suffixIcon: IconButton(
                              icon: Icon(
                                obscurePwd
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? CustomColors.white
                                    : CustomColors.black,
                                size: 18,
                              ),
                              onPressed: () {
                                setState(() {
                                  obscurePwd = !obscurePwd;
                                });
                              }),
                          labelText:
                              AppLocalizations.of(context)!.placeholderPassword,
                          labelStyle:
                              CustomTextStyles.themeStyleWhiteForDarkOrBlack(
                                  context),
                          errorMaxLines: 4),
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
            Form(
              key: _passwordControlFormKey,
              onChanged: () => setState(() => _pwdControlEntered =
                  _passwordControlFormKey.currentState!.validate()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      obscureText: obscureControlPwd,
                      style: CustomTextStyles.themeStyleWhiteForDarkOrGrey(
                          context),
                      autocorrect: false,
                      enabled: !User().isProcessing,
                      decoration: new InputDecoration(
                          suffixIcon: IconButton(
                              icon: Icon(
                                obscureControlPwd
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? CustomColors.white
                                    : CustomColors.black,
                                size: 18,
                              ),
                              onPressed: () {
                                setState(() {
                                  obscureControlPwd = !obscureControlPwd;
                                });
                              }),
                          labelText: AppLocalizations.of(context)!
                              .placeholderPasswordRepetition,
                          labelStyle:
                              CustomTextStyles.themeStyleWhiteForDarkOrBlack(
                                  context),
                          errorMaxLines: 4),
                      validator: (value) {
                        if (value != controller.text) {
                          return AppLocalizations.of(context)!
                              .passwordControlHint;
                        } else if (value!.isEmpty ||
                            value.length < 8 ||
                            !_regExpLowerCase.hasMatch(value) ||
                            !_regExpUpperCase.hasMatch(value) ||
                            !_regExpNumbers.hasMatch(value) ||
                            !_regExpSpecial.hasMatch(value)) {
                          return AppLocalizations.of(context)!.passwordHint;
                        }
                        return null;
                      },
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              child: TextButton(
                style: CustomButtonStyles.themeButtonyStyle(context),
                child: User().isProgressRegister
                    ? new CircularProgressIndicator()
                    : Text(
                        AppLocalizations.of(context)!.signup,
                        style: CustomTextStyles.bodyWhite,
                      ),
                onPressed: _emailEntered &&
                        _pwdEntered &&
                        _pwdControlEntered &&
                        _firstNameEntered &&
                        _lastNameEntered &&
                        _addressEntered &&
                        _phoneNumberEntered &&
                        !User().isProcessing
                    ? () {
                        _emailFormKey.currentState!.save();
                        _passwordFormKey.currentState!.save();
                        _firstNameFormKey.currentState!.save();
                        _lastNameFormKey.currentState!.save();
                        _phoneFormKey.currentState!.save();
                        _addressFormKey.currentState!.save();

                        _register(context);
                      }
                    : _validateAllFields,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _validateAllFields() {
    _emailFormKey.currentState!.save();
    _passwordFormKey.currentState!.validate();
    _passwordControlFormKey.currentState!.validate();
    _firstNameFormKey.currentState!.validate();
    _lastNameFormKey.currentState!.validate();
    _phoneFormKey.currentState!.validate();
    _addressFormKey.currentState!.validate();
    _emailFormKey.currentState!.validate();
  }

  void _register(BuildContext context) async {
    RequestState state = await User().register(_tmpEmail, _tmpPwd,
        _tmpFirstName, _tmpLastName, _tmpAddress, _tmpPhone, context);
    if (state == RequestState.SUCCESS) {
      _showDialog(
          AppLocalizations.of(context)!.dialogInfoTitle,
          AppLocalizations.of(context)!.dialogRegisterAccountText,
          context,
          true);
    } else if (state == RequestState.ERROR_USER_EXISTS) {
      _showDialog(
          AppLocalizations.of(context)!.dialogErrorTitle,
          AppLocalizations.of(context)!.dialogUserExistsErrorText,
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
                  style: CustomTextStyles.themeStyleWhiteForDarkOrGrey(context),
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
