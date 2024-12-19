import 'package:adjemin_gateway_sdk/src/models/customer.dart';
import 'package:adjemin_gateway_sdk/src/models/gateway_operator.dart';
import 'package:flutter/material.dart';

import 'custom_progress_widget.dart';

class CashPaymentWidget extends StatefulWidget {
  final GatewayOperator operator;
  final bool isPayIn;
  final Customer customer;
  final int amount;
  final String? description;
  final String merchantTransactionId;
  const CashPaymentWidget({
    required this.operator,
    required this.isPayIn,
    required this.amount,
    this.description,
    required this.customer,
    required this.merchantTransactionId
  }) ;

  @override
  _CashPaymentWidgetState createState() => _CashPaymentWidgetState();
}

class _CashPaymentWidgetState extends State<CashPaymentWidget> {

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white ,
      appBar: AppBar(
        title: Text(widget.description??"Effectuer une transaction", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),),
        actions: [
          GestureDetector(
            onTap: (){
              Navigator.of(context).pop(false);
            },
            child: const Icon(Icons.close,size: 30,),
          ),
          const SizedBox(width: 20,)
        ],
      ),
      body: _isLoading? const CustomProgressWidget():
      _buildBody(),
    );
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

          const SizedBox(height: 10,),
          _buildCartUi(),
          _buildCustomerItemUi(widget.customer),

          const SizedBox(height: 20,),

          _buildPayWithUi(),

          Container(
            width: MediaQuery.of(context).size.width,
            height: 50,
            margin: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: (){
                  Navigator.of(context).pop(true);
              },
              style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.secondary),
                  textStyle: WidgetStateProperty.all(const TextStyle(
                      color: Colors.white,
                      fontSize: 19
                  ))
              ),
              child:const Text("Payer", style: TextStyle(
                color: Colors.white
              ),) ,
            ),
          ),

          widget.operator.name!.toLowerCase().contains('carte')?const SizedBox():Container(
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text("L'étape suivante déclenchera une demande de validation par USSD de l'opérateur ${widget.operator.name}",
              style: const TextStyle(
                  color: Colors.black
              ),
            ),
          ),
          const SizedBox(height: 20,),



        ],
      ),
    );

  }

  Widget _buildCustomerItemUi(Customer customer) {
    return Container(
      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      padding: const EdgeInsets.all( 8.0),
      margin: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.transparent,
            backgroundImage: NetworkImage(customer.photoUrl != null && customer.photoUrl!.isNotEmpty?
            customer.photoUrl!: "https://i.imgur.com/vQBp4EF.png"),
            radius: 30.0,
          ),
          const SizedBox(width: 10,),
          Expanded(
            child:  Column(
              children: [
                Container(
                  alignment: Alignment.topLeft,
                  child: Text("${widget.customer.firstName} ${widget.customer.lastName}", style: Theme.of(context).textTheme.titleSmall,),
                ),
                Container(
                  alignment: Alignment.topLeft,
                  child: Text(customer.email != null && customer.email!.isNotEmpty?"${customer.email}":"${customer.phoneNumber}", style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500]
                  ),),
                )
              ],
            ),
          ),

          const SizedBox(width: 10,),


        ],
      ),
    );
  }

  _buildCartUi() {

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            child: const Icon(Icons.shopping_cart_outlined, size: 25,),
          ),
          const SizedBox(width: 10,),
          Container(
            height: 50,
            alignment: Alignment.center,
            child: Text("${widget.amount} ${widget.operator.currencyCode}",
             style: Theme.of(context).textTheme.headlineMedium?.copyWith(
               fontSize: 30.0,
               color: Colors.black
             ),
            ),
          )

        ],
      ),
    );
  }

  Widget _buildPayWithUi() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            child: Text("Payer avec",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.grey
            ),
            ),
          ),
          const SizedBox(height: 20.0,),

          Row(
            children: [
              Image.network(widget.operator.image!, width: 60,),
              const SizedBox(width: 10.0,),
              Expanded(
                child: Column(
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        child: Text("${widget.operator.name}",
                          style: Theme.of(context).textTheme.headlineSmall,),
                      ),
                      widget.operator.name!.toLowerCase().contains('carte')?const SizedBox():Container(
                        alignment: Alignment.topLeft,
                        child: Text("+${widget.customer.dialCode} ${widget.customer.phoneNumber}",
                         style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                           color: Colors.grey[500]
                         ),
                        ),
                      ),
                      widget.operator.name!.toLowerCase().contains('carte')?const SizedBox():
                      Container(
                        alignment: Alignment.topLeft,
                        child: Text("Ce numéro de téléphone sera débité du montant à payer",
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Colors.grey[500]
                          ),
                        ),
                      )
                    ],
                  )
              )
              
            ],
          ),

          const SizedBox(height: 20.0,)

        ],
      ),
    );
  }



}
