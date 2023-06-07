// ignore_for_file: depend_on_referenced_packages

import 'package:adminpage/ClaimApproval/verifiers_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:adminpage/model/user_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as cloud_firebase;
// import 'package:webview_flutter/webview_flutter.dart';
// // #docregion platform_imports
// // Import for Android features.
// import 'package:webview_flutter_android/webview_flutter_android.dart';
// // Import for iOS features.
// import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

class ClaimViewDetails extends StatefulWidget {
  final cloud_firebase.DocumentSnapshot doc;
  final String masterKey;

  const ClaimViewDetails({Key? key, required this.doc, required this.masterKey})
      : super(key: key);

  @override
  ClaimViewDetailsState createState() => ClaimViewDetailsState();
}

void animateViewerDialog(BuildContext context, Widget dchild) {
  showGeneralDialog(
    context: context,
    barrierLabel: "Barrier",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (_, __, ___) {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(40)),
          child: dchild,
        ),
      );
    },
    transitionBuilder: (_, anim, __, child) {
      Tween<Offset> tween;
      if (anim.status == AnimationStatus.reverse) {
        tween = Tween(begin: const Offset(-1, 0), end: Offset.zero);
      } else {
        tween = Tween(begin: const Offset(1, 0), end: Offset.zero);
      }

      return SlideTransition(
        position: tween.animate(anim),
        child: FadeTransition(
          opacity: anim,
          child: child,
        ),
      );
    },
  );
}

class ClaimViewDetailsState extends State<ClaimViewDetails> {
  bool isPlayingAudio = false;
  var balance = BigInt.from(0);
  late TextEditingController feedbackController;
  late Client httpClient;
  late Web3Client ethereumClient;
  User? user = FirebaseAuth.instance.currentUser;
  String ethereumClientUrl = dotenv.env['INFURA_URL']!;
  String contractName = dotenv.env['CONTRACT_NAME']!;
  String masterWallet = dotenv.env['MASTER_WALLET']!;
  UserModel loggedInUser = UserModel();

  @override
  void initState() {
    super.initState();
    feedbackController = TextEditingController();
    httpClient = Client();
    ethereumClient = Web3Client(ethereumClientUrl, httpClient);
    getBalance();
  }

  @override
  void dispose() {
    feedbackController.dispose();
    super.dispose();
  }

  Future<void> getBalance() async {
    setState(() {});
    final addr = EthereumAddress.fromHex(masterWallet);
    List<dynamic> result = await query('balanceOf', [addr]);
    balance = BigInt.parse(result[0].toString());
    //print(balance.toString());
    setState(() {});
  }

  Future<DeployedContract> getContract() async {
    String abi = await rootBundle.loadString("assets/token/abi.json");
    String contractAddress = dotenv.env["CONTRACT_ADDRESS"]!;
    //print(contractAddress);
    DeployedContract contract = DeployedContract(
      ContractAbi.fromJson(abi, contractName),
      EthereumAddress.fromHex(contractAddress),
    );
    return contract;
  }

  Future<List<dynamic>> query(String functionName, List<dynamic> args) async {
    DeployedContract contract = await getContract();
    ContractFunction function = contract.function(functionName);
    List<dynamic> result = await ethereumClient.call(
        contract: contract, function: function, params: args);
    return result;
  }

  Future<String> transaction(String functionName, List<dynamic> args) async {
    //print(widget.masterKey);
    EthPrivateKey credential = EthPrivateKey.fromHex(widget.masterKey);
    DeployedContract contract = await getContract();
    ContractFunction function = contract.function(functionName);
    dynamic result = await ethereumClient.sendTransaction(
      credential,
      Transaction.callContract(
        contract: contract,
        function: function,
        parameters: args,
      ),
      fetchChainIdFromNetworkId: true,
      chainId: null,
    );
    return result;
  }

  Future<void> payout() async {
    var amount = 0;
    await cloud_firebase.FirebaseFirestore.instance
        .collection('insurance options')
        .doc(widget.doc.get("option"))
        .get()
        .then((value) {
      amount = value.data()?["payout"];
    });
    cloud_firebase.FirebaseFirestore.instance
        .collection("users")
        .doc(widget.doc.get("uid"))
        .get()
        .then((value) async {
      String userWallet = value.data()?["metamaskWAddress"];
      final addr = EthereumAddress.fromHex(userWallet);
      BigInt parsedAmount = BigInt.from(amount) * (BigInt.from(10).pow(18));
      //print(parsedAmount.toString());
      await transaction("transfer", [addr, parsedAmount]);
      Fluttertoast.showToast(msg: "Insurance claim approved");
      //print(result);
    });
    // updateUserOptions(insurance_info);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: Text(widget.doc.get("user_name")),
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 10, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Claimed at: ",
                          style: GoogleFonts.openSans(
                              textStyle: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400))),
                      Text(
                        DateFormat.yMMMd()
                            .add_jm()
                            .format(widget.doc.get("timestamp").toDate())
                            .toString(),
                        style: GoogleFonts.openSans(
                            textStyle: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w400)),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Insurance Plan:",
                          style: GoogleFonts.openSans(
                              textStyle: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400))),
                      Text(
                        widget.doc.get("option_name"),
                        style: GoogleFonts.openSans(
                            textStyle: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w400)),
                      ),
                    ],
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Document Uploaded:",
                          style: GoogleFonts.openSans(
                              textStyle: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400)),
                        ),
                        widget.doc.get("document").toString().isNotEmpty
                            ? TextButton(
                                onPressed: (() {
                                  final Stack wview = Stack(
                                    children: [
                                      WebViewPlus(
                                        initialUrl: widget.doc.get('document'),
                                        javascriptMode:
                                            JavascriptMode.unrestricted,
                                      ),
                                    ],
                                  );
                                  animateViewerDialog(context, wview);
                                }),
                                child: const Text("Open"),
                              )
                            : Text(
                                "None",
                                style: GoogleFonts.openSans(
                                    textStyle: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400)),
                              ),
                      ]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Verifiers:",
                          style: GoogleFonts.openSans(
                              textStyle: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400))),
                      TextButton(
                        onPressed: (() {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => VerifierListScreen(
                                        verifyIds: widget.doc.get("verifiers"),
                                      )));
                        }),
                        child: const Text("Open"),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(widget.doc.get("description"),
                      style: GoogleFonts.openSans(
                          textStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w400))),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        child: Row(
                          children: [
                            IconButton(
                                onPressed: (() {}),
                                icon: const FaIcon(
                                  FontAwesomeIcons.personCircleCheck,
                                  color: Colors.green,
                                )),
                            const Text(
                              'Verify',
                              style:
                                  TextStyle(fontSize: 15, color: Colors.green),
                            ),
                          ],
                        ),
                        onPressed: () async {
                          // Update the database with claim status
                          await cloud_firebase.FirebaseFirestore.instance
                              .collection('claims')
                              .doc(widget.doc.get('uuid'))
                              .update({
                            "claim_status": 1,
                            "feedback": cloud_firebase.FieldValue.delete(),
                          });
                          payout();
                        },
                      ),
                      TextButton(
                        child: Row(
                          children: [
                            IconButton(
                                onPressed: (() {}),
                                icon: const FaIcon(
                                  FontAwesomeIcons.ban,
                                  color: Colors.red,
                                )),
                            const Text(
                              'Reject',
                              style: TextStyle(fontSize: 15, color: Colors.red),
                            ),
                          ],
                        ),
                        onPressed: () async {
                          final feedback = await openFeedbackForm();
                          if (feedback != null) {
                            await cloud_firebase.FirebaseFirestore.instance
                                .collection('claims')
                                .doc(widget.doc.get('uuid'))
                                .update(
                                    {'claim_status': 2, 'feedback': feedback});
                            Fluttertoast.showToast(
                                msg:
                                    "User was rejected and provided feedback.");
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ))
        ],
      ),
    );
  }

  Future<String?> openFeedbackForm() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Provide feedback"),
          content: TextField(
            keyboardType: TextInputType.multiline,
            maxLines: null,
            autofocus: true,
            decoration:
                const InputDecoration(hintText: "Reason for refuting claim..."),
            controller: feedbackController,
          ),
          actions: [
            TextButton(
                onPressed: submitFeedback,
                child: Row(
                  children: [
                    IconButton(
                        onPressed: submitFeedback,
                        icon: const FaIcon(
                          FontAwesomeIcons.ban,
                          color: Colors.red,
                        )),
                    const Text(
                      'Reject',
                      style: TextStyle(fontSize: 15, color: Colors.red),
                    ),
                  ],
                ))
          ],
        ),
      );

  void submitFeedback() {
    if (feedbackController.text == "") {
      Fluttertoast.showToast(
          msg: "Please provide some feedback before refuting.");
    } else {
      Navigator.of(context).pop(feedbackController.text);
    }
  }
}
