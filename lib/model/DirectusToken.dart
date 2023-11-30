class DirectusToken {
  final String? accessToken;
  final DateTime? expires;
  final String? refreshToken;

  const DirectusToken(this.accessToken, this.expires, this.refreshToken);

  factory DirectusToken.fromJson(Map<String, dynamic> json) {
    return DirectusToken(
        json['accessToken'],
        json['expires'] != null
            ? DateTime.parse(json['expires'] as String)
            : null,
        json['refreshToken']);
  }

  @override
  String toString() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (accessToken != null) {
      data['access_token'] = this.accessToken;
    }
    if (expires != null) {
      data['expires'] = this.expires;
    }
    if (refreshToken != null) {
      data['refresh_token'] = this.refreshToken;
    }

    return data.toString();
  }
}
