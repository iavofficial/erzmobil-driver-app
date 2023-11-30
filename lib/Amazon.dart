import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:erzmobil_driver/model/SecureStorageHolder.dart';

class Amazon {
  Amazon._();

  static initUserPool(String userPoolId, String clientId) {
    Amazon.userPoolId = userPoolId;
    Amazon.clientId = clientId;
    userPool =
        CognitoUserPool(userPoolId, clientId, storage: SecureStorageHolder());
  }

  static late String userPoolId = '';
  static late String clientId = '';

  static const String region = '';
  static const String baseUrl = '';

  static late CognitoUserPool userPool;
}
