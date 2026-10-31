import 'package:equatable/equatable.dart';

class PrefsIdParams extends Equatable {
  final String uid;
  final String prefsId;

  const PrefsIdParams({required this.uid,required this.prefsId});
  @override
  List<Object?> get props => [uid,prefsId];
}
