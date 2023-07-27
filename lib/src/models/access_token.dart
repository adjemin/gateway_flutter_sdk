class AccessToken{

  String? tokenType;
  int? expiresIn;
  String? accessToken;

  AccessToken({this.tokenType, this.expiresIn, this.accessToken});

  AccessToken.fromJson(Map<String, dynamic> json) {
    tokenType = json['token_type'];
    expiresIn = json['expires_in'];
    accessToken = json['access_token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['token_type'] = this.tokenType;
    data['expires_in'] = this.expiresIn;
    data['access_token'] = this.accessToken;
    return data;
  }

}