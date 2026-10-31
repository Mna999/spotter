import 'package:equatable/equatable.dart';

class FoodIdParams extends Equatable {
  final String foodId;

  const FoodIdParams({required this.foodId});

  @override
  List<Object?> get props => [foodId];
}
