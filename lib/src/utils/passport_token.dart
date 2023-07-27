/*import 'dart:convert';
import 'package:intl/intl.dart';

class PassportToken {
  String? token;
  Map<String, dynamic> properties = {};

  PassportToken(String token) {
    properties = dirtyDecode(token);
    this.token = token;
  }

  String? getToken() {
    return token;
  }

  Map<String, dynamic> getProperties() {
    return properties;
  }

  dynamic operator [](String property) {
    return properties[property];
  }

  bool existsValid() {
    return existsValidToken(properties['token_id'], properties['user_id']);
  }

  static bool existsValidToken(String? token_id, String? user_id) {
    // Implement your logic to check token validity here.
    return false;
  }

  Map<String, dynamic> dirtyDecode(String access_token, [List<String> claims = const []]) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    bool expecting = false;
    bool incorrect = false;
    bool expired = false;
    bool error = false;
    List<String> errors = [];
    final tokenSegments = access_token.split('.');
    final body = tokenSegments.length >= 2 ? tokenSegments[1] : null;


    if(body == null){
      error = true;
      errors.add('Decoder has problem with Token encoding');
    }

    if (tokenSegments.length != 3) {
      error = true;
      errors.add('Token has wrong number of segments');
    }
    final data = jsonDecode(urlDecode(body!)) as Map<String, dynamic>?;
    if (data == null) {
      error = true;
      errors.add('Decoder has problem with Token encoding');
    }
    if (data!.containsKey('nbf') && data['nbf'] > now) {
      expecting = true;
    }
    if (data.containsKey('iat') && data['iat'] > now) {
      incorrect = true;
    }
    if (data.containsKey('exp') && now >= data['exp']) {
      expired = true;
    }

    final decodedToken = {
      'token_id': data['jti'],
      'user_id': data['sub'],
      'expecting': expecting,
      'start_at_unix': data['nbf'],
      'start_at': data['nbf'] != null ? DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(data['nbf'] * 1000)) : null,
      'incorrect': incorrect,
      'created_at_unix': data['iat'],
      'created_at': data['iat'] != null ? DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(data['iat'] * 1000)) : null,
      'expired': expired,
      'expires_at_unix': data['exp'],
      'expires_at': data['exp'] != null ? DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(data['exp'] * 1000)) : null,
      'error': error,
      'errors': errors,
      'valid': !(expecting || incorrect || expired || error),
    };

    if (claims.isNotEmpty) {
      decodedToken['claims'] = getCustomClaims(data, claims);
    }

    return decodedToken;
  }

  String urlDecode(String input) {
    final remainder = input.length % 4;
    if (remainder > 0) {
      final padlen = 4 - remainder;
      input += '=' * padlen;
    }
    return utf8.decode(base64Url.decode(input));
  }

  Map<String, dynamic> jsonDecode(String input) {
    dynamic obj;
    try {
      obj = jsonDecode(input);
    } catch (_) {
      final maxIntLength = (BigInt.from(1) << 63).toString().length - 1;
      final jsonWithoutBigints = input.replaceAllMapped(
        RegExp(':\\s*(-?\\d{${maxIntLength},})'),
            (match) => ': "${match.group(1)}"',
      );
      obj = jsonDecode(jsonWithoutBigints);
    }
    return obj;
  }

  Map<String, dynamic> getCustomClaims(Map<String, dynamic> data, List<String> claims) {
    final decodedToken = <String, dynamic>{};
    for (final claim in claims) {
      if (data.containsKey(claim)) {
        decodedToken[claim] = data[claim];
      }
    }
    return decodedToken;
  }
}*/
