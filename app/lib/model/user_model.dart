import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? uid;
  String? email;
  String? name;
  String? role;
  String? metamaskWAddress;
  String? metamaskPK;
  bool? kycVerified;
  bool? coinbaseVerified;
  // ignore: non_constant_identifier_names
  String? coinbaseId;
  GeoPoint? loc;
  List<dynamic>? options;
  List<dynamic>? baskets;

  UserModel(
      {this.uid,
      this.email,
      this.name,
      this.role,
      this.metamaskWAddress,
      this.metamaskPK,
      this.kycVerified,
      this.coinbaseVerified,
      this.coinbaseId,
      this.loc,
      this.options,
      this.baskets});

  // receiving data from server
  factory UserModel.fromMap(map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      name: map['name'],
      role: map['role'],
      metamaskWAddress: map['metamaskWAddress'],
      metamaskPK: map['metamaskPK'],
      kycVerified: map['kycVerified'],
      coinbaseVerified: map['coinbaseVerified'],
      coinbaseId: map['coinbaseId'],
      loc: map['loc'],
      options: map['options'],
      baskets: map['baskets']
    );
  }

  // sending data to our server
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
      'metamaskWAddress': metamaskWAddress,
      'metamaskPK': metamaskPK,
      'kycVerified': kycVerified,
      'coinbaseVerified': coinbaseVerified,
      'coinbaseId': coinbaseId,
      'loc': loc,
      'options': options,
      'baskets': baskets
    };
  }

  bool? isCoinbaseVerified() {
    return coinbaseVerified;
  }
}
