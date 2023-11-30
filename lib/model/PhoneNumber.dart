class PhoneNumber {
  final int? userId;
  final String number;

  const PhoneNumber(this.userId, this.number);

  factory PhoneNumber.fromJson(Map<String, dynamic> json) {
    return PhoneNumber(
        json['id'] as int,
        json['user_created'] != null &&
                json['user_created']['phoneNumber'] != null
            ? json['user_created']['phoneNumber'] as String
            : "");
  }
}
