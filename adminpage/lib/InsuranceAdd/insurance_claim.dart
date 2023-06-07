import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as cloud_firebase;
import 'package:adminpage/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:file_picker/file_picker.dart';

class InsuranceAddScreen extends StatefulWidget {
  const InsuranceAddScreen({Key? key}) : super(key: key);

  @override
  State<InsuranceAddScreen> createState() => _InsuranceAddScreenState();
}

class _InsuranceAddScreenState extends State<InsuranceAddScreen> {
  // form key
  final _formKey = GlobalKey<FormState>();
  final descriptionController = TextEditingController();
  final payoutController = TextEditingController();
  final costController = TextEditingController();
  final verificationController = TextEditingController();
  final providerController = TextEditingController();
  final nameController = TextEditingController();

  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  bool? automatedValue = false;
  bool? adminValue = false;
  FilePickerResult? file;
  List<DropdownMenuItem<String>> menuItems = [];
  List<DropdownMenuItem<bool>> automatedItems = [
    const DropdownMenuItem(
      value: true,
      child: Text("Yes"),
    ),
    const DropdownMenuItem(
      value: false,
      child: Text("No"),
    ),
  ];
  @override
  void initState() {
    super.initState();
  }

  List<DropdownMenuItem<bool>> get dropdownItems {
    return automatedItems;
  }

  void submitPlan() async {
    if (providerController.text.isEmpty ||
        nameController.text.isEmpty ||
        costController.text.isEmpty ||
        verificationController.text.isEmpty ||
        payoutController.text.isEmpty ||
        descriptionController.text.isEmpty) {
      Fluttertoast.showToast(
          msg: "Please fill in all fields",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    var uuid = const Uuid();
    var id = uuid.v1();
    var option = {
      "name": nameController.text,
      "provider": providerController.text,
      "cost": int.parse(costController.text),
      "verify_required": int.parse(verificationController.text),
      "payout": int.parse(payoutController.text),
      "description": descriptionController.text,
      "automated": automatedValue,
      "admin_required": adminValue,
      "visible": true,
      "created_time": DateTime.now(),
      "uuid": id,
      "Option_bid":false, // A boolean variable that checks whether if the Insurance Option is bought by a speculator
      "Speculator_id":null // UserID of the Speculator who has bought the insurance option
    };
    await cloud_firebase.FirebaseFirestore.instance
        .collection("insurance options")
        .doc(id)
        .set(option);
    
    Fluttertoast.showToast(
      msg: "Plan added successfully",
    );
  }


  @override
  Widget build(BuildContext context) {
    //claim description field
    final descriptionField = TextFormField(
        style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
        keyboardType: TextInputType.multiline,
        controller: descriptionController,
        minLines: 10,
        maxLines: null,
        autofocus: false,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          fillColor: Colors.grey.shade100,
          filled: true,
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Description of insurance",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    final nameField = SizedBox(
        width: MediaQuery.of(context).size.width * 0.6,
        child: TextFormField(
          style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
          controller: nameController,
          minLines: 1,
          maxLines: 1,
          autofocus: false,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            fillColor: Colors.grey.shade100,
            filled: true,
            contentPadding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
            hintText: "Insurance option name",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ));

    final providerField = SizedBox(
        width: MediaQuery.of(context).size.width * 0.6,
        child: TextFormField(
          style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
          controller: providerController,
          minLines: 1,
          maxLines: 1,
          autofocus: false,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            fillColor: Colors.grey.shade100,
            filled: true,
            contentPadding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
            hintText: "Insurance provider name",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ));

    final costField = SizedBox(
        width: MediaQuery.of(context).size.width * 0.3,
        child: TextFormField(
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
          controller: costController,
          minLines: 1,
          maxLines: 1,
          autofocus: false,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            fillColor: Colors.grey.shade100,
            filled: true,
            contentPadding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ));

    final payoutField = SizedBox(
        width: MediaQuery.of(context).size.width * 0.3,
        child: TextFormField(
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
          controller: payoutController,
          minLines: 1,
          maxLines: 1,
          autofocus: false,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            fillColor: Colors.grey.shade100,
            filled: true,
            contentPadding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ));

    final verificationField = SizedBox(
        width: MediaQuery.of(context).size.width * 0.3,
        child: TextFormField(
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
          controller: verificationController,
          minLines: 1,
          maxLines: 1,
          autofocus: false,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            fillColor: Colors.grey.shade100,
            filled: true,
            contentPadding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ));
    const pad = SizedBox(
      height: 10,
    );
    var color = 0xff924444;
    return Container(
      decoration: BoxDecoration(
        color: Color(color),
      ),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Color(color),
        ),
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 35, top: 30),
                    child: const Text(
                      'Create an\nInsurance Option',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 29,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  pad,
                  Container(
                    margin: const EdgeInsets.only(left: 35, right: 35),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Insurance Option Name",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                            ),
                          ),
                          nameField,
                          pad,
                          const Text(
                            "Insurance Provider Name",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                            ),
                          ),
                          providerField,
                          pad,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Weekly token cost",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                ),
                              ),
                              costField,
                            ],
                          ),
                          pad,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Payout",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                ),
                              ),
                              payoutField,
                            ],
                          ),
                          pad,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Verifications Required",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                ),
                              ),
                              verificationField,
                            ],
                          ),
                          pad,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Admin Approval Required",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                ),
                              ),
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: Colors.white,
                                  ),
                                  child: DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                    dropdownColor: Colors.white,
                                    items: automatedItems,
                                    value: adminValue,
                                    onChanged: (bool? newValue) {
                                      setState(() {
                                        adminValue = newValue;
                                      });
                                    },
                                  ))),
                            ],
                          ),
                          pad,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Automated Payout",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                ),
                              ),
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: Colors.white,
                                  ),
                                  child: DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                    dropdownColor: Colors.white,
                                    items: automatedItems,
                                    value: automatedValue,
                                    onChanged: (bool? newValue) {
                                      setState(() {
                                        automatedValue = newValue;
                                      });
                                    },
                                  ))),
                            ],
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          const Text(
                            "Description",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                            ),
                          ),
                          descriptionField,
                          const SizedBox(
                            height: 40,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(16.0), backgroundColor: Colors.black,
                                  textStyle: const TextStyle(fontSize: 23),
                                ),
                                onPressed: () {
                                  submitPlan();
                                },
                                child: const Text('Create Plan'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
