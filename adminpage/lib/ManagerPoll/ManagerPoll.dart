import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManagerPoll extends StatefulWidget {
  const ManagerPoll({Key? key}) : super(key: key);
  @override
  _ManagerPollState createState() => _ManagerPollState();
}

class _ManagerPollState extends State<ManagerPoll> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Requests'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.collection('Requests').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                String userID = snapshot.data!.docs[index].get('userid');

                return StreamBuilder<DocumentSnapshot>(
                  stream: firestore.collection('users').doc(userID).snapshots(),
                  builder: (context, userSnapshot) {
                    if (!userSnapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      String userName = userSnapshot.data!.get('name');
                      return ListTile(
                        title: Text(userName),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              child: Text('ACCEPT'),
                              onPressed: () {
                                // update user role to manager
                                firestore.collection('users').doc(userID).update({'role': 'manager'});
                                // delete request document
                                firestore.collection('Requests').doc(snapshot.data!.docs[index].id).delete();
                              },
                            ),
                            SizedBox(width: 10),
                            ElevatedButton(
                              child: Text('REJECT'),
                              onPressed: () {
                                // delete request document
                                firestore.collection('Requests').doc(snapshot.data!.docs[index].id).delete();
                              },
                            ),
                          ],
                        ),
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
