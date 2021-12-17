import 'dart:async';
import 'dart:io';

import 'package:adjemin_gateway_sdk/adjemin_gateway_sdk.dart';
import 'package:adjemin_gateway_sdk/src/models/customer.dart';
import 'package:adjemin_gateway_sdk/src/models/gateway_transaction.dart';
import 'package:adjemin_gateway_sdk/src/network/GatewayException.dart';
import 'package:adjemin_gateway_sdk/src/network/gateway_repository.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'cash_payment_widget.dart';
import 'custom_progress_widget.dart';
import 'customer_form_widget.dart';
import 'otp_form_widget.dart';

enum Country{CI}

class OperatorPickerWidget extends StatefulWidget {

  final Country countryCode;
  final bool isPayIn;
  final String title;
  final Customer? customer;
  final int amount;
  final String? description;
  final String merchantTransactionId;
  final String webhookUrl;

  const OperatorPickerWidget({
    required this.countryCode,
    required this.isPayIn,
    required this.title,
    required this.amount,
    required this.merchantTransactionId,
    required this.webhookUrl,
    this.description,
    this.customer
  });

  @override
  _OperatorPickerWidgetState createState() => _OperatorPickerWidgetState();

}

class _OperatorPickerWidgetState extends State<OperatorPickerWidget> {

  List<GatewayOperator> elements = [];
  bool _isLoading = false;
  bool _isPaymentLoading = false;
  bool _isWaitingAcceptation = true;
  GatewayOperator? _paymentOperatorSelected;
  Timer? _transactionCheckTimer;

  @override
  void initState() {
    super.initState();

    print("ISO =>> ${widget.countryCode.toString().split('.').last}");
    
    Timer.run(loadData);
  }

  @override
  void dispose() {
    super.dispose();
    if(_transactionCheckTimer!= null){
      if(_transactionCheckTimer?.isActive == true){
        _transactionCheckTimer?.cancel();
      }else{
        _transactionCheckTimer?.cancel();
      }
    }

  }
  
  @override
  Widget build(BuildContext context) {


    return WillPopScope(
      onWillPop: () async => false,
      child: _isPaymentLoading?_buildPaymentLoadingUi():
      Scaffold(
        appBar: AppBar(
          title: Text(widget.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),),
          actions: [
            GestureDetector(
              onTap: (){

                displayPrompt(context, "Êtes-vous sûr de faire cela?", "Voulez vous confirmer que vous quittez sans finaliser le paiement ?",(){
                  Navigator.of(context).pop();
                },(){} );

              },
              child: Icon(Icons.close,size: 30,),
            ),
            SizedBox(width: 20,)
          ],
        ),
        body: _isLoading? CustomProgressWidget(): _buildBody(),
      ),
    );
    
  }


  void loadData() {

    showProgress();

    GatewayRepository()
        .findOperatorsByCountry(widget.countryCode.toString().split('.').last)
        .then((value){

          hideProgress();
          if(mounted){
            setState(() {
              elements = value.where((element) => element.isActivePayin == true).toList();
              _paymentOperatorSelected = elements[1];
            });
          }

        })
        .catchError((onError){
         hideProgress();
         print("Error $onError");

         if(onError is Response){
           print("Body ${onError.body}");
         }

       });
    
  }

  showProgress(){
    if(mounted){
      setState(() {
        _isLoading = true;
      });
    }
  }

  hideProgress(){
    if(mounted){
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildBody() {
    return new SingleChildScrollView(
      child: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            padding: EdgeInsets.all(8.0),
            child: Text("Sélectionnez un moyen de paiement",
            style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          Column(
            children: elements.map((e) => GestureDetector(
              onTap: ()async{
                //Navigator.of(context).pop(e);

                final Customer? mCustomer  = await Navigator.push(context,
                    MaterialPageRoute(builder: (context)=> CustomerFormWidget(
                      customer:widget.customer
                    ))
                );

                if(mCustomer != null){

                  if(widget.isPayIn){
                    await _processPayIn(e,mCustomer);
                  }else{
                    await _processPayOut(e, mCustomer);
                  }


                }


              },
              child: _buildOperatorItemUi(e),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOperatorItemUi(GatewayOperator element) {
    return Container(
      padding: EdgeInsets.only(left: 8.0, right: 8.0),
      child: Card(
        shape:RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0)
        ) ,
        child: Row(
          children: [
            SizedBox(width: 20,),
            Image.network(element.image!, width: 80,height: 80,),
            SizedBox(width: 10,),
            Expanded(
              child:  Container(
                child: Text("${element.name}", style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                ),),
              ),
            ),

            SizedBox(width: 10,),
            Icon(Icons.arrow_forward_ios_outlined),
            SizedBox(width: 20,),

          ],
        ),
      ),
    );
  }

  void _pay({required Customer customer, required GatewayOperator gatewayOperator, String? otp}){
    showPaymentLoader(gatewayOperator);
    GatewayRepository().makePayment(
        amount: widget.amount,
        gatewayOperatorCode: gatewayOperator.payinCode!,
        merchantTransId: widget.merchantTransactionId,
        webhookUrl: widget.webhookUrl,
        customerRecipientNumber: customer.phoneNumber!,
        customerEmail: customer.email,
        customerFirstname: customer.firstName,
        customerLastname: customer.lastName,
        otp: otp
    ).then((value){

      if(widget.isPayIn){
        if(gatewayOperator.name!.toLowerCase().contains('orange')){

          _runTransactionChecker(gatewayOperator, widget.merchantTransactionId);

        }

        if(gatewayOperator.name!.toLowerCase().contains('mtn')){

          _runTransactionChecker(gatewayOperator, widget.merchantTransactionId);
        }

        if(gatewayOperator.name!.toLowerCase().contains('moov')){
          _runTransactionChecker(gatewayOperator, widget.merchantTransactionId);

        }

      }else{
        hidePaymentLoader();
      }


    })
    .catchError((onError){
      hidePaymentLoader();

      print("Error $onError");

      if(onError is SocketException){
        displayErrorMessage(context, "Vous n'avez pas accès à internet !", (){
          Navigator.of(context).pop();
        });
      }else if(onError is TimeoutException){
        displayErrorMessage(context, "Votre connexion est instable !", (){
          Navigator.of(context).pop();
        });
      }else if(onError is GatewayException){
        if(onError.code == 300 && onError.error!.contains('(203)')){
          displayErrorMessage(context, "Une transaction similaire a été effectuée récemment, veuillez patienter 15 mins avant de réessayer", (){
            Navigator.of(context).pop();
          });
        }else{
          displayErrorMessage(context, onError.error??onError.message!, (){
            Navigator.of(context).pop();
          });
        }

      } else{
        displayErrorMessage(context, "Désolé, nous rencontrons des problèmes, revenez plutard.", (){
          Navigator.of(context).pop();
        });
      }

    });

  }

  void showPaymentLoader(GatewayOperator gatewayOperator) {
    if(mounted){
      setState(() {
        _isPaymentLoading = true;
        _isLoading = false;
        _paymentOperatorSelected = gatewayOperator;
      });
    }
  }

  void hidePaymentLoader() {
    if(mounted){
      setState(() {
        _isPaymentLoading = false;
        _isLoading = false;
      });
    }
  }

  Widget _buildPaymentLoadingUi() {
    return _paymentOperatorSelected == null? Container(
      color: Colors.white,
    ):Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            SizedBox(height: 50,),

            Row(
              children: [
                SizedBox(width: 20,),
                Container(
                  child: Text("Transaction en cours",
                    style: Theme.of(context).textTheme.headline5,),
                ),
                SizedBox(width: 50,),
                GestureDetector(
                  onTap: (){
                    Navigator.of(context).pop();
                  },
                  child: Icon(Icons.close,size: 40,),
                )
              ],
            ),
            SizedBox(height: 100,),
            Center(
              child: Image.network(_paymentOperatorSelected!.image!,height: 80,),
            ),
            SizedBox(height: 10,),
            Container(
              child: Text("${_paymentOperatorSelected!.name!}",
              style: Theme.of(context).textTheme.headline6,),
            ),
            SizedBox(height: 20,),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(getLoadingMessage(widget.isPayIn,_paymentOperatorSelected!, _isWaitingAcceptation),
                style: Theme.of(context).textTheme.bodyText2?.copyWith(
                  fontSize: 16
                ),),
            ),

            SizedBox(height: 100,),
            new Center(
              child: Container(
                height: 100.0,
                width: 100.0,
                child: new CircularProgressIndicator(
                  strokeWidth: 10.0,
                ),
              ),
            ),
            SizedBox(height: 20,),


          ],
        ),
      ),
    );
  }

   _processPayIn(GatewayOperator e, Customer mCustomer)async {
    if(e.name!.toLowerCase().contains('orange')){
      final String? code  = await Navigator.push(context,
                        MaterialPageRoute(builder: (context)=> OtpFormWidget(
                          gatewayOperator: e,
                          title:widget.title
                        ))
                    );

     if(code != null && code.isNotEmpty){
       _pay(customer: mCustomer, gatewayOperator: e,otp: code);
     }

    }

    if(e.name!.toLowerCase().contains('mtn')){
      final bool? hasPaymentResult  = await Navigator.push(context,
          MaterialPageRoute(builder: (context)=> CashPaymentWidget(
            customer:mCustomer,
            operator:e,
            amount:widget.amount,
            merchantTransactionId: widget.merchantTransactionId,
            description:widget.description,
            isPayIn: widget.isPayIn,
          ))
      );

      if(hasPaymentResult == true){
        _pay(customer: mCustomer, gatewayOperator: e);
      }else{
        Navigator.of(context).pop();
      }

    }

    if(e.name!.toLowerCase().contains('moov')){
      final  bool? hasPaymentResult  = await Navigator.push(context,
          MaterialPageRoute(builder: (context)=> CashPaymentWidget(
            customer:mCustomer,
            operator:e,
            amount:widget.amount,
            merchantTransactionId: widget.merchantTransactionId,
            description:widget.description,
            isPayIn: widget.isPayIn,
          ))
      );

      if(hasPaymentResult == true){
        _pay(customer: mCustomer, gatewayOperator: e);
      }else{
        Navigator.of(context).pop();
      }

    }

  }

  _processPayOut(GatewayOperator e, Customer mCustomer) {

  }

  String getLoadingMessage(bool isPayIn, GatewayOperator operator, bool isWaitingAcceptation) {

    if(isPayIn){
      if(operator.name!.toLowerCase().contains("mtn")){

          if(isWaitingAcceptation){
            return "Veuillez patienter, nous vous redirigeons vers le portail de paiement ${_paymentOperatorSelected!.name}. \n\nSi vous n'êtes pas redirigé après plusieurs minutes vous devez taper ceci: *133# pour valider la transaction.";
          }else{
            return "Traitement de la transaction ${_paymentOperatorSelected!.name} en cours...";
          }

      }else if(operator.name!.toLowerCase().contains("moov")){
        return "Veuillez patienter, nous vous redirigeons vers le portail de paiement ${_paymentOperatorSelected!.name}.";
      }else if(operator.name!.toLowerCase().contains("orange")){
        return "Traitement de la transaction ${_paymentOperatorSelected!.name} en cours...";
      }else{
        return "En attente de validation de la transaction.";
      }
    }else{
      return "Traitement de la transaction ${_paymentOperatorSelected!.name} en cours...";
    }




  }

  _runTransactionChecker(GatewayOperator operator, String transactionId){
    _transactionCheckTimer = Timer.periodic(Duration(milliseconds: 400), (timer) {
      _checkTransactionStatus(operator, transactionId);
    });
  }

  _checkTransactionStatus(GatewayOperator operator, String transactionId){

    print("Date ${DateTime.now()}");

    if(!_isPaymentLoading){

      showPaymentLoader(operator);
    }

    GatewayRepository()
        .checkPaymentStatus(transactionId)
        .then((value){

         if(value.status == GatewayTransaction.SUCCESSFUL){

                hidePaymentLoader();
            _transactionCheckTimer?.cancel();
            Navigator.of(context).pop(value);

          }else if(value.status == GatewayTransaction.FAILED){
           hidePaymentLoader();
            _transactionCheckTimer?.cancel();
            Navigator.of(context).pop(value);
          }else{

          }


       }).catchError((onError){
          //hidePaymentLoader();
          print("Error $onError");

    });

  }

  displayErrorMessage(BuildContext context, String message, Function() action){
    showModalBottomSheet(context: context, builder: (ctext){
      return Container(
        padding: EdgeInsets.all(16.0),
        height: 200,
        color: Colors.white,
        child: Column(
          children: [

            Container(
              child: Text("Erreur rencontrée",style: Theme.of(context).textTheme.headline6),
            ),
            SizedBox(height: 20,),
            Container(
              child: Text(message,style: Theme.of(context).textTheme.bodyText1),
            ),
            SizedBox(height: 20,),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: ElevatedButton(
                onPressed: (){
                  Navigator.of(ctext).pop();
                  action();
                },
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondary),
                    textStyle: MaterialStateProperty.all(Theme.of(context).textTheme.button?.copyWith(
                        color: Colors.white,
                        fontSize: 19
                    ))
                ),
                child:Text("D'accord",) ,
              ),
            ),

          ],
        ),
      );
    });
  }

  displayPrompt(BuildContext context, String title, String message, Function() positive, Function() negative){
    showModalBottomSheet(context: context, builder: (ctext){
      return Container(
        padding: EdgeInsets.all(16.0),
        height: 260,
        color: Colors.white,
        child: Column(
          children: [

            Container(
              child: Text("$title",style: Theme.of(context).textTheme.headline6),
            ),
            SizedBox(height: 20,),
            Container(
              child: Text(message,style: Theme.of(context).textTheme.bodyText1),
            ),
            SizedBox(height: 20,),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: ElevatedButton(
                onPressed: (){
                  Navigator.of(ctext).pop();
                  positive();
                },
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondary),
                    textStyle: MaterialStateProperty.all(Theme.of(context).textTheme.button?.copyWith(
                        color: Colors.white,
                        fontSize: 19
                    ))
                ),
                child:Text("Confirmer",) ,
              ),
            ),
            SizedBox(height: 20,),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: ElevatedButton(
                onPressed: (){
                  Navigator.of(ctext).pop();
                  negative();
                },
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
                    textStyle: MaterialStateProperty.all(Theme.of(context).textTheme.button?.copyWith(
                        color: Colors.white,
                        fontSize: 19
                    ))
                ),
                child:Text("Annuler",) ,
              ),
            ),
            SizedBox(height: 10,),

          ],
        ),
      );
    });
  }

}
