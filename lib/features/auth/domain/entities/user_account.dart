import 'package:equatable/equatable.dart';

class UserAccount extends Equatable {
  String uid;
  String email;
  String displayName;
  DateTime createdAt;

  UserAccount({
    required this.createdAt,
    required this.displayName,
    required this.email,
    required this.uid,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [uid, email, displayName, createdAt];
}
