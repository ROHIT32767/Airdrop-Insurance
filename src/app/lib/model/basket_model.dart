// ignore_for_file: unused_import

import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';

class BasketModel {
  String? uuid;
  String? name;
  int? cost;
  bool? automated;
  String? speculatorid;
  int? depositamount;
  String? waddress;
  List<dynamic>? users;
  String? description;
  // ignore: non_constant_identifier_Basket
  BasketModel(
      {this.uuid,
      this.name,
      this.cost,
      this.automated,
      this.speculatorid,
      this.depositamount,
      this.waddress,
      this.users,
      this.description
      });

  // receiving data from server
  factory BasketModel.fromMap(map) {
    return BasketModel(
      uuid: map["uuid"],
      name: map["name"],
      cost: map["cost"],
      automated: map["automated"],
      speculatorid: map["speculatorid"],
      depositamount: map["depositamount"],
      waddress: map["waddress"],
      users: map["users"],
      description: map["description"]
    );
  }

  // sending data to our server
  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'name': name,
      'cost': cost,
      'automated': automated,
      'speculatorid': speculatorid,
      'depositamount': depositamount,
      'waddress': waddress,
      'users': users,
      'description': description
    };
  }

}
