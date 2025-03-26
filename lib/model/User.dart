import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:erzmobil_driver/Amazon.dart';
import 'package:erzmobil_driver/Constants.dart';
import 'package:erzmobil_driver/debug/Logger.dart';
import 'package:erzmobil_driver/location/LocationMangager.dart';
import 'package:erzmobil_driver/model/BusPosition.dart';
import 'package:erzmobil_driver/model/BusStopList.dart';
import 'package:erzmobil_driver/model/CognitoData.dart';
import 'package:erzmobil_driver/model/DirectusToken.dart';
import 'package:erzmobil_driver/model/PhoneNumberList.dart';
import 'package:erzmobil_driver/model/PreferenceHolder.dart';
import 'package:erzmobil_driver/model/ProgressState.dart';
import 'package:erzmobil_driver/model/RequestState.dart';
import 'package:erzmobil_driver/model/TourList.dart';
import 'package:erzmobil_driver/model/Tours.dart';
import 'package:erzmobil_driver/model/database/DatabaseProvider.dart';
import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:erzmobil_driver/push/PushNotificationService.dart';
import 'package:erzmobil_driver/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:path_provider/path_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';
import 'Bus.dart';

class User extends ChangeNotifier with LocationListener {
  static final User _instance = new User._internal();

  bool _isMainTosViewed = true;
  bool _isHeatTosViewed = true;
  bool _isPrivacyDataViewed = true;
  bool _isCognitoInitialized = false;
  CognitoData? _cognitoData;

  static const int TIMEOUT_DURATION = 60;

  bool isProcessing = false;
  bool isDebugProcessing = false;
  ProgressState _currentProgressState = ProgressState.NONE;

  int? id;
  String? _name;
  String? email;
  String? _address;
  String? _phoneNumber;
  String? _firstName;
  String? tmpAcceptedRegisterVersions;
  bool _isActive = true;

  TourList? tourList;
  BusStopList? stopList;

  List<Bus>? buses;
  List? busIds;

  int? _finishedTourIndex;
  int? _activeTourId;
  Tour? currentRoute;
  int activeNodeIdx = 0;
  Position? _currentLocation;
  bool inStopRange = false;
  int distanceToStop = 0;

  SharedPreferences? _sharedPreferences = PreferenceHolder().getPreferences();
  DatabaseProvider _databaseProvider = DatabaseProvider();
  CognitoUser? _cognitoUser;
  CognitoUserSession? _cognitoUserSession;

  bool useDirectus = true;
  DirectusToken? directusToken;
  DateTime? directusTokenExpirationDate;

  factory User() {
    return _instance;
  }

  User._internal();

  void resetViewedState() {
    _isMainTosViewed = true;
    _isHeatTosViewed = true;
    _isPrivacyDataViewed = true;
  }

  bool get isMainTosViewed {
    return _isMainTosViewed;
  }

  set isMainTosViewed(bool viewed) {
    this._isMainTosViewed = viewed;
  }

  bool get isHeatTosViewed {
    return _isHeatTosViewed;
  }

  set isHeatTosViewed(bool viewed) {
    this._isHeatTosViewed = viewed;
    notifyListeners();
  }

  bool get isPrivacyDataViewed {
    return _isPrivacyDataViewed;
  }

  set isPrivacyDataViewed(bool viewed) {
    this._isPrivacyDataViewed = viewed;
  }

  Future<void> deleteLogs() async {
    _setDebugProcessing(true);
    Directory? externalDirectory;
    File? zipFile;
    try {
      if (Platform.isIOS) {
        externalDirectory = await getApplicationDocumentsDirectory();
      } else {
        externalDirectory = await getExternalStorageDirectory();
      }

      String path = externalDirectory!.path +
          "/" +
          Strings.logsWriteDirectoryName +
          "/" +
          Strings.logsExportDirectoryName;
      final dir = Directory(path);
      dir.deleteSync(recursive: true);
    } catch (e) {
      Logger.e("Delete exported logfiles in path not.");
    }

    FlutterLogs.clearLogs();
    _setDebugProcessing(false);
  }

  Future<Tuple2<int, int>> sizeLogs() async {
    _setDebugProcessing(true);
    int numberFiles = 0;
    int totalFileSize = 0;
    Tuple2<int, int> tuple;

    Directory? externalDirectory;
    try {
      if (Platform.isIOS) {
        externalDirectory = await getApplicationDocumentsDirectory();
      } else {
        externalDirectory = await getExternalStorageDirectory();
      }

      String path = externalDirectory!.path +
          "/" +
          Strings.logsWriteDirectoryName +
          "/" +
          Strings.logFilesDirectoryName;
      final dir = Directory(path);
      if (await dir.exists()) {
        await for (var entity
            in dir.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            final fileSize = await entity.length();
            numberFiles += 1;
            totalFileSize += fileSize;
            print('File: ${entity.path}, Size: $fileSize bytes');
          }
        }
      } else {
        print('Directory does not exist');
      }
    } catch (e) {
      Logger.e("Error on checking size for logfiles in path.");
    }
    tuple = Tuple2(numberFiles, totalFileSize);
    _setDebugProcessing(false);
    return tuple;
  }

  Future<void> sendLogs() async {
    _setDebugProcessing(true);

    await Logger.exportAllLogs().then((value) async {
      //zip file
      Directory? externalDirectory;
      File? zipFile;
      try {
        if (Platform.isIOS) {
          externalDirectory = await getApplicationDocumentsDirectory();
        } else {
          externalDirectory = await getExternalStorageDirectory();
        }

        FlutterLogs.logInfo(
            "ErzMobil-Driver", "found", 'External Storage:$externalDirectory');

        zipFile = File("${externalDirectory!.path}/$value");

        if (zipFile.existsSync()) {
          Logger.info("Logs found and ready to export!");
          StringBuffer buffer = StringBuffer();
          buffer.write(
              'Bitte teilen Sie uns mit, warum Sie uns dieses Log schicken.\nPlease tell us why you are sending the log file.\n\n');
          DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
          if (Platform.isIOS) {
            IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
            buffer.write('systemVersion: ${iosInfo.systemVersion} \n');
            buffer.write('model: ${iosInfo.model} \n');
            buffer.write('name: ${iosInfo.name} \n');
          } else {
            AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
            buffer.write('version.baseOS: ${androidInfo.version.baseOS} \n');
            buffer.write('manufacturer: ${androidInfo.manufacturer} \n');
            buffer.write('model: ${androidInfo.model} \n');
          }

          //sendZip
          final Email email = Email(
            body: buffer.toString(),
            subject: 'Erzmobil User App Logs',
            recipients: ['erzmobil@smartcity-zwoenitz.de'],
            attachmentPaths: [zipFile.path],
            isHTML: false,
          );

          try {
            await FlutterEmailSender.send(email);
          } catch (e) {
            print(e);
          }
        } else {
          Logger.e("File not found in storage.");
        }
      } catch (e) {
        print(e);
      }
    });

    _setDebugProcessing(false);
  }

  Future<RequestState> login(String? pwd, BuildContext context) async {
    RequestState retVal = RequestState.ERROR_FAILED;
    if (_isCognitoInitialized && email != null && pwd != null) {
      _setProcessing(true, ProgressState.LOGIN);
      _cognitoUser = new CognitoUser(email, Amazon.userPool,
          storage: Amazon.userPool.storage);
      try {
        _cognitoUserSession = await _cognitoUser!.authenticateUser(
            AuthenticationDetails(username: email, password: pwd));
        await _cognitoUser!.cacheTokens();
        _setPwdVerificationMode(false);
        _isActive = true;
        User? user = await _databaseProvider.getUser(email!);
        if (user == null) {
          id = await _databaseProvider.insert(this);
        }

        Logger.info("stored user with $id");
        retVal = RequestState.SUCCESS;
      } on CognitoUserNewPasswordRequiredException catch (e) {
        Logger.error(e, StackTrace.current);
        // handle New Password challenge
      } on CognitoUserMfaRequiredException catch (e) {
        Logger.error(e, StackTrace.current);
        // handle SMS_MFA challenge
      } on CognitoUserSelectMfaTypeException catch (e) {
        Logger.error(e, StackTrace.current);
        // handle SELECT_MFA_TYPE challenge
      } on CognitoUserMfaSetupException catch (e) {
        Logger.error(e, StackTrace.current);
        // handle MFA_SETUP challenge
      } on CognitoUserTotpRequiredException catch (e) {
        Logger.error(e, StackTrace.current);
        // handle SOFTWARE_TOKEN_MFA challenge
      } on CognitoUserCustomChallengeException catch (e) {
        Logger.error(e, StackTrace.current);
        // handle CUSTOM_CHALLENGE challenge
      } on CognitoUserConfirmationNecessaryException catch (e) {
        Logger.error(e, StackTrace.current);
        retVal = RequestState.ERROR_CONFIRMATION_NECESSARY;
      } on CognitoClientException catch (e) {
        Logger.error(e, StackTrace.current);
        final bool isConnected =
            await InternetConnectionChecker.instance.hasConnection;
        if (!isConnected) {
          Logger.info("ERROR_FAILED_NO_INTERNET");
          retVal = RequestState.ERROR_FAILED_NO_INTERNET;
        }
        if (e.code == 'NotAuthorizedException') {
          retVal = RequestState.ERROR_WRONG_CREDENTIALS;
        }
        if (e.code == 'UserNotConfirmedException') {
          retVal = RequestState.ERROR_CONFIRMATION_NECESSARY;
        }
        if (e.code == 'UserNotFoundException') {
          Logger.error(e, StackTrace.current);
          retVal = RequestState.ERROR_USER_UNKNOWN;
        }
      } catch (e) {
        Logger.error(e, StackTrace.current);
      }
      await loadPublicDataFromBE();
      _setProcessing(false, ProgressState.NONE);
    }

    return retVal;
  }

  Future<RequestState> deleteUser() async {
    RequestState retVal = RequestState.ERROR_FAILED;
    _setProcessing(true, ProgressState.DELETE);
    bool userDeleted = false;
    await _refreshSessionIfNeeded();
    try {
      userDeleted = await _cognitoUser!.deleteUser();
      if (userDeleted) {
        await deleteFirebaseToken(
            await PushNotificationService().getFCMToken());
        await _cognitoUser!.clearCachedTokens();
        await _databaseProvider.delete(this);
        _reset();
        retVal = RequestState.SUCCESS;
      }
    } on SocketException catch (e) {
      retVal = RequestState.ERROR_FAILED_NO_INTERNET;
      Logger.info("ERROR_FAILED_NO_INTERNET");
      Logger.error(e, StackTrace.current);
    } catch (e) {
      final bool isConnected =
          await InternetConnectionChecker.instance.hasConnection;
      if (!isConnected) {
        retVal = RequestState.ERROR_FAILED_NO_INTERNET;
        Logger.info("ERROR_FAILED_NO_INTERNET");
      }
    }
    _setProcessing(false, ProgressState.NONE);
    return retVal;
  }

  Future<RequestState> startForgotPwd(String? email) async {
    RequestState retVal = RequestState.ERROR_FAILED;
    _setProcessing(true, ProgressState.RESET);
    if (_isCognitoInitialized) {
      CognitoUser user = CognitoUser(email, Amazon.userPool);
      try {
        await user.forgotPassword();
        _setPwdVerificationMode(true);
        retVal = RequestState.SUCCESS;
      } on CognitoClientException catch (e) {
        Logger.error(e, StackTrace.current);
        final bool isConnected =
            await InternetConnectionChecker.instance.hasConnection;
        if (!isConnected) {
          retVal = RequestState.ERROR_FAILED_NO_INTERNET;
          Logger.info("ERROR_FAILED_NO_INTERNET");
        } else if (e.code == 'ResourceNotFoundException') {
          retVal = RequestState.ERROR_USER_UNKNOWN;
        }
      } catch (e) {
        Logger.error(e, StackTrace.current);
      }
    }
    _setProcessing(false, ProgressState.NONE);
    return retVal;
  }

  Future<RequestState> completeForgotPwd(
      String? email, String? code, String? pwd) async {
    RequestState retVal = RequestState.ERROR_FAILED;
    _setProcessing(true, ProgressState.RESET);
    CognitoUser user = CognitoUser(email, Amazon.userPool);
    try {
      if (await user.confirmPassword(code!, pwd!)) {
        _setPwdVerificationMode(false);
        retVal = RequestState.SUCCESS;
      }
    } on CognitoClientException catch (e) {
      Logger.error(e, StackTrace.current);
      //this exception will be thrown if user is unknown or code is expired
      if (e.code == 'ExpiredCodeException') {
        retVal = RequestState.ERROR_EXPIRED_CODE;
      }
      if (e.code == 'CodeMismatchException') {
        retVal = RequestState.ERROR_WRONG_CODE;
      }
    } catch (e) {
      Logger.error(e, StackTrace.current);
    }
    _setProcessing(false, ProgressState.NONE);
    return retVal;
  }

  Future<RequestState> resendConfirmationCode(String? email) async {
    RequestState retVal = RequestState.ERROR_FAILED;
    _setProcessing(true, ProgressState.CONFIRM);
    if (_isCognitoInitialized) {
      CognitoUser user = CognitoUser(email, Amazon.userPool);
      try {
        await user.resendConfirmationCode();
        retVal = RequestState.SUCCESS;
      } on CognitoClientException catch (e) {
        Logger.error(e, StackTrace.current);
      } catch (e) {
        Logger.error(e, StackTrace.current);
      }
    }
    _setProcessing(false, ProgressState.NONE);
    return retVal;
  }

  Future<RequestState> register(
      String? mailAddress,
      String? pwd,
      String? firstName,
      String? lastName,
      String? address,
      String? phoneNumber,
      BuildContext context) async {
    RequestState retVal = RequestState.ERROR_FAILED;
    _setProcessing(true, ProgressState.REGISTER);

    final List<AttributeArg> userAttributes = phoneNumber != null
        ? [
            new AttributeArg(name: 'given_name', value: firstName),
            new AttributeArg(name: 'name', value: lastName),
            new AttributeArg(name: 'address', value: address),
            new AttributeArg(name: 'email', value: mailAddress),
            new AttributeArg(name: 'phone_number', value: phoneNumber)
          ]
        : [
            new AttributeArg(name: 'given_name', value: firstName),
            new AttributeArg(name: 'name', value: lastName),
            new AttributeArg(name: 'address', value: address),
            new AttributeArg(name: 'email', value: mailAddress),
          ];

    if (_isCognitoInitialized) {
      try {
        CognitoUserPoolData data = await Amazon.userPool
            .signUp(mailAddress!, pwd!, userAttributes: userAttributes);
        if (data != null) {
          _cognitoUser = data.user;
          /*try {
          //cleanup already registered user which are not logged in
          await _databaseProvider.delete(this);
        } catch (e) {}*/
          this._name = lastName;
          this._firstName = firstName;
          this._phoneNumber = phoneNumber;
          this.email = mailAddress;
          this._address = address;

          id = await _databaseProvider.insert(this);
          retVal = RequestState.SUCCESS;
        }
      } on CognitoClientException catch (e) {
        if (e.code == 'UsernameExistsException') {
          retVal = RequestState.ERROR_USER_EXISTS;
        }
        Logger.error(e, StackTrace.current);
      } catch (e) {
        Logger.error(e, StackTrace.current);
      }
    }
    _setProcessing(false, ProgressState.NONE);
    return retVal;
  }

  Future<RequestState> logout() async {
    RequestState retVal = RequestState.ERROR_FAILED;
    _setProcessing(true, ProgressState.LOGOUT);
    await _refreshSessionIfNeeded();
    try {
      await deleteFirebaseToken(await PushNotificationService().getFCMToken());
      await _cognitoUser!.globalSignOut();
      await _cognitoUser!.clearCachedTokens();
      retVal = RequestState.SUCCESS;
    } catch (e) {
      Logger.error(e, StackTrace.current);
    }
    _isActive = false;
    await _databaseProvider.update(this);
    _reset();
    LocationManager().unregister(this);

    _setProcessing(false, ProgressState.NONE);
    return retVal;
  }

  /// Handles session refresh. Used due to problematic secure storage handling. Otherwise user.getSession() would be enough.
  Future<void> _refreshSessionIfNeeded() async {
    if (useDirectus &&
        directusToken != null &&
        directusToken!.expires != null &&
        directusTokenExpirationDate != null) {
      DateTime now = DateTime.now();

      Logger.info("directusTokenExpirationDate: " +
          directusTokenExpirationDate!.toLocal().toIso8601String());

      if (now.isAfter(directusTokenExpirationDate!.toLocal())) {
        Logger.info("Directus token expired, refresh session");
        await loadDirectusToken();
      }
    }
    if (!_cognitoUserSession!.isValid()) {
      try {
        Logger.info("Cognito session expired, refresh session");
        _cognitoUserSession = await _cognitoUser!.refreshSession(
            CognitoRefreshToken(
                _cognitoUserSession!.getRefreshToken()!.getToken()));
      } catch (e) {
        Logger.error(e, StackTrace.current);
      }
    }
  }

  bool isLoggedIn() {
    return id != null && _cognitoUser != null && _cognitoUserSession != null;
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      DatabaseProvider.columnMail: email,
    };

    if (_name != null) {
      map[DatabaseProvider.columnName] = _name;
    }

    if (_firstName != null) {
      map[DatabaseProvider.columnFirstName] = _firstName;
    }

    if (_address != null) {
      map[DatabaseProvider.columnAddress] = _address;
    }

    if (_phoneNumber != null) {
      map[DatabaseProvider.columnPhone] = _phoneNumber;
    }

    if (id != null) {
      map[DatabaseProvider.columnId] = id;
    }

    if (_activeTourId != null) {
      map[DatabaseProvider.columnActiveTourId] = _activeTourId;
    } else {
      map[DatabaseProvider.columnActiveTourId] = -1;
    }
    if (_finishedTourIndex != null) {
      map[DatabaseProvider.columnFinishedTourIndex] = _finishedTourIndex;
    } else {
      map[DatabaseProvider.columnFinishedTourIndex] = -1;
    }

    if (tmpAcceptedRegisterVersions != null) {
      map[DatabaseProvider.columnRegisteredVersions] =
          tmpAcceptedRegisterVersions;
    }

    map[DatabaseProvider.columnIsActive] = _isActive ? 1 : 0;

    return map;
  }

  User.fromMap(map) {
    User().id = map[DatabaseProvider.columnId];
    User()._name = map[DatabaseProvider.columnName];
    User()._firstName = map[DatabaseProvider.columnFirstName];
    User().email = map[DatabaseProvider.columnMail];
    User()._address = map[DatabaseProvider.columnAddress];
    User()._phoneNumber = map[DatabaseProvider.columnPhone];
    int? tourId = map[DatabaseProvider.columnActiveTourId];
    User()._activeTourId = tourId != -1 ? tourId : null;
    int? tourIndex = map[DatabaseProvider.columnFinishedTourIndex];
    User()._finishedTourIndex = tourIndex != -1 ? tourIndex : null;
    User().tmpAcceptedRegisterVersions =
        map[DatabaseProvider.columnRegisteredVersions];
  }

  /// Restores cached session from store (refresh if session is not valid any more).
  Future<void> restoreSessionFromStore() async {
    //we have a user in our database
    if (_isCognitoInitialized && email != null) {
      _cognitoUser = await Amazon.userPool.getCurrentUser();
      if (_cognitoUser != null) {
        try {
          _cognitoUserSession = await _cognitoUser!.getSession();
        } catch (e) {
          //we have no valid session and refresh is not possible
          _cognitoUser = null;
          Logger.error(e, StackTrace.current);
        }
      } else if (tmpAcceptedRegisterVersions == null) {
        //clear user data if we have not registered otherwise keep data without session --> login possible
        try {
          await _databaseProvider.delete(this);
        } catch (e) {}
        _reset();
      }
    }
  }

  void initActiveTourData() {
    if (currentRoute == null) {
      Logger.info("Active Tour: currentRoute is null, determine current tour");
      currentRoute = _determineCurrentTour();
    }

    if (currentRoute != null && currentRoute!.nodes != null) {
      LocationManager().initLocationService();
      LocationManager().register(this);

      if (_finishedTourIndex == null || _finishedTourIndex == -1) {
        // tour just started
        activeNodeIdx = 0;
      } else {
        if (_finishedTourIndex != null &&
            _finishedTourIndex! + 1 < currentRoute!.nodes!.length) {
          activeNodeIdx = _finishedTourIndex! + 1;
        }
      }

      TourNode currentActiveNode = currentRoute!.nodes![activeNodeIdx];
      _currentLocation = LocationManager().getCurrentLocation();
      Logger.info("Active Tour: Start tour at active node : " +
          activeNodeIdx.toString() +
          " " +
          currentActiveNode.label);
      if (_currentLocation != null) {
        Tuple2 result =
            Utils.isWithInStopRange(currentActiveNode, _currentLocation!);
        inStopRange = result.item1;
        distanceToStop = result.item2;
      }
    }
  }

  void resetActiveTourData() {
    Logger.info("Active Tour: reset active tour");
    _activeTourId = null;
    currentRoute = null;
    _finishedTourIndex = null;
    activeNodeIdx = 0;
    inStopRange = false;
    LocationManager().unregister(this);
  }

  Future<void> saveTourData(int lastTourIndex) async {
    _finishedTourIndex = lastTourIndex;

    try {
      await _databaseProvider.update(this);
      Logger.info("Active Tour: saved tour index: " + lastTourIndex.toString());
    } catch (e) {
      Logger.error(e, StackTrace.current);
    }
  }

  @override
  void onLocationChanged(Position location) {
    if (_activeTourId != null && currentRoute == null) {
      Logger.info("Active Tour: _activeTourId: " + _activeTourId.toString());
      currentRoute = _determineCurrentTour();
    }
    if (currentRoute == null) {
      return;
    }

    TourNode currentActiveNode = currentRoute!.nodes![activeNodeIdx];
    Tuple2 result = Utils.isWithInStopRange(currentActiveNode, location);
    bool isCurrentActiveNodeInNewLocationRange = result.item1;
    distanceToStop = result.item2;

    if (!inStopRange && isCurrentActiveNodeInNewLocationRange) {
      Logger.info(
          "Active Tour: Arrived at bus stop: " + currentActiveNode.label);
    }
    // if activeStop was in range before but is not anymore,
    // --> bus left stop and is on its way to the next stop, increment activeNodeIndex & save
    else if (inStopRange && !isCurrentActiveNodeInNewLocationRange) {
      Logger.info("Active Tour: left bus stop: " + currentActiveNode.label);
      User().saveLastNodeIdx(activeNodeIdx);
      if (currentRoute!.nodes!.length - 1 != activeNodeIdx) {
        activeNodeIdx++;

        while (isNextStopIdentical(currentActiveNode)) {
          User().saveLastNodeIdx(activeNodeIdx);
          activeNodeIdx++;
        }
      }
    }

    inStopRange = isCurrentActiveNodeInNewLocationRange;
  }

  bool isNextStopIdentical(TourNode currentActiveNode) {
    TourNode next = currentRoute!.nodes![activeNodeIdx];
    if (currentActiveNode.latitude == next.latitude &&
        currentActiveNode.longitude == currentActiveNode.longitude) {
      Logger.info(
          "Active Tour: current stop and next stop are identical, increment active stop again");
      return true;
    }
    return false;
  }

  //no return type needed
  Future<void> loadPublicDataFromBE() async {
    if (!isLoggedIn()) {
      return null;
    }
    await loadDirectusToken();

    _setProcessing(true, ProgressState.UPDATE_STOPS);
    await loadStopList();

    await loadBuses();
    await loadTours();
    initActiveTourData();
    _setProcessing(false, ProgressState.NONE);
  }

  Future<RequestState> loadStopList() async {
    RequestState retVal = RequestState.ERROR_FAILED;

    await _refreshSessionIfNeeded();
    http.Response response;

    try {
      response = await http
          .get(
              Uri.parse(Amazon.baseUrl +
                  (useDirectus
                      ? Strings.STOPS_URL_DIRECTUS
                      : Strings.STOPS_URL_BACKEND)),
              headers:
                  new Map<String, String>.from({'Accept': 'application/json'}))
          .timeout(Duration(seconds: User.TIMEOUT_DURATION));

      BusStopList newStopList = BusStopList(response);
      if (newStopList.isSuccessful()) {
        retVal = RequestState.SUCCESS;
        stopList = newStopList;
      }
    } on SocketException {
      retVal = RequestState.ERROR_FAILED_NO_INTERNET;
      Logger.info("ERROR_FAILED_NO_INTERNET");
      if (stopList == null) {
        stopList = BusStopList(null);
        stopList!.markNotLoaded();
      }
    } catch (e) {
      Logger.error(e, StackTrace.current);
      if (stopList == null) {
        stopList = BusStopList(null);
        stopList!.markNotLoaded();
      }
    }

    if (stopList!.isSuccessful()) {
      try {
        stopList!.data.sort((a, b) =>
            a.name!.toLowerCase().compareTo(b.name!.toLowerCase().toString()));
      } catch (e) {
        Logger.e("Cannot sort bus stops");
      }
    }

    _setProcessing(false, ProgressState.NONE);
    return retVal;
  }

  Future<void> loadCognitoData() async {
    _setProcessing(true, ProgressState.REQUEST_COGNITO_DATA);

    if (useDirectus) {
      Logger.info("load Cognito data from backend");
      http.Response response;
      try {
        response = await http
            .get(Uri.parse(Amazon.baseUrl + Strings.COGNITO_DATA_URL_DIRECTUS),
                headers: new Map<String, String>.from(
                    {'Content-Type': 'application/json'}))
            .timeout(Duration(seconds: User.TIMEOUT_DURATION));

        Logger.info(response.request.toString());
        Logger.info("RESPONSE: " + response.statusCode.toString());
        if (response.statusCode == 200) {
          final parsed = jsonDecode(response.body);
          _cognitoData = CognitoData.fromJson(parsed);
          if (_cognitoData != null && _cognitoData!.isValid()) {
            Logger.info("Cognito data was loaded successfully");

            Amazon.initUserPool(
                _cognitoData!.userPoolId!, _cognitoData!.driverClientId!);
            _isCognitoInitialized = true;
          }
        }
      } on SocketException {
        Logger.info("ERROR_FAILED_NO_INTERNET");
      } catch (e) {
        Logger.error(e, StackTrace.current);
        Logger.info("Couldn't load cognito data");
      }
    } else {
      Logger.info("Using default cognito data");
      Amazon.initUserPool(Amazon.userPoolId, Amazon.clientId);
      _isCognitoInitialized = true;
    }

    _setProcessing(false, ProgressState.NONE);
  }

  Future<void> loadDirectusToken() async {
    _setProcessing(true, ProgressState.REQUEST_DIRECTUS_TOKEN);
    http.Response response;

    String? idToken = _cognitoUserSession!.getIdToken().getJwtToken();
    String? refreshToken = _cognitoUserSession!.getRefreshToken()!.getToken();
    String? clientId = _cognitoUser!.pool.getClientId();

    Logger.info('Cognito IdToken: $idToken');
    Logger.info('Cognito RefreshToken: $refreshToken');
    Logger.info('Cognito UserPool: $clientId');

    if (_isCognitoInitialized) {
      try {
        response = await http
            .post(Uri.parse(Amazon.baseUrl + '/awsmw/auth'),
                headers: new Map<String, String>.from(
                    {'Content-Type': 'application/json'}),
                body: json.encode({
                  "IdToken": '$idToken',
                  "RefreshToken": '$refreshToken',
                  "clientId": '$clientId'
                }))
            .timeout(Duration(seconds: User.TIMEOUT_DURATION));

        Logger.info(response.request.toString());
        Logger.info("RESPONSE: " + response.statusCode.toString());
        if (response.statusCode == 200) {
          final parsed = jsonDecode(response.body);
          directusToken = DirectusToken.fromJson(parsed);
          if (directusToken != null && directusToken!.expires != null) {
            directusTokenExpirationDate = directusToken!.expires!;
            Logger.info("Directus token: ${directusToken!.accessToken}");
            Logger.info("Token expires " +
                directusTokenExpirationDate!.toLocal().toIso8601String());
          } else {
            Logger.info("Couldn't get directus token");
          }
        }
      } on SocketException {
        Logger.info("ERROR_FAILED_NO_INTERNET");
      } catch (e) {
        Logger.error(e, StackTrace.current);
        Logger.info("Couldn't get directus token");
      }
    }

    _setProcessing(false, ProgressState.NONE);
  }

  Future<void> loadBuses() async {
    if (!isLoggedIn()) {
      return null;
    }

    _setProcessing(true, ProgressState.UPDATE_BUSES);

    await _refreshSessionIfNeeded();
    String? authorizationToken = useDirectus
        ? directusToken!.accessToken
        : _cognitoUserSession!.getAccessToken().getJwtToken();

    try {
      http.Response response = await http
          .get(
              Uri.parse(Amazon.baseUrl +
                  (useDirectus
                      ? Strings.COMMUNITY_BUSES_URL_DIRECTUS
                      : Strings.COMMUNITY_BUSES_URL_BACKEND)),
              headers: new Map<String, String>.from({
                'Accept': 'application/json',
                'Authorization': 'Bearer $authorizationToken'
              }))
          .timeout(Duration(seconds: TIMEOUT_DURATION));

      Logger.info(response.request.toString());
      Logger.info("RESPONSE: " + response.body.toString());
      Logger.info("RESPONSE: " + response.statusCode.toString());
      if (response.statusCode == 200) {
        final parsed = useDirectus
            ? jsonDecode(response.body)["data"].cast<Map<String, dynamic>>()
            : jsonDecode(response.body).cast<Map<String, dynamic>>();
        busIds = parsed.map<dynamic>((json) => json['id']).toList();
      }
    } catch (e) {
      Logger.error(e, StackTrace.current);
    }
  }

  Future<RequestState> loadTours() async {
    if (!isLoggedIn()) {
      return RequestState.ERROR_NOT_LOGGED_IN;
    }
    RequestState retVal = RequestState.ERROR_FAILED;

    _setProcessing(true, ProgressState.UPDATE_TOURS);
    http.Response response;

    if (busIds == null || busIds!.isEmpty) {
      Future.delayed(Duration(seconds: 1), () async {
        _setProcessing(false, ProgressState.NONE);
      });
      return retVal;
    }

    int busId = busIds![0];
    await _refreshSessionIfNeeded();

    try {
      response = await http
          .get(Uri.parse(Amazon.baseUrl + '/routes/buses/$busId'),
              headers: new Map<String, String>.from({
                'Accept': 'application/json',
                'Authorization':
                    'Bearer ${_cognitoUserSession!.getAccessToken().getJwtToken()}'
              }))
          .timeout(Duration(seconds: TIMEOUT_DURATION));
      Logger.info(response.request.toString());
      Logger.info("RESPONSE: " + response.statusCode.toString());
      TourList newTourList = TourList(response);
      if (newTourList.isSuccessful()) {
        retVal = RequestState.SUCCESS;
        tourList = newTourList;
      } else {
        if (tourList == null) {
          tourList = TourList(null);
        }
        tourList!.markNotLoaded();
      }
    } on TimeoutException catch (e) {
      if (tourList == null) {
        tourList = TourList(null);
      }
      tourList!.markNotLoaded();
      Logger.error(e, StackTrace.current);
      retVal = RequestState.ERROR_TIMEOUT;
      Logger.info("ERROR_TIMEOUT");
    } on SocketException catch (e) {
      if (tourList == null) {
        tourList = TourList(null);
      }
      tourList!.markNotLoaded();
      Logger.error(e, StackTrace.current);
      retVal = RequestState.ERROR_FAILED_NO_INTERNET;
      Logger.info("ERROR_FAILED_NO_INTERNET");
    } catch (e) {
      if (tourList == null) {
        tourList = TourList(null);
      }
      tourList!.markInvalid();
      _setProcessing(false, ProgressState.NONE);
      Logger.error(e, StackTrace.current);
    }

    if (tourList != null) {
      Tour? determinedTour = _determineCurrentTour();
      if (determinedTour != null &&
          currentRoute != null &&
          determinedTour != currentRoute) {
        Logger.info("Active tour might be invalid");
      }
    }

    _setProcessing(false, ProgressState.NONE);
    return retVal;
  }

  Future<RequestState> registerToken() async {
    RequestState retVal = RequestState.ERROR_FAILED;

    _setProcessing(true, ProgressState.REGISTER_TOKEN);
    String? token = await PushNotificationService().getFCMToken();
    String? authorizationToken = useDirectus
        ? directusToken!.accessToken
        : _cognitoUserSession!.getAccessToken().getJwtToken();

    if (token != null) {
      try {
        http.Response response = await http
            .post(
                Uri.parse(Amazon.baseUrl +
                    (useDirectus
                        ? Strings.TOKENS_URL_DIRECTUS
                        : Strings.TOKENS_URL_BACKEND + '/driver')),
                headers: new Map<String, String>.from({
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer $authorizationToken'
                }),
                body: json.encode({"fcmToken": token}))
            .timeout(Duration(seconds: TIMEOUT_DURATION));
        Logger.info("Body:" +
            json.encode(useDirectus
                ? {"fcmToken": token, "isDriver": true}
                : {"fcmToken": token}));
        Logger.info(response.request.toString());
        Logger.info("RESPONSE: " + response.body.toString());
        Logger.info("RESPONSE: " + response.statusCode.toString());
        if (response.statusCode == 201 ||
            response.statusCode == 204 ||
            response.statusCode == 200) {
          Logger.info("Firebase token successfully registered");
          retVal = RequestState.SUCCESS;
        }
      } on SocketException catch (e) {
        Logger.error(e, StackTrace.current);
        retVal = RequestState.ERROR_FAILED_NO_INTERNET;
        Logger.info("ERROR_FAILED_NO_INTERNET");
      } on TimeoutException catch (e) {
        Logger.error(e, StackTrace.current);
        retVal = RequestState.ERROR_TIMEOUT;
      } catch (e) {
        Logger.error(e, StackTrace.current);
      }
    }

    _setProcessing(false, ProgressState.NONE);

    return retVal;
  }

  Future<RequestState> deleteFirebaseToken(String? token) async {
    RequestState retVal = RequestState.ERROR_FAILED;
    _setProcessing(true, ProgressState.DELETE_TOKEN);
    http.Response response;

    await _refreshSessionIfNeeded();
    String? authorizationToken = useDirectus
        ? directusToken!.accessToken
        : _cognitoUserSession!.getAccessToken().getJwtToken();

    try {
      response = await http
          .delete(
              Uri.parse(Amazon.baseUrl +
                  (useDirectus
                      ? Strings.TOKENS_URL_DIRECTUS
                      : Strings.TOKENS_URL_BACKEND) +
                  '/$token'),
              headers: new Map<String, String>.from({
                'Accept': 'application/json',
                'Authorization': 'Bearer $authorizationToken'
              }))
          .timeout(Duration(seconds: TIMEOUT_DURATION));
      Logger.info(response.request.toString());
      Logger.info("RESPONSE: " + response.statusCode.toString());
      if (response.statusCode == 204) {
        retVal = RequestState.SUCCESS;
        Logger.info("Firebase token successfully deleted");
      }
    } on TimeoutException catch (e) {
      retVal = RequestState.ERROR_TIMEOUT;
      Logger.error(e, StackTrace.current);
      _setProcessing(false, ProgressState.NONE);
    } catch (e) {
      Logger.error(e, StackTrace.current);
      _setProcessing(false, ProgressState.NONE);
    }

    _setProcessing(false, ProgressState.NONE);

    return retVal;
  }

  Tour? _determineCurrentTour() {
    Logger.info("Active Tour: _determineCurrentTour");
    if (_activeTourId != null && tourList != null) {
      for (Tour tour in tourList!.getRequestedRoutes()) {
        if (tour.routeId == _activeTourId && tour.status == 'Started') {
          Logger.info("Active Tour: set current tour: $_activeTourId");
          return tour;
        }
      }
    }
    /*
    leave comment for testing purposes
    */

    // if (tourList!.completedRoutes != null) {
    //   for (Tour journey in tourList!.completedRoutes!) {
    //     if (journey.nodes!.length > 2 &&
    //         journey.status == 'Finished' &&
    //         journey.routeId == 15183) {
    //       saveActiveTour(journey.routeId!);
    //       return journey;
    //     }
    //   }
    // }

    return null;
  }

  Tour? getCurrentTour() {
    return currentRoute;
  }

  Future<void> saveActiveTour(int tourId) async {
    _activeTourId = tourId;
    try {
      await _databaseProvider.update(this);
      Logger.info(
          "Active Tour: saved active tour: " + _activeTourId.toString());
    } catch (e) {
      Logger.error(e, StackTrace.current);
    }
  }

  Future<void> saveLastNodeIdx(int nodeIndex) async {
    Logger.info("Active Tour: set previous tournode to new index " +
        nodeIndex.toString());
    _finishedTourIndex = nodeIndex;
    try {
      await _databaseProvider.update(this);
      Logger.info("Active Tour: saved active tour");
    } catch (e) {
      Logger.error(e, StackTrace.current);
    }
  }

  int getLastFinishedTourNode() {
    return _finishedTourIndex == null ? -1 : _finishedTourIndex!;
  }

  bool hasOpenTours() {
    for (Tour tour in tourList!.getRequestedRoutes()) {
      if (tour.routeId == _activeTourId && tour.status == 'Started') {
        return true;
      }
    }
    return false;
  }

  Future<RequestState> startTour(int routeId) async {
    RequestState retVal = RequestState.ERROR_FAILED;
    _setProcessing(true, ProgressState.START_TOUR);
    http.Response response;
    await _refreshSessionIfNeeded();

    try {
      response = await http
          .put(Uri.parse(Amazon.baseUrl + '/routes/$routeId/started'),
              headers: new Map<String, String>.from({
                'Accept': 'application/json',
                'Authorization':
                    'Bearer ${_cognitoUserSession!.getAccessToken().getJwtToken()}'
              }))
          .timeout(Duration(seconds: TIMEOUT_DURATION));
      Logger.info(response.request.toString());
      Logger.info("RESPONSE: " + response.body.toString());
      if (response.statusCode == 202) {
        retVal = RequestState.SUCCESS;
        _activeTourId = routeId;
        try {
          await _databaseProvider.update(this);
          Logger.info("Active Tour: saved active tour");
        } catch (e) {
          Logger.error(e, StackTrace.current);
        }
        await loadTours();
        initActiveTourData();
      }
    } on TimeoutException catch (e) {
      retVal = RequestState.ERROR_TIMEOUT;
    } on SocketException catch (e) {
      Logger.error(e, StackTrace.current);
      retVal = RequestState.ERROR_FAILED_NO_INTERNET;
      Logger.info("ERROR_FAILED_NO_INTERNET");
    } catch (e) {
      _setProcessing(false, ProgressState.NONE);
      Logger.error(e, StackTrace.current);
    }
    _setProcessing(false, ProgressState.NONE);

    return retVal;
  }

  Future<void> confirmFinishDialog(
      int routeId, BuildContext context, bool isStarted, bool popScreen) async {
    RequestState resultState = RequestState.ERROR_FAILED;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.dialogFinishTourTitle,
              style: CustomTextStyles.title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  AppLocalizations.of(context)!.dialogFinishTourMessage,
                  style: CustomTextStyles.bodyGrey,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
                child: Text(
                  AppLocalizations.of(context)!.buttonConfirmFinish,
                  style: CustomTextStyles.bodyAzure,
                ),
                onPressed: () => Navigator.pop(context, true)),
            TextButton(
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: CustomTextStyles.bodyAzure,
              ),
              onPressed: () => Navigator.pop(context, false),
            ),
          ],
        );
      },
    ).then((confirm) async {
      if (confirm) {
        resultState = isStarted
            ? await User().finishTour(routeId)
            : await User().startTour(routeId);
        if (resultState != RequestState.SUCCESS) {
          if (resultState == RequestState.ERROR_FAILED_NO_INTERNET) {
            _showDialog(AppLocalizations.of(context)!.dialogErrorTitle,
                AppLocalizations.of(context)!.dialogMessageNoInternet, context);
          } else if (resultState == RequestState.ERROR_TIMEOUT) {
            _showDialog(AppLocalizations.of(context)!.dialogInfoTitle,
                AppLocalizations.of(context)!.dialogTimeoutErrorText, context);
          } else {
            _showDialog(AppLocalizations.of(context)!.dialogErrorTitle,
                AppLocalizations.of(context)!.dialogGenericErrorText, context);
          }
        }
        if (popScreen && resultState == RequestState.SUCCESS) {
          Navigator.of(context).pop();
        }
      }
    });
  }

  Future<void>? showFCMErrorIfnecessary(
      BuildContext context, RequestState resultState) {
    if (resultState != RequestState.SUCCESS) {
      if (resultState == RequestState.ERROR_FAILED_NO_INTERNET) {
        Logger.info("ERROR_FAILED_NO_INTERNET");
        _showDialog(
            AppLocalizations.of(context)!.dialogErrorTitle,
            AppLocalizations.of(context)!.dialogPushNoInternetErrorText,
            context);
      } else {
        return _showDialog(AppLocalizations.of(context)!.dialogErrorTitle,
            AppLocalizations.of(context)!.dialogPushBackendErrorText, context);
      }
    }
    return null;
  }

  Future<void> _showDialog(String title, String message, BuildContext context) {
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

  Future<RequestState> finishTour(int routeId) async {
    RequestState retVal = RequestState.ERROR_FAILED;
    _setProcessing(true, ProgressState.FINISH_TOUR);
    await _refreshSessionIfNeeded();
    http.Response response;

    try {
      response = await http
          .put(Uri.parse(Amazon.baseUrl + '/routes/$routeId/finished'),
              headers: new Map<String, String>.from({
                'Accept': 'application/json',
                'Authorization':
                    'Bearer ${_cognitoUserSession!.getAccessToken().getJwtToken()}'
              }))
          .timeout(Duration(seconds: TIMEOUT_DURATION));
      Logger.info(response.request.toString());
      Logger.info("RESPONSE: " + response.body.toString());
      if (response.statusCode == 202) {
        retVal = RequestState.SUCCESS;

        try {
          resetActiveTourData();
          await _databaseProvider.update(this);
        } catch (e) {
          Logger.error(e, StackTrace.current);
        }
        await loadTours();
      }
    } on TimeoutException catch (e) {
      Logger.e("Connection timed out");
      retVal = RequestState.ERROR_TIMEOUT;
    } on SocketException catch (e) {
      Logger.error(e, StackTrace.current);
      retVal = RequestState.ERROR_FAILED_NO_INTERNET;
      Logger.info("ERROR_FAILED_NO_INTERNET");
    } catch (e) {
      _setProcessing(false, ProgressState.NONE);
      Logger.error(e, StackTrace.current);
    }
    _setProcessing(false, ProgressState.NONE);

    return retVal;
  }

  Future<Tuple2<RequestState, Map<int, int>?>> loadCustomerStatusForTourNode(
      TourNode tourNode) async {
    RequestState retVal = RequestState.ERROR_FAILED;
    if (!isLoggedIn()) {
      return Tuple2(retVal, null);
    }

    Map<int, int> customerStatusList = new Map<int, int>();
    _setProcessing(true, ProgressState.LOAD_ORDERSTATUS);

    for (int i = 0; i < tourNode.hopOns.length; i++) {
      HopOnsAndOffs current = tourNode.hopOns[i];
      int orderID = current.orderId;
      int result = 0;
      result = await getCustomerStatus(orderID);
      if (result == -99) {
        retVal = RequestState.ERROR_FAILED_NO_INTERNET;
      } else {
        retVal = RequestState.SUCCESS;
        Logger.info("customerStatus for orderID $orderID : $result");
        customerStatusList.putIfAbsent(orderID, () => result);
      }
    }

    _setProcessing(false, ProgressState.NONE);
    return Tuple2(retVal, customerStatusList);
  }

  Future<PhoneNumberList> loadPhoneNumbers(int routeId) async {
    if (!isLoggedIn()) {
      return PhoneNumberList(null);
    }

    PhoneNumberList? phoneNumberList;

    _setProcessing(true, ProgressState.LOAD_PHONENUMBERS);
    await _refreshSessionIfNeeded();
    String? authorizationToken = useDirectus
        ? directusToken!.accessToken
        : _cognitoUserSession!.getAccessToken().getJwtToken();
    http.Response response;

    try {
      Logger.info("Load phone numbers for route with id: $routeId");

      response = await http
          .get(
              Uri.parse(Amazon.baseUrl +
                  (useDirectus
                      ? '/items/order?filter[route_id][_eq]=$routeId&filter[status][_neq]=Cancelled&fields=user_created.phoneNumber,id'
                      : Strings.ORDERS_URL_BACKEND + '/$routeId/phonenumbers')),
              headers: new Map<String, String>.from({
                'Accept': 'application/json',
                'Authorization': 'Bearer $authorizationToken'
              }))
          .timeout(Duration(seconds: TIMEOUT_DURATION));
      Logger.info(response.request.toString());
      Logger.info("RESPONSE: " + response.statusCode.toString());

      phoneNumberList = PhoneNumberList(response);
    } on SocketException {
      Logger.info("ERROR_FAILED_NO_INTERNET");
      phoneNumberList = PhoneNumberList(null);
      phoneNumberList.markNotLoaded();
    } catch (e) {
      Logger.error(e, StackTrace.current);
      if (phoneNumberList == null) {
        phoneNumberList = PhoneNumberList(null);
        phoneNumberList.markNotLoaded();
      }
    }
    _setProcessing(false, ProgressState.NONE);
    return phoneNumberList;
  }

  Future<int> getCustomerStatus(int orderID) async {
    http.Response response;
    int result = 0;

    await _refreshSessionIfNeeded();
    String? authorizationToken = useDirectus
        ? directusToken!.accessToken
        : _cognitoUserSession!.getAccessToken().getJwtToken();

    try {
      response = await http
          .get(
              Uri.parse(Amazon.baseUrl +
                  (useDirectus
                      ? '/items/order/$orderID?fields=customerStatus'
                      : Strings.ORDERS_URL_BACKEND +
                          '/$orderID/customerStatus')),
              headers: new Map<String, String>.from({
                'Accept': 'application/json',
                'Authorization': 'Bearer $authorizationToken'
              }))
          .timeout(Duration(seconds: TIMEOUT_DURATION));
      Logger.info(response.request.toString());
      Logger.info("RESPONSE: " + response.statusCode.toString());
      if (response.statusCode == 200) {
        if (useDirectus) {
          final parsed = jsonDecode(response.body)["data"];
          if (parsed['customerStatus'] != null) {
            final bool status = parsed['customerStatus'] as bool;
            result = status == true ? 1 : 0;
          }
        } else {
          result = int.tryParse(response.body)!;
          Logger.info(response.request.toString());
        }
      }
    } on TimeoutException catch (e) {
      Logger.info("Timeout for loading customerStatus");
      _setProcessing(false, ProgressState.NONE);
    } on SocketException catch (e) {
      result = -99;
      Logger.info("ERROR_FAILED_NO_INTERNET");
      Logger.error(e, StackTrace.current);
    } catch (e) {
      Logger.error(e, StackTrace.current);
    }

    return result;
  }

  Future<Tuple2<RequestState, int>> setCustomerStatus(
      int orderID, int customerStatus) async {
    RequestState retVal = RequestState.ERROR_FAILED;
    int statusCode = 0;
    if (this.isProcessing) {
      return Tuple2<RequestState, int>(retVal, -1);
    }

    http.Response response;
    _setProcessing(true, ProgressState.UPDATE_ORDERSTATUS);
    await _refreshSessionIfNeeded();
    String? authorizationToken = useDirectus
        ? directusToken!.accessToken
        : _cognitoUserSession!.getAccessToken().getJwtToken();

    try {
      if (useDirectus) {
        bool status = customerStatus == 0 ? false : true;
        response = await http
            .patch(
                Uri.parse(Amazon.baseUrl +
                    '/items/order/$orderID?fields=customerStatus'),
                headers: new Map<String, String>.from({
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer $authorizationToken'
                }),
                body: json.encode({"customerStatus": '$status'}))
            .timeout(Duration(seconds: TIMEOUT_DURATION));
        Logger.info(response.request.toString());
        Logger.info("body: " + json.encode({"customerStatus": '$status'}));
      } else {
        response = await http
            .patch(
                Uri.parse(Amazon.baseUrl + '/orders/$orderID/$customerStatus'),
                headers: new Map<String, String>.from({
                  'Accept': 'application/json',
                  'Authorization': 'Bearer $authorizationToken'
                }))
            .timeout(Duration(seconds: TIMEOUT_DURATION));
        Logger.info(response.request.toString());
      }

      Logger.info("RESPONSE: " + response.statusCode.toString());

      if (response.statusCode == 204 || response.statusCode == 200) {
        retVal = RequestState.SUCCESS;
      }
      statusCode = response.statusCode;
    } on SocketException catch (e) {
      statusCode = 0;
      retVal = RequestState.ERROR_FAILED_NO_INTERNET;
      Logger.info("ERROR_FAILED_NO_INTERNET");
      Logger.error(e, StackTrace.current);
    } catch (e) {
      _setProcessing(false, ProgressState.NONE);
      Logger.error(e, StackTrace.current);
    }
    _setProcessing(false, ProgressState.NONE);

    return Tuple2<RequestState, int>(retVal, statusCode);
  }

  Future<RequestState> sendBusPosition(Position location) async {
    RequestState retVal = RequestState.ERROR_FAILED;

    http.Response response;

    if (busIds == null || busIds!.isEmpty || location == null) {
      return retVal;
    }

    _setProcessing(true, ProgressState.UPDATE_BUSPOSITION);

    int busId = busIds![0];
    double lng = location.longitude;
    double lat = location.latitude;

    await _refreshSessionIfNeeded();

    String? authorizationToken = useDirectus
        ? directusToken!.accessToken
        : _cognitoUserSession!.getAccessToken().getJwtToken();

    BusPosition busPosition = BusPosition(
        LastPosition(
            coordinates: [location.longitude, location.latitude],
            type: "Point"),
        location.timestamp);

    try {
      if (useDirectus) {
        response = await http
            .patch(Uri.parse(Amazon.baseUrl + '/items/bus/$busId'),
                headers: new Map<String, String>.from({
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer $authorizationToken'
                }),
                body: json.encode(busPosition.toJson()))
            .timeout(Duration(seconds: TIMEOUT_DURATION));
        Logger.info(response.request.toString());
        Logger.info("Body: " + json.encode(busPosition.toJson()));
      } else {
        response = await http
            .put(
                Uri.parse(Amazon.baseUrl +
                    '/buses/$busId/position?lng=$lng&lat=$lat'),
                headers: new Map<String, String>.from({
                  'Accept': 'application/json',
                  'Authorization': 'Bearer $authorizationToken'
                }))
            .timeout(Duration(seconds: TIMEOUT_DURATION));
        Logger.info(response.request.toString());
      }

      Logger.info("RESPONSE: " + response.statusCode.toString());
      if (response.statusCode == 204 || response.statusCode == 200) {
        retVal = RequestState.SUCCESS;
      }
    } catch (e) {
      _setProcessing(false, ProgressState.NONE);
      Logger.error(e, StackTrace.current);
    }
    _setProcessing(false, ProgressState.NONE);

    return retVal;
  }

  void _setPwdVerificationMode(bool enabled) {
    _sharedPreferences!.setBool(Strings.prefKeyCode, enabled);
  }

  bool isPwdVerificationMode() {
    return _sharedPreferences!.getBool(Strings.prefKeyCode) ?? false;
  }

  /// Load user data from local database.
  Future<void> loadUser() async {
    await _databaseProvider.getActiveUser();
  }

  void _setProcessing(bool isProcessing, ProgressState state) {
    Logger.info('setProcessing: ' +
        isProcessing.toString() +
        ", state: " +
        state.toString());
    this.isProcessing = isProcessing;
    this._currentProgressState = state;
    notifyListeners();
  }

  void _setDebugProcessing(bool isProcessing) {
    this.isDebugProcessing = isProcessing;
    notifyListeners();
  }

  bool get isProgressUpdateTours {
    return _currentProgressState == ProgressState.UPDATE_TOURS;
  }

  bool get isProgressAnyTourAction {
    return _currentProgressState == ProgressState.UPDATE_TOURS ||
        _currentProgressState == ProgressState.START_TOUR ||
        _currentProgressState == ProgressState.FINISH_TOUR;
  }

  bool get isProgressGetPhoneNumbers {
    return _currentProgressState == ProgressState.LOAD_PHONENUMBERS;
  }

  bool get isProgressOrderStatus {
    return _currentProgressState == ProgressState.LOAD_ORDERSTATUS ||
        _currentProgressState == ProgressState.UPDATE_ORDERSTATUS;
  }

  bool get isProgressLogin {
    return _currentProgressState == ProgressState.LOGIN;
  }

  bool get isProgressLogout {
    return _currentProgressState == ProgressState.LOGOUT;
  }

  bool get isProgressRegister {
    return _currentProgressState == ProgressState.REGISTER;
  }

  bool get isProgressReset {
    return _currentProgressState == ProgressState.RESET;
  }

  bool get isProgressDelete {
    return _currentProgressState == ProgressState.DELETE;
  }

  bool get isProgressAccept {
    return _currentProgressState == ProgressState.ACCEPT;
  }

  bool get isProgressConfirm {
    return _currentProgressState == ProgressState.CONFIRM;
  }

  void _reset() {
    _cognitoUser = null;
    _cognitoUserSession = null;

    id = null;
    _name = null;
    email = null;
    _firstName = null;
    _phoneNumber = null;
    _address = null;
    tmpAcceptedRegisterVersions = null;
    _activeTourId = null;
    _finishedTourIndex = null;
    _isActive = false;
    inStopRange = false;
    distanceToStop = 0;
    activeNodeIdx = 0;
    currentRoute = null;
  }
}
