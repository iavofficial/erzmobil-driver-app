class RouteRequestResult {
  final bool result;
  final int reasonCode;
  final String reasonText;

  const RouteRequestResult(this.result, this.reasonCode, this.reasonText);

  factory RouteRequestResult.fromJson(Map<String, dynamic> json) {
    return RouteRequestResult(
        json['result'] as bool, json['reasonCode'] as int, json['reasonText']);
  }
}
