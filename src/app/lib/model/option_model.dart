// ignore_for_file: unused_import

import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';

class OptionModel {
  String? uuid;
  String? name;
  String? provider;
  String? description;
  int? cost;
  int? payout;
  Timestamp? createdTime;
  int? verifyRequired;
  bool? adminRequired;
  bool? automated;
  bool? visible;
  // ignore: non_constant_identifier_names

  OptionModel(
      {this.uuid,
      this.name,
      this.provider,
      this.description,
      this.cost,
      this.payout,
      this.createdTime,
      this.verifyRequired,
      this.adminRequired,
      this.automated,
      this.visible});

  // receiving data from server
  factory OptionModel.fromMap(map) {
    return OptionModel(
      uuid: map["uuid"],
      name: map["name"],
      provider: map["provider"],
      description: map["description"],
      cost: map["cost"],
      payout: map["payout"],
      createdTime: map["createdTime"],
      verifyRequired: map["verifyRequired"],
      adminRequired: map["adminRequired"],
      automated: map["automated"],
      visible: map["visible"],
    );
  }

  // sending data to our server
  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'name': name,
      'provider': provider,
      'description': description,
      'cost': cost,
      'payout': payout,
      'createdTime': createdTime,
      'verifyRequired': verifyRequired,
      'adminRequired': adminRequired,
      'automated': automated,
      'visible': visible,
    };
  }

  bool? isVisible() {
    return visible;
  }
}
