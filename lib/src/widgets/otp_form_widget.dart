import 'package:adjemin_gateway_sdk/adjemin_gateway_sdk.dart';
import 'package:flutter/material.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';

class OtpFormWidget extends StatefulWidget {

  final GatewayOperator gatewayOperator;
  final String title;

  const OtpFormWidget({required this.title, required this.gatewayOperator});

  @override
  _OtpFormWidgetState createState() => _OtpFormWidgetState();
}

class _OtpFormWidgetState extends State<OtpFormWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [

            SizedBox(height: 50.0,),

            Center(
              child:  Image.network(widget.gatewayOperator.image!, width: 80,height: 80,),
            ),
            SizedBox(height: 10.0,),
            Container(
              child: Text("${widget.gatewayOperator.name}", style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black
              ),),
            ),

            SizedBox(height: 20.0,),
            Container(
              child: Text("Obtenez un code validation en cliquant sur", style: Theme.of(context)
                .textTheme.caption,),
            ),
            SizedBox(height: 20.0,),
            Center(
              child: Row(
                children: [
                  Icon(Icons.phone),
                  SizedBox(height: 20.0,),
                  Text("#144*22#", style: Theme.of(context).textTheme.headline5,)
                ],
              ) ,
            ),
            SizedBox(height: 20.0,),
            Container(
              child: Text("Entrez le code reçu  dans le champs ci-dessous:", style: Theme.of(context)
                  .textTheme.caption,),
            ),

            SizedBox(height: 20.0,),
            Center(
              child: OTPTextField(
                length: 4,
                width: MediaQuery.of(context).size.width,
                textFieldAlignment: MainAxisAlignment.spaceAround,
                fieldWidth: 80,
                fieldStyle: FieldStyle.underline,
                style: TextStyle(fontSize: 17),
                onCompleted: (pin) {
                  print("Completed: " + pin);
                },
              ),
            ),
            SizedBox(height: 20.0,),

          ],
        ),
      ),
    );
  }
}
