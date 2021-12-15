class GatewayTransaction {

  static final String SUCCESSFUL = "SUCCESSFUL";
  static final String FAILED = "FAILED";
  static final String PENDING = "PENDING";
  static final String INITIATED = "INITIATED";

  String? gatewayOperatorCode;
  String? gatewayCode;
  int? amount;
  String? currencyCode;
  String? recipientNumber;
  String? status;
  String? gatewayTransId;
  double? fees;
  String? paymentUrl;
  String? merchantTransId;
  bool? isPayin;
  String? requestMetadata;
  String? responseMetadata;
  int? responseStatusCode;
  bool? isWaiting;
  bool? isCompleted;
  int? merchantId;
  String? updatedAt;
  String? createdAt;
  int? id;

  GatewayTransaction(
      { this.gatewayOperatorCode,
        this.gatewayCode,
        this.amount,
        this.currencyCode,
        this.recipientNumber,
        this.status,
        this.paymentUrl,
        this.gatewayTransId,
        this.fees,
        this.merchantTransId,
        this.isPayin,
        this.requestMetadata,
        this.responseMetadata,
        this.responseStatusCode,
        this.isWaiting,
        this.isCompleted,
        this.merchantId,
        this.updatedAt,
        this.createdAt,
        this.id});

  GatewayTransaction.fromJson(Map<String, dynamic> json) {
    gatewayOperatorCode = json['gateway_operator_code'];
    gatewayCode = json['gateway_code'];
    amount = json['amount'];
    currencyCode = json['currency_code'];
    recipientNumber = json['recipient_number'];
    status = json['status'];
    paymentUrl = json['payment_url'];
    gatewayTransId = json['gateway_trans_id'];
    fees = json['fees'];
    merchantTransId = json['merchant_trans_id'];
    isPayin = json['is_payin'];
    requestMetadata = json['request_metadata'];
    responseMetadata = json['response_metadata'];
    responseStatusCode = json['response_status_code'];
    isWaiting = json['is_waiting'];
    isCompleted = json['is_completed'];
    merchantId = json['merchant_id'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['gateway_operator_code'] = this.gatewayOperatorCode;
    data['gateway_code'] = this.gatewayCode;
    data['amount'] = this.amount;
    data['currency_code'] = this.currencyCode;
    data['recipient_number'] = this.recipientNumber;
    data['status'] = this.status;
    data['payment_url'] = this.paymentUrl;
    data['gateway_trans_id'] = this.gatewayTransId;
    data['fees'] = this.fees;
    data['merchant_trans_id'] = this.merchantTransId;
    data['is_payin'] = this.isPayin;
    data['request_metadata'] = this.requestMetadata;
    data['response_metadata'] = this.responseMetadata;
    data['response_status_code'] = this.responseStatusCode;
    data['is_waiting'] = this.isWaiting;
    data['is_completed'] = this.isCompleted;
    data['merchant_id'] = this.merchantId;
    data['updated_at'] = this.updatedAt;
    data['created_at'] = this.createdAt;
    data['id'] = this.id;
    return data;
  }
}

