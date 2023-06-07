import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:cloud_firestore/cloud_firestore.dart' as cloud_firebase;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/model/user_model.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  late Client httpClient;
  late Web3Client ethereumClient;
  TextEditingController controller = TextEditingController();
  TextEditingController addressController = TextEditingController();

  String ethereumClientUrl = dotenv.env['INFURA_URL']!;

  String contractName = dotenv.env['CONTRACT_NAME']!;

  BigInt balance = BigInt.from(0);
  bool loading = false;

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
    // print("res");
    // print(result);
    return result;
  }

  Future<DeployedContract> getContract() async {
    String abi = await rootBundle.loadString("assets/token/abi.json");
    // String contractAddress = dotenv.env["CONTRACT_ADDRESS"]!;
    // TODO:
    String contractAddress = "0x7ad62035a6C1E0eB0569511B7FD0C5B19FCd9e0d";
    DeployedContract contract = DeployedContract(
      ContractAbi.fromJson(abi, contractName),
      EthereumAddress.fromHex(contractAddress),
    );
    return contract;
  }

  Future<void> getBalance() async {
    loading = true;
    setState(() {});
    final addr = EthereumAddress.fromHex(loggedInUser.metamaskWAddress!);

    // print(addr);
    // EtherAmount.zero();
    List<dynamic> result = await query('balanceOf', [addr]);
    balance = BigInt.parse(result[0].toString());
   
    loading = false;
    
    setState(() {});
  }

  Future<void> deposit(int amount, String selectedAddress) async {
    BigInt parsedAmount = BigInt.from(amount) * (BigInt.from(10).pow(18));
    final addr = EthereumAddress.fromHex(selectedAddress);
    //print(selectedAddress);
    //print(parsedAmount.toString());
    await transaction("transfer", [addr, parsedAmount]);
    Fluttertoast.showToast(msg: "Transaction placed");
    //print("deposited");
    //print(result);
  }
  
  

  Future<void> withdraw(int amount) async {
    BigInt parsedAmount = BigInt.from(amount);
    await transaction("withdraw", [parsedAmount]);
    //print("withdraw done");
    //print(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFF00564D),
        ),
        body: Container(
          color: const Color(0xFF00564D),
          child: Center(
            child: Column(
              children: [
                const SizedBox(
                  height: 30,
                ),
                const Text(
                  "Current Balance",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 25),
                ),
                const SizedBox(
                  height: 10,
                ),
                loading
                    ? const SizedBox(
                        height: 40,
                        width: 40,
                        child: CircularProgressIndicator(),
                      )
                    : SizedBox(
                        height: 40,
                        child: Text(
                          "${balance.toString().substring(0, max(1, balance.toString().length - 18))} tokens",
                          // "${(balance / BigInt.from(10).pow(18)).toString().substring(0, max(1, balance.toString().length - 18 + 3))} tokens",
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 35),
                        ),
                      ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                  child: IconButton(
                    onPressed: getBalance,
                    icon: const Icon(Icons.refresh),
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                const Row(children: [
                  SizedBox(
                    width: 50,
                  ),
                  Text(
                    "Send To",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  )
                ]),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 45,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.white,
                      ),
                      child: TextField(
                        style:
                            const TextStyle(color: Colors.black, fontSize: 15),
                        controller: addressController,
                        decoration: InputDecoration(
                          fillColor: Colors.grey.shade100,
                          filled: true,
                          prefixIcon:
                              const Icon(Icons.account_balance_wallet_rounded),
                          contentPadding:
                              const EdgeInsets.fromLTRB(20, 15, 20, 15),
                          hintText: "Wallet Address",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                const Row(children: [
                  SizedBox(
                    width: 50,
                  ),
                  Text(
                    "Amount",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  )
                ]),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 45,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: TextField(
                        style:
                            const TextStyle(color: Colors.black, fontSize: 15),
                        controller: controller,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          fillColor: Colors.grey.shade100,
                          filled: true,
                          prefixIcon: const Icon(Icons.currency_bitcoin),
                          contentPadding:
                              const EdgeInsets.fromLTRB(20, 15, 20, 15),
                          hintText: "Amount",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 45,
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                      ),
                      child: IconButton(
                        onPressed: () => deposit(
                            int.parse(controller.text), addressController.text),
                        icon: const Icon(Icons.upload),
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(12.0),
                        backgroundColor: Colors.black,
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, 'add_key');
                      },
                      child: const Text('Update Wallet'),
                    ),
                    const SizedBox(
                      width: 30,
                    )
                  ],
                ),
                const Spacer(),
                const Spacer(),
              ],
            ),
          ),
        ));
  }
}
