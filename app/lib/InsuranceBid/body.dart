// ignore_for_file: avoid_print

import 'package:app/model/basket_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'details.dart';
import 'title.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/model/user_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as cloud_firebase;

class InsuranceDetails extends StatefulWidget {
  final BasketModel basket;
  const InsuranceDetails({Key? key, required this.basket}) : super(key: key);
  @override
  State<InsuranceDetails> createState() => _InsuranceDetailsState();
}

class _InsuranceDetailsState extends State<InsuranceDetails> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  // Crypto related
  late Client httpClient;
  late Web3Client ethereumClient;
  String ethereumClientUrl = dotenv.env['INFURA_URL']!;
  String contractName = dotenv.env['CONTRACT_NAME']!;
  String masterWallet = dotenv.env['BASKET_1']!;
  BigInt balance = BigInt.from(0);
  final Color bcolor = const Color(0xFF3D82AE);
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      cloud_firebase.FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .get()
          .then((value) {
        loggedInUser = UserModel.fromMap(value.data());
        setState(() {});
        if (loggedInUser.metamaskPK == null ||
            loggedInUser.metamaskWAddress == null) {
          Fluttertoast.showToast(
              msg: "Please connect to Metamask",
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
          Navigator.popAndPushNamed(context, "add_key");
        }
        getBalance();
        httpClient = Client();
        ethereumClient = Web3Client(ethereumClientUrl, httpClient);
      });
    });
  }

  Future<void> getBalance() async {
    setState(() {});
    final addr = EthereumAddress.fromHex(loggedInUser.metamaskWAddress!);
    List<dynamic> result = await query('balanceOf', [addr]);
    balance = BigInt.parse(result[0].toString());
    print("balance");
    print(balance.toString());
    setState(() {});
  }

  Future<DeployedContract> getContract() async {
    String abi = await rootBundle.loadString("assets/token/abi.json");
    String contractAddress = dotenv.env["CONTRACT_ADDRESS"]!;

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
    EthPrivateKey credential = EthPrivateKey.fromHex(loggedInUser.metamaskPK!);
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
    print(result);
    return result;
  }

  void updateUserbaskets(Map<String, dynamic> data) {
    cloud_firebase.FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get()
        .then((value) {
      UserModel loggedInUser = UserModel.fromMap(value.data());
      loggedInUser.baskets?.add(data);
      cloud_firebase.FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({'baskets': loggedInUser.baskets});
    });
  }

  Future<void> purchase() async {
    // Check if user already has this plan that is active
    print("entered");
    if (loggedInUser.baskets!=null) {
      for (var x in loggedInUser.baskets!) {
        if (x['uuid'] == widget.basket.uuid) {
          Fluttertoast.showToast(
              msg: "This insurance basket is already active",
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
          return;
        }
      }
    }
    print("before amount");
    int? amount = widget.basket.depositamount;
    print("amount = ");
    print(amount);
    BigInt parsedAmount =
        BigInt.from(amount as num) * (BigInt.from(10).pow(18));
    print("parsedAMount: ");
    print(parsedAmount);
    final addr = EthereumAddress.fromHex(masterWallet);
    //print(parsedAmount.toString());
    await transaction("transfer", [addr, parsedAmount]);
    print("Line 147");
    Fluttertoast.showToast(msg: "Basket purchased");
    Map<String, dynamic> insuranceInfo = {
      "uuid": widget.basket.uuid!,
      "name": widget.basket.name!,
      "automated": widget.basket.automated!,
    };
    print("purchased");
    //print("purchased");
    //print(result);
    updateUserbaskets(insuranceInfo);
  }

  @override
  Widget build(BuildContext context) {
    // It provide us total height and width
    Size size = MediaQuery.of(context).size;
    double s = MediaQuery.of(context).padding.top;
    AppBar appBar =
        AppBar(elevation: 0, backgroundColor: const Color(0xFF3D82AE));
    double appHeight = appBar.preferredSize.height;
    return Scaffold(
        appBar: appBar,
        body: Container(
          color: bcolor,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: size.height - appHeight - s,
                child: Stack(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(top: size.height * 0.37),
                      padding: EdgeInsets.only(
                        top: size.height * 0.04,
                      ),
                      // height: 500,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      // child: Description(index: index),
                      child: Column(
                        children: <Widget>[
                          Description(basket: widget.basket),
                          Expanded(child: Container()),
                          Container(
                            foregroundDecoration: BoxDecoration(
                                color: (balance.compareTo(
                                            BigInt.from(widget.basket.cost!)) >=
                                        0)
                                    ? Colors.transparent
                                    : Colors.grey,
                                backgroundBlendMode: BlendMode.saturation),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(12.0),
                                backgroundColor: bcolor,
                                textStyle: const TextStyle(fontSize: 16),
                              ),
                              onPressed: () {
                                (balance.compareTo(
                                            BigInt.from(widget.basket.cost!)) >=
                                        0)
                                    ? purchase()
                                    : Fluttertoast.showToast(
                                        msg: "Insufficient Balance",
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        fontSize: 16.0);
                              },
                              child: const Text('Take Risk for this basket'),
                            ),
                          )
                        ],
                      ),
                    ),
                    Header(basket: widget.basket)
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
