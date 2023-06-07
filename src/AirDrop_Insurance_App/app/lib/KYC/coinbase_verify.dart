import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';
import 'package:app/model/user_model.dart';

class CoinbaseVerifyPage extends StatefulWidget {
  const CoinbaseVerifyPage({Key? key}) : super(key: key);

  @override
  CoinbaseVerifyPageState createState() => CoinbaseVerifyPageState();
}

class CoinbaseVerifyPageState extends State<CoinbaseVerifyPage> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    // ignore: unused_local_variable
    bool isLoading = true;

    return Scaffold(
      body: Stack(
        children: [
        WebViewPlus(
            initialUrl:
                'https://www.coinbase.com/oauth/authorize?client_id=ae3176dadee544bf8bdc90cc695e9d138f1503ebf97b5a8f435e2cf2259f7d1c&redirect_uri=urn%3Aietf%3Awg%3Aoauth%3A2.0%3Aoob&response_type=code&scope=wallet%3Auser%3Aread',
            javascriptMode: JavascriptMode.unrestricted,
            onPageFinished: (finish) {
              setState(() {
                isLoading = false;
              });
            },
            navigationDelegate: (NavigationRequest request) {
              if (request.url.contains("coinbase.com/oauth/authorize") &&
                  !request.url.contains("client_id")) {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(user!.uid)
                    .update({'coinbaseVerified': true});
                Navigator.pop(context);
              }
              if (request.url.contains("coinbase.com")) {
                return NavigationDecision.navigate;
              } else {
                return NavigationDecision.prevent;
              }
            },
          )
        ],
      ),
    );
  }
}
