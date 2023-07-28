# Integrate Adjemin Gateway SDK

Gateway sdk to allow payment and transfer in Adjemin app

<img src="https://gitlab.com/adjemin/adjemin_gateway_sdk/-/raw/main/picture/payment.png" alt="screenshot"/>

## 1. Add the package to your project
Add the adjemin_gateway_sdk package as a dependancy in your `pubspec.yaml` file.

```yaml
    dependencies:
    flutter:
        sdk: flutter
    adjemin_gateway_sdk:
      git:
        url: https://github.com/adjemin/gateway_flutter_sdk.git
        ref: main
```
## 3. How to use
You must use `OperatorPickerWidget`
```dart
OperatorPickerWidget(
    baseUrl: 'https://api.adjem.in',
    clientId: 'CLIENT_ID',
    clientSecret: 'CLIENT_SECRET',
    sellerUsername: 'SELLER_USERNAME',
    paymentType: 'gateway',
    title: 'Payer une commande',
    description: 'Payer une commande',
    amount: 100,
    merchantTransactionId: uuid.v4(),
    webhookUrl:"https://your-webhook-url/v1/customers/payments/callback",
    returnUrl:"https://your-return-url",
    cancelUrl:"https://your-cancel-url",
    isPayIn: true,
    countryCode: Country.CI,
    customer: Customer(
        firstName: "Ange",
        lastName: "Bagui",
        photoUrl: "https://i.imgur.com/dAApjNt.jpg",
        dialCode: "225",
        phoneNumber: "0556888385",
        email: "angebagui@gmail.com"
    ),
)
```
## PayIn
Accept payment from mobile money


Example
```dart
import 'package:adjemin_gateway_sdk/adjemin_gateway_sdk.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


import 'package:uuid/uuid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: Colors.green,
            secondary: Colors.blue[500]
        ),
        textTheme: GoogleFonts.montserratTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var uuid = Uuid();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()async {
          final GatewayTransaction? result = await Navigator.push(context,
              MaterialPageRoute(builder: (context)=> OperatorPickerWidget(
                baseUrl:'https://api-test.adjem.in',
                title: 'Payer une commande',
                description: 'Payer une commande',
                amount: 100,
                merchantTransactionId: uuid.v4(),
                webhookUrl:"https://adjemin.com",
                isPayIn: true,
                countryCode: Country.CI,
                customer: Customer(
                    firstName: "Ange",
                    lastName: "Bagui",
                    photoUrl: "https://i.imgur.com/dAApjNt.jpg",
                    dialCode: "225",
                    phoneNumber: "0556888385",
                    email: "angebagui@gmail.com"
                ),
              ))
          );

          if(result != null){

            print("Payment result =>>  $result");
            
            //result.status can be GatewayTransaction.SUCCESSFUL
            //result.status can be GatewayTransaction.FAILED
            //result.status can be GatewayTransaction.PENDING
            //result.status can be GatewayTransaction.INITIATED

            displayErrorMessage(context, "${result.merchantTransId} ${result.status}", (){

            });

          }
        },
        child: Icon(Icons.add),

      ),
    );
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
              child: Text("Message",style: Theme.of(context).textTheme.headline6),
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
}

```

## PayOut
Not Avalaible
