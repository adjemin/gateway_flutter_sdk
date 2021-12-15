class GatewayOperator {
  int? id;
  String? name;
  String? payinCode;
  String? payoutCode;
  String? countryCode;
  String? currencyCode;
  bool? isActivePayin;
  bool? isActivePayout;
  String? image;
  String? payinFees;
  String? payinMode;
  String? payoutFees;
  String? payoutMode;
  String? gatewayCode;

  GatewayOperator(
      {this.id,
        this.name,
        this.payinCode,
        this.payoutCode,
        this.countryCode,
        this.currencyCode,
        this.isActivePayin,
        this.isActivePayout,
        this.image,
        this.payinFees,
        this.payinMode,
        this.payoutFees,
        this.payoutMode,
        this.gatewayCode
      });

  GatewayOperator.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    payinCode = json['payin_code'];
    payoutCode = json['payout_code'];
    countryCode = json['country_code'];
    currencyCode = json['currency_code'];
    isActivePayin = json['is_active_payin'];
    isActivePayout = json['is_active_payout'];
    image = json['image'];
    payinFees = json['payin_fees'];
    payinMode = json['payin_mode'];
    payoutFees = json['payout_fees'];
    payoutMode = json['payout_mode'];
    gatewayCode = json['gateway_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['payin_code'] = this.payinCode;
    data['payout_code'] = this.payoutCode;
    data['country_code'] = this.countryCode;
    data['currency_code'] = this.currencyCode;
    data['is_active_payin'] = this.isActivePayin;
    data['is_active_payout'] = this.isActivePayout;
    data['image'] = this.image;
    data['payin_fees'] = this.payinFees;
    data['payin_mode'] = this.payinMode;
    data['payout_fees'] = this.payoutFees;
    data['payout_mode'] = this.payoutMode;
    data['gateway_code'] = this.gatewayCode;
    return data;
  }
}