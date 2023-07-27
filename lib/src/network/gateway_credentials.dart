import 'dart:convert';

import 'package:adjemin_gateway_sdk/src/models/access_token.dart';
import 'package:adjemin_gateway_sdk/src/network/gateway_exception.dart';
import 'package:adjemin_gateway_sdk/src/utils/jwt_decoder.dart';
import 'package:http/http.dart';

abstract class IGatewayCredentials{

  Future<AccessToken> getAccessToken({
    required String baseUrl,
    required String clientId,
    required String clientSecret,
  });
}

class GatewayCredentials implements IGatewayCredentials{

 static final GatewayCredentials _singleton = GatewayCredentials._internal();
 static AccessToken? _token;

 factory GatewayCredentials() {
   return _singleton;
 }

 GatewayCredentials._internal();

  @override
  Future<AccessToken> getAccessToken({
    required String baseUrl,
    required String clientId,
    required String clientSecret}) async {

    if(_token == null ){
      _token = await _obtainAccessToken(baseUrl: baseUrl, clientId: clientId, clientSecret: clientSecret);
    }

    //print("getAccessToken() ==>>> _token ==>> $_token");
    //print("TEST ==>>> token has expired ==>> ${JwtDecoder.isExpired("eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiI5NjY2MGFjZC1jMDRmLTQ5NmMtODAzMi0xMGU4ZDRmYmRmYzAiLCJqdGkiOiI3NThmNzJjOTE4ZGY4MDkwNzczMTdjNDBiYTIwN2MzNGEzY2E3MmU4MzYxMDUxOGI5ZDJmZWVkMTZkMmVhYzk3MzA2YTBjMzg5OGRjYTBjZSIsImlhdCI6MTY5MDQ3MTI1Ny43Njk2MDEsIm5iZiI6MTY5MDQ3MTI1Ny43Njk2MDUsImV4cCI6MTY5MDU1NzY1Ny43NjU1OTMsInN1YiI6IiIsInNjb3BlcyI6W119.B7PvqESNdTZW-UiIRT5sLvdbUktV4SNVhoYXBHm4bxgUMc6LuGRKzaDNCtVmztUE2CSj4Hk_uDWOC7arhXMWDX52_IdLrZhaC2HYkoxLdYkR5vPXVnSG8Sn_l0pqXR2Tg5Z0ypsKihbGCwj4AAbYeSQBXSzWpa9oz62mkUhTqwnxNAwumy9g3Fuh33GTZylxA_M-Hc6B8imxa8qYLUXLQV9Yd3QH-K-pfJ8gsk0LB0yRGLgSheY6VU2Rr2a-VDEI_vUKV312NfCh_v79snevKgWTDBbpr0V-lEoVd9hK2lj3pqOjTjZun31I31bcv5jzj36wWkaz84HPLkLjCFj5Leo1nuh7kJWELDCVy_uqh-PKgUrySJv21wCcc_bczP8p60PsbjVvzosecqM5X64uc13cpNArzJT0lXla6TxvUM54sYrMIy2VynXEDDVh3gW44OZ6M7eTWCwAf2PTvFQGQ0cS1CYVeH4k7UhLMWExDmsyGjatwefmo_OX1tz97hA8HYRJ4L8LEFiRLjSvYGBhUmQ-5zPyqoqRngY-d2eoJxT9D0e5zQ4q11ZWdmyaTcru0d_1N1KvQUQdgvt3bAHs4ALRKn7qVsoUBN1TECI7kM0D15LpC51hUu7YooxddN-Hm3-PSBx0eJho0wwapOhce2U9xNNnTiEOzhBeSoiF3z8")}");


    if(_token != null){

      //check if the token has expired
      print("Check if the token has expired");
     final bool hasExpired = JwtDecoder.isExpired(_token!.accessToken!);

      if(hasExpired){//Token has expired
        print("Token has expired so we are obtaining a new one.");
        _token =  await _obtainAccessToken(baseUrl: baseUrl, clientId: clientId, clientSecret: clientSecret);
      }

    }



    return _token!;
  }

 Future<AccessToken> _obtainAccessToken({
   required String baseUrl,
   required String clientId,
   required String clientSecret}) async{

   final url = Uri.parse("$baseUrl/v3/oauth/token");

   final response = await post(url,
       body: {
         "client_id":clientId,
         "client_secret":clientSecret,
         "grant_type":"client_credentials"
       },
     headers: {
       'Accept': 'application/json',
       'Content-Type': 'application/x-www-form-urlencoded'
     }
   );

   //print("_obtainAccessToken() ==>>> BODY ${response.body}");

   if(response.statusCode == 200){
     final Map<String, dynamic> json  = jsonDecode(response.body);
     if(json != null){
       return AccessToken.fromJson(json);
     }else{

       throw GatewayException(
           message: json.containsKey('message')?json['message']:'',
           error: json.containsKey('error')?json['error']:'',
           code: json.containsKey('code')?json['code']:'',
           status: json.containsKey('status')?json['status']:''
       );
     }
   }else{

     if(response.headers['content-type'] == 'application/json'){
       final Map<String, dynamic> json  = jsonDecode(response.body);
       throw GatewayException(
           message: json.containsKey('message')?json['message']:'',
           error: json.containsKey('error')?json['error']:'',
           code: json.containsKey('code')?json['code']:'',
           status: json.containsKey('status')?json['status']:''
       );
     }else{
       throw response;
     }

   }
 }

}