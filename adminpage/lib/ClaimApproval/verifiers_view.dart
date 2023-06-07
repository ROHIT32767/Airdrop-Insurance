import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class VerifierListScreen extends StatefulWidget {
  final List<dynamic> verifyIds;
  const VerifierListScreen({Key? key, required this.verifyIds})
      : super(key: key);

  @override
  State<VerifierListScreen> createState() => _VerifierListScreen();
}

class _VerifierListScreen extends State<VerifierListScreen> {
  List<String> names = [];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      for (var id in widget.verifyIds) {
        var user =
            await FirebaseFirestore.instance.collection('users').doc(id).get();
        names.add(user.data()?['name']);
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    var color = 0xff924444;
    return Container(
      decoration: BoxDecoration(color: Color(color)),
      child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Color(color),
          ),
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 20,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Text("List of Verifiers",
                            style: GoogleFonts.openSans(
                                textStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600))),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    const SizedBox(
                      width: 20,
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: ListView.separated(
                          itemCount: names.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(7)),
                              ),
                              height: 50,
                              // color: Colors.amber,
                              child: Center(child: Text(names[index])),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) =>
                              const Divider(),
                        )),
                  ]),
                ],
              )
            ],
          )),
    );
  }
}
