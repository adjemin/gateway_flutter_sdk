import 'dart:convert';

import 'package:adjemin_gateway_sdk/adjemin_gateway_sdk.dart';
import 'package:adjemin_gateway_sdk/src/models/gateway_transaction.dart';
import 'package:adjemin_gateway_sdk/src/network/GatewayException.dart';
import 'package:http/http.dart';

abstract class IGatewayRepository{

  Future<List<GatewayOperator>> findOperatorsByCountry(String countryIso);
  Future<GatewayTransaction> makePayment({
    required int amount,
    required String gatewayOperatorCode,
    required String merchantTransId,
    required String webhookUrl,
    required String customerRecipientNumber,
    String? customerEmail,
    String? customerFirstname,
    String? customerLastname,
    String? otp
  });
  Future<GatewayTransaction> finalisePayment({
    required String merchantTransId,
    String? customerRecipientNumber,
    String? otp
  });
  Future<GatewayTransaction> makeTransfer({
    required int amount,
    required String gatewayOperatorCode,
    required String merchantTransId,
    required String webhookUrl,
    required String customerRecipientNumber,
    String? customerEmail,
    String? customerFirstname,
    String? customerLastname
  });
  Future<GatewayTransaction> checkPaymentStatus(String merchantTransactionId);

}

class GatewayRepository implements IGatewayRepository{

  //final String _API_URL = "https://api-test.adjem.in";
  final String _API_URL = "https://api.adjem.in";

  @override
  Future<GatewayTransaction> checkPaymentStatus(String merchantTransactionId)async {
    final url = Uri.parse("$_API_URL/v3/gateway/payment/$merchantTransactionId");

    final response = await get(url);

    print('checkPaymentStatus() =>>> REQ => $response');

    if(response.statusCode == 200){
      final Map<String, dynamic> json  = jsonDecode(response.body);
      final bool success = json['success'];
      if(success){
        final Map<String, dynamic> data = json['data'];
        return GatewayTransaction.fromJson(data);
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

  @override
  Future<GatewayTransaction> finalisePayment({required String merchantTransId, String? customerRecipientNumber, String? otp}) {
    // TODO: implement finalisePayment
    throw UnimplementedError();
  }

  @override
  Future<List<GatewayOperator>> findOperatorsByCountry(String countryIso)async {
   final url = Uri.parse("$_API_URL/v3/gateway/operators/$countryIso");

   final response = await get(url);
   if(response.statusCode == 200){
     final Map<String, dynamic> json  = jsonDecode(response.body);
     final bool success = json['success'];
     if(success){
       final List list = json['data'];
       return list.map((e) => GatewayOperator.fromJson(e as Map<String, dynamic>)).toList();
     }else{
       throw response;
     }
   }else{
     throw response;
   }
  }

  @override
  Future<GatewayTransaction> makePayment({
    required int amount,
    required String gatewayOperatorCode,
    required String merchantTransId,
    required String webhookUrl,
    required String customerRecipientNumber,
    String? customerEmail,
    String? customerFirstname,
    String? customerLastname,
    String? otp})async {
    final url = Uri.parse("$_API_URL/v3/gateway/make_payment");

    final response = await post(url,
    body: jsonEncode({
      "amount":amount,
      "gateway_operator_code":gatewayOperatorCode,
      "merchant_trans_id":merchantTransId,
      "customer_recipient_number":customerRecipientNumber,
      "customer_email":customerEmail,
      "customer_firstname":customerFirstname,
      "customer_lastname":customerLastname,
      "otp":otp,
      "webhook_url":webhookUrl
    })
    );

    print("makePayment() ==>>> BODY ${response.body}");

    if(response.statusCode == 200){
      final Map<String, dynamic> json  = jsonDecode(response.body);
      final bool success = json['success'];
      if(success){
        final Map<String, dynamic> data = json['data'];
        return GatewayTransaction.fromJson(data);
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

  @override
  Future<GatewayTransaction> makeTransfer({required int amount, required String gatewayOperatorCode, required String merchantTransId,required String webhookUrl, required String customerRecipientNumber, String? customerEmail, String? customerFirstname, String? customerLastname})async {
    final url = Uri.parse("$_API_URL/v3/gateway/make_transfer");

    final response = await post(url,
        body: jsonEncode({
          "amount":amount,
          "gateway_operator_code":gatewayOperatorCode,
          "merchant_trans_id":merchantTransId,
          "customer_recipient_number":customerRecipientNumber,
          "customer_email":customerEmail,
          "customer_firstname":customerFirstname,
          "customer_lastname":customerLastname,
          "webhook_url":webhookUrl
        })
    );
    if(response.statusCode == 200){
      final Map<String, dynamic> json  = jsonDecode(response.body);
      final bool success = json['success'];
      if(success){
        final Map<String, dynamic> data = json['data'];
        return GatewayTransaction.fromJson(data);
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