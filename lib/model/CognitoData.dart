class CognitoData {
  final String? userClientId;
  final String? userPoolId;
  final String? driverClientId;

  const CognitoData(this.userClientId, this.driverClientId, this.userPoolId);

  factory CognitoData.fromJson(Map<String, dynamic> json) {
    return CognitoData(
        json['userClientId'], json['driverClientId'], json['userPoolId']);
  }

  bool isValid() {
    return driverClientId != null && userPoolId != null;
  }
}
