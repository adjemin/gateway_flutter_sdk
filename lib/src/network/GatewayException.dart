class GatewayException implements Exception{
 final String?  message;
 final String? error;
 final String? status;
 final int? code;

 const GatewayException({this.message, this.error, this.status, this.code});
}