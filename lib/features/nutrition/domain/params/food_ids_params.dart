import 'package:equatable/equatable.dart';

class FoodIdsParams extends Equatable {
  final Set<String> foodIds;

  const FoodIdsParams(this.foodIds);

  @override
  List<Object?> get props => [foodIds];
}
