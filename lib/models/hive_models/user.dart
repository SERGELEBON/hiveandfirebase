import 'dart:io';

import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User {
  @HiveField(0)
  final String firstName;

  @HiveField(1)
  final String lastName;

  @HiveField(2)
  final String dateOfBirth;

  @HiveField(3)
  final String idType;

  @HiveField(4)
  final String idNumber;

  @HiveField(5)
  final String password;

  @HiveField(6)
  File? profileImage; // Ajoutez cette ligne si elle n'existait pas.


  User({
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.idType,
    required this.idNumber,
    required this.password,
    this.profileImage, // Ajoutez cette ligne si elle n'existait pas.
  });
}
