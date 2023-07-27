import 'package:adjemin_gateway_sdk/adjemin_gateway_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:uuid/uuid.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "lib/.env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({Key? key }) : super(key: key);

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
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()async {

          final String merchantTransId = uuid.v4().split('-').last;
          print("merchantTransId => $merchantTransId");
          final String baseUrl = "https://api.adjem.in";

          final String returnUrl = "https://adjemin.page.link/vhUX";

          final GatewayTransaction? result = await Navigator.push(context,
              MaterialPageRoute(builder: (context)=> OperatorPickerWidget(
                baseUrl: baseUrl,
                clientId: dotenv.env['CLIENT_ID']!,
                clientSecret: dotenv.env['CLIENT_SECRET']!,
                sellerUsername: dotenv.env['SELLER_USERNAME']!,
                paymentType: 'gateway',
                title: 'Payer une commande',
                description: 'Paiement apport initial',
                amount: 100,
                currencyCode: "XOF",
                merchantTransactionId: merchantTransId,
                webhookUrl:"https://api.donypay.com/v1/customers/payments/adjeminpay/callback",
                returnUrl:returnUrl,
                cancelUrl:returnUrl,
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

            displayErrorMessage(context, "${result.merchantTransId} ${result.status}", (){

            });

          }else{

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

