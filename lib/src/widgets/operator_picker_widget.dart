import 'dart:async';
import 'dart:io';

import 'package:adjemin_gateway_sdk/adjemin_gateway_sdk.dart';
import 'package:adjemin_gateway_sdk/src/models/customer.dart';
import 'package:adjemin_gateway_sdk/src/models/gateway_transaction.dart';
import 'package:adjemin_gateway_sdk/src/models/payment_event.dart';
import 'package:adjemin_gateway_sdk/src/models/payment_state.dart';
import 'package:adjemin_gateway_sdk/src/network/gateway_exception.dart';
import 'package:adjemin_gateway_sdk/src/network/gateway_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final String currencyCode;
  final String? description;
  final String merchantTransactionId;
  final String webhookUrl;
  final String? returnUrl;
  final String? cancelUrl;
  final String baseUrl;
  final String clientId;
  final String clientSecret;
  final String sellerUsername;
  final String paymentType;

  const OperatorPickerWidget({
    required this.baseUrl,
    required this.clientId,
    required this.clientSecret,
    required this.sellerUsername,
    required this.paymentType,
    required this.countryCode,
    required this.isPayIn,
    required this.title,
    required this.amount,
    required this.currencyCode,
    required this.merchantTransactionId,
    required this.webhookUrl,

    this.returnUrl,
    this.cancelUrl,
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

  StreamController<PaymentEvent> paymentStreamController = StreamController.broadcast();

  bool listenerRunning = false;

  @override
  void initState() {
    super.initState();
    
    Timer.run(loadData);

    paymentStreamController.stream.listen((event) {
      if(event.currentState == PaymentState.INITIATED){

      }

      if(event.currentState == PaymentState.PENDING){

      }

      if(event.currentState == PaymentState.COMPLETED){
          print("paymentStreamController.stream.listen(($event) ");
          if(!listenerRunning){
            hidePaymentLoader();
           listenerRunning = true;
           _transactionCheckTimer?.cancel();

           if(event.success){

             _transactionCheckTimer?.cancel();
             if(mounted){
               Navigator.pop(context,event.data);
             }

           }else{

             print("EVENT => ${event.data}");
             
             if(event.data is GatewayException){
               _transactionCheckTimer?.cancel();

               if(mounted){
                 if(event.data.code == 300 && event.data.error!.contains('(203)')){
                   displayErrorMessage(context, "Une transaction similaire a été effectuée récemment, veuillez patienter 15 mins avant de réessayer", (){
                     Navigator.pop(context);
                   });
                 }else{
                   String errorMessage = event.data.message??event.data.error!;
                   if(errorMessage == "Payment has failed"){
                        errorMessage = "Le paiement a échoué";
                   }else if(errorMessage == "An error has occurred"){
                     errorMessage = "Une erreur est survenue";
                   }else{
                     errorMessage = event.data.error??"Une erreur est survenue";
                   }
                   displayErrorMessage(context, errorMessage, (){
                     Navigator.pop(context);
                   });
                 }
               }
             }else if(event.data is HandshakeException){

             }else{

             }
           }

         }

        }

    });
  }

  @override
  void dispose() {
    _transactionCheckTimer?.cancel();
    super.dispose();

  }

  @override
  void deactivate() {

    super.deactivate();
  }
  
  @override
  Widget build(BuildContext context) {


    return PopScope(
      canPop: false,
      child: _isPaymentLoading?_buildPaymentLoadingUi():
      Scaffold(
        appBar: AppBar(
          title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),),
          actions: [
            GestureDetector(
              onTap: (){

                displayPrompt(context, "Êtes-vous sûr de faire cela?", "Voulez vous confirmer que vous quittez sans finaliser le paiement ?",(){
                  Navigator.of(context).pop();
                },(){} );

              },
              child: const Icon(Icons.close,size: 30,),
            ),
            const SizedBox(width: 20,)
          ],
        ),
        body: _isLoading? const CustomProgressWidget(): _buildBody(),
      ),
    );
    
  }


  void loadData() {

    showProgress();

    _createPayment();

    GatewayRepository()
        .findOperatorsByCountry(widget.baseUrl,widget.countryCode.toString().split('.').last)
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
           print("Body ${onError.data.toString()}");
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
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.all(8.0),
            child: Text("Sélectionnez un moyen de paiement",
            style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Column(
            children: elements.map((e) => GestureDetector(
              onTap: ()async{
                //Navigator.of(context).pop(e);

                Customer? mCustomer;
                print("Operator => ${e.name!.toLowerCase().contains('carte bancaire')}");
                if(e.name!.toLowerCase().contains('carte')){
                  mCustomer = widget.customer;
                }else{
                  mCustomer  = await Navigator.push(context,
                      MaterialPageRoute(builder: (context)=> CustomerFormWidget(
                          customer:widget.customer
                      ))
                  );
                }


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
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: Card(
        shape:RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0)
        ) ,
        child: Row(
          children: [
            const SizedBox(width: 20,),
            Image.network(element.image!, width: 80,height: 80,),
            const SizedBox(width: 10,),
            Expanded(
              child:  Text("${element.name}", style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black
              ),),
            ),

            const SizedBox(width: 10,),
            const Icon(Icons.arrow_forward_ios_outlined),
            const SizedBox(width: 20,),

          ],
        ),
      ),
    );
  }

  void _createPayment(){

    GatewayRepository().createPayment(
        baseUrl: widget.baseUrl,
        clientId: widget.clientId,
        clientSecret: widget.clientSecret ,
        amount: widget.amount,
        currencyCode: widget.currencyCode,
        merchantTransId: widget.merchantTransactionId,
        sellerUsername: widget.sellerUsername,
        paymentType: widget.paymentType,
        designation: widget.description??"Paiement de facture",
        webhookUrl: widget.webhookUrl,
        returnUrl: widget.returnUrl,
        cancelUrl: widget.cancelUrl,
        customerEmail: widget.customer?.email,
        customerFirstname: widget.customer?.firstName,
        customerLastname: widget.customer?.lastName,
        customerRecipientNumber: widget.customer?.phoneNumber
    ).then((value){


    }).catchError((onError){

      print("Error $onError");

      hideProgress();

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


  void _pay({required Customer customer, required GatewayOperator gatewayOperator, String? otp}){
    showPaymentLoader(gatewayOperator);

    GatewayRepository().makePayment(
        baseUrl: widget.baseUrl,
        clientId: widget.clientId,
        clientSecret: widget.clientSecret ,
        amount: widget.amount,
        designation:widget.description??"Paiement de facture",
        gatewayOperatorCode: gatewayOperator.payinCode!,
        merchantTransId: widget.merchantTransactionId,
        webhookUrl: widget.webhookUrl,
        returnUrl: widget.returnUrl,
        cancelUrl: widget.cancelUrl,
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

        if(gatewayOperator.name!.toLowerCase().contains('wave')){

          _runTransactionChecker(gatewayOperator, widget.merchantTransactionId);

          if(value.paymentUrl != null){
            //Open Payment URL
            //final Uri _paymentUrl = Uri.parse(value.paymentUrl!);
            _openPaymentUrl(value.paymentUrl!);
          }

        }

        //TODO carte bancaire
        if(gatewayOperator.name!.toLowerCase().contains('carte')){

          _runTransactionChecker(gatewayOperator, widget.merchantTransactionId);

          if(value.paymentUrl != null){
            //Open Payment URL
            //final Uri _paymentUrl = Uri.parse(value.paymentUrl!);
            _openPaymentUrl(value.paymentUrl!);
          }

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

            const SizedBox(height: 50,),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 30,),
                Container(
                  child: Text("Transaction en cours",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                    ),),
                ),
                const SizedBox(width: 40,),
                InkWell(
                  onTap: (){
                    Navigator.of(context).pop();
                  },
                  child: const Icon(Icons.close,size: 30,),
                )
              ],
            ),
            const SizedBox(height: 100,),
            Center(
              child: Image.network(_paymentOperatorSelected!.image!,height: 80,),
            ),
            const SizedBox(height: 10,),
            Text("${_paymentOperatorSelected!.name!}",
            style: Theme.of(context).textTheme.headlineSmall,),
            const SizedBox(height: 20,),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              alignment: Alignment.center,
              child: Text(getLoadingMessage(widget.isPayIn,_paymentOperatorSelected!, _isWaitingAcceptation),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 16
                ),),
            ),

            const SizedBox(height: 100,),
            const Center(
              child: SizedBox(
                height: 100.0,
                width: 100.0,
                child: CircularProgressIndicator(
                  strokeWidth: 10.0,
                ),
              ),
            ),
            const SizedBox(height: 20,),
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
         _pay(customer: mCustomer, gatewayOperator: e,otp: code);
       }else{
         Navigator.of(context).pop();
       }
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

    if(e.name!.toLowerCase().contains('wave')){
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

    if(e.name!.toLowerCase().contains('carte')){
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
      }else if(operator.name!.toLowerCase().contains("carte")){
        return "Veuillez patienter, nous vous redirigeons vers le portail de paiement par  ${_paymentOperatorSelected!.name}.";
      }else{
        return "En attente de validation de la transaction.";
      }
    }else{
      return "Traitement de la transaction ${_paymentOperatorSelected!.name} en cours...";
    }




  }

  _runTransactionChecker(GatewayOperator operator, String transactionId){

    _transactionCheckTimer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      _checkTransactionStatus(operator, transactionId);
    });
  }

  _checkTransactionStatus(GatewayOperator operator, String transactionId){

    if(!_isPaymentLoading){

      showPaymentLoader(operator);
    }

    GatewayRepository()
        .checkPaymentStatus(
      baseUrl:widget.baseUrl,
      merchantTransactionId:transactionId,
      clientId: widget.clientId,
      clientSecret: widget.clientSecret
    )
        .then((value){

         if(value.status == GatewayTransaction.SUCCESSFUL){

           paymentStreamController.add(PaymentEvent(
             currentState: PaymentState.COMPLETED,
             success: true,
             data: value
           ));
         }else if(value.status == GatewayTransaction.FAILED){
           paymentStreamController.add(PaymentEvent(
               currentState: PaymentState.COMPLETED,
               success: false,
               data: value
           ));
         }else{
           paymentStreamController.add(PaymentEvent(
               currentState: PaymentState.PENDING,
               success: false,
               data: value
           ));
         }

       }).catchError((onError){
         print("Error _checkTransactionStatus() =>>> $onError");
         if(onError is HandshakeException || onError is DioException){
            _checkTransactionStatus(operator, transactionId);
         }else{
           paymentStreamController.add(PaymentEvent(
               currentState: PaymentState.COMPLETED,
               success: false,
               data: onError
           ));
         }


    });

  }

  displayErrorMessage(BuildContext context, String message, Function() action){
    showModalBottomSheet(context: context, builder: (ctext){
      return Container(
        padding: const EdgeInsets.all(16.0),
        height: 200,
        color: Colors.white,
        child: Column(
          children: [

            Container(
              child: Text("Erreur rencontrée",style: Theme.of(context).textTheme.headlineSmall),
            ),
            const SizedBox(height: 20,),
            Container(
              child: Text(message,style: Theme.of(context).textTheme.bodyMedium),
            ),
            const SizedBox(height: 20,),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: ElevatedButton(
                onPressed: (){
                  Navigator.of(ctext).pop();
                  action();
                },
                style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.secondary),
                    textStyle: WidgetStateProperty.all(TextStyle(
                        color: Colors.white,
                        fontSize: 19
                    ))
                ),
                child:const Text("D'accord",) ,
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
        padding: const EdgeInsets.all(16.0),
        height: 260,
        color: Colors.white,
        child: Column(
          children: [
            Container(
              child: Text("$title",style: Theme.of(context).textTheme.headlineSmall),
            ),
            const SizedBox(height: 20,),
            Container(
              child: Text(message,style: Theme.of(context).textTheme.bodyMedium),
            ),
            const SizedBox(height: 20,),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: ElevatedButton(
                onPressed: (){
                  Navigator.of(ctext).pop();
                  positive();
                },
                style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.secondary),
                    textStyle: WidgetStateProperty.all(TextStyle(
                        color: Colors.white,
                        fontSize: 19
                    ))
                ),
                child:const Text("Confirmer",) ,
              ),
            ),
            const SizedBox(height: 20,),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: ElevatedButton(
                onPressed: (){
                  Navigator.of(ctext).pop();
                  negative();
                },
                style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.primary),
                    textStyle: WidgetStateProperty.all(TextStyle(
                        color: Colors.white,
                        fontSize: 19
                    ))
                ),
                child:const Text("Annuler",) ,
              ),
            ),
            const SizedBox(height: 10,),

          ],
        ),
      );
    });
  }

   _openPaymentUrl(String paymentUrl) async{
     await launch(paymentUrl);
  }

}
