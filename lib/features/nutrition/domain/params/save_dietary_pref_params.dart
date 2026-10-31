import 'package:equatable/equatable.dart';
import 'package:spotter/features/nutrition/domain/entities/dietary_preferences.dart';

class SaveDietaryPrefParams extends Equatable {
  final String uid;
  final DietaryPreferences prefs;

  const SaveDietaryPrefParams({required this.uid, required this.prefs});

  @override
  List<Object?> get props => [uid, prefs];
}
