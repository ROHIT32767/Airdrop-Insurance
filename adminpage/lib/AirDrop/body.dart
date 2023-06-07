import 'package:adminpage/model/option_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'details.dart';
import 'title.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:adminpage/model/user_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as cloud_firebase;

class InsuranceDetails extends StatefulWidget {
  final OptionModel option;
  final String masterKey;
  const InsuranceDetails(
      {Key? key, required this.option, required this.masterKey})
      : super(key: key);
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
  String masterWallet = dotenv.env['MASTER_WALLET']!;
  BigInt balance = BigInt.from(0);
  List<String> wallets = [];
  final Color bcolor = const Color(0xff924444);
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await cloud_firebase.FirebaseFirestore.instance
          .collection("users")
          // .where("options", arrayContains: {"uuid": widget.option.uuid})
          .get()
          .then((values) {
        final now = DateTime.now();
        for (var value in values.docs) {
          var user = value.data();
          if (user["options"] != null) {
            for (var option in user["options"]) {
              if (option["uuid"] == widget.option.uuid &&
                  now.difference(option["timestamp"].toDate()).inDays < 7) {
                wallets.add(user["metamaskWAddress"]);
              }
            }
          }
          // wallets.add(value.data()["metamaskWAddress"]);
        }
      });
      setState(() {});
      getBalance();
      httpClient = Client();
      ethereumClient = Web3Client(ethereumClientUrl, httpClient);
    });
  }

  Future<void> getBalance() async {
    final addr = EthereumAddress.fromHex(masterWallet);
    List<dynamic> result = await query('balanceOf', [addr]);
    balance = BigInt.parse(result[0].toString());
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

  void updateUserOptions(Map<String, dynamic> data) {
    cloud_firebase.FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get()
        .then((value) {
      UserModel loggedInUser = UserModel.fromMap(value.data());
      loggedInUser.options?.add(data);
      cloud_firebase.FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({'options': loggedInUser.options});
    });
  }

  Future<void> airdrop() async {
    // Check if user already has this plan that is active
    int amount = widget.option.payout!;
    BigInt parsedAmount = BigInt.from(amount) * (BigInt.from(10).pow(18));
    for (var wallet in wallets) {
      final addr = EthereumAddress.fromHex(wallet);
      await transaction("transfer", [addr, parsedAmount]);
    }
    Fluttertoast.showToast(msg: "Insurance Airdropped");
  }

  @override
  Widget build(BuildContext context) {
    // It provide us total height and width
    Size size = MediaQuery.of(context).size;
    double s = MediaQuery.of(context).padding.top;
    AppBar appBar =
        AppBar(elevation: 0, backgroundColor: const Color(0xff924444));
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
                          Description(option: widget.option),
                          Expanded(child: Container()),
                          Container(
                            foregroundDecoration: BoxDecoration(
                                color: (balance.compareTo(
                                            BigInt.from(widget.option.cost!)) >=
                                        0)
                                    ? Colors.transparent
                                    : Colors.grey,
                                backgroundBlendMode: BlendMode.saturation),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(15.0), backgroundColor: bcolor,
                                textStyle: const TextStyle(fontSize: 25),
                              ),
                              onPressed: () {
                                (balance.compareTo(
                                            BigInt.from(widget.option.cost!)) >=
                                        0)
                                    ? airdrop()
                                    : Fluttertoast.showToast(
                                        msg: "Insufficient Balance",
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        fontSize: 16.0);
                              },
                              child: const Text('Airdrop'),
                            ),
                          )
                        ],
                      ),
                    ),
                    Header(
                      option: widget.option,
                      userCount: wallets.length,
                    )
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
