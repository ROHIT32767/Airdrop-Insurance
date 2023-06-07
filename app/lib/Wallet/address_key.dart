import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddKeyScreen extends StatefulWidget {
  const AddKeyScreen({Key? key}) : super(key: key);

  @override
  State<AddKeyScreen> createState() => _AddKeyScreenState();
}

class _AddKeyScreenState extends State<AddKeyScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  // form key
  final _formKey = GlobalKey<FormState>();

  // editing controller
  final TextEditingController walletAddressController = TextEditingController();
  final TextEditingController privateKeyController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    //email field
    final addressField = TextFormField(
        style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
        autofocus: false,
        controller: walletAddressController,
        keyboardType: TextInputType.emailAddress,
        onSaved: (value) {
          walletAddressController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          fillColor: Colors.grey.shade100,
          filled: true,
          prefixIcon: const Icon(Icons.account_balance_wallet),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "MetaMask Wallet Address",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    //password field
    final keyField = TextFormField(
        style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
        autofocus: false,
        controller: privateKeyController,
        onSaved: (value) {
          privateKeyController.text = value!;
        },
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          fillColor: Colors.grey.shade100,
          filled: true,
          prefixIcon: const Icon(Icons.vpn_key),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "MetaMask Private Key",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    return Scaffold(
      // backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF00564D),
      ),
      backgroundColor: const Color(0xFF00564D),
      body: Stack(
        children: [
          Row(children: [
            SizedBox(
              height: 150,
              width: 35,
            ),
            Text(
              "Update Wallet",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 30),
            ),
          ]),
          Container(),
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 35, right: 35),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          addressField,
                          const SizedBox(
                            height: 30,
                          ),
                          keyField,
                          const SizedBox(
                            height: 40,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(12.0),
                                  backgroundColor: Colors.black,
                                  textStyle: const TextStyle(fontSize: 16),
                                ),
                                onPressed: () {
                                  updateInfo();
                                },
                                child: const Text('Save Details'),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // forgot password option
  void updateInfo() async {
    if (privateKeyController.text.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({'metamaskPK': privateKeyController.text});
    }
    if (walletAddressController.text.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({'metamaskWAddress': walletAddressController.text});
    }
    Fluttertoast.showToast(msg: "Wallet Details Updated");
  }
}
