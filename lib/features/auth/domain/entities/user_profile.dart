class UserProfile {
  String uid;
  bool isMale;
  int age;
  double height;
  double weight;
  ExperienceLevel experienceLevel;
  int trainingDays;
  int weeklyTargetMin;
  UserProfile({
    required this.age,
    required this.experienceLevel,
    required this.height,
    required this.isMale,
    required this.trainingDays,
    required this.uid,
    required this.weeklyTargetMin,
    required this.weight,
  });
}

enum ExperienceLevel { beginner, intermediate, advanced }

enum ActivityLevel {
  sedentary(1.2), // little or no exercise
  lightlyActive(1.375), // light exercise 1-3 days/week
  moderatelyActive(1.55), // moderate exercise 3-5 days/week
  veryActive(1.725), // hard exercise 6-7 days/week
  extraActive(1.9); // very hard exercise + physical job

  const ActivityLevel(this.factor);
  final double factor;
}

enum Goal {
  loseFat(0.85), // ~15% deficit
  maintain(1.0),
  buildMuscle(1.10); // ~10% surplus

  const Goal(this.calorieMultiplier);
  final double calorieMultiplier;
}

enum EquipmentAccess { fullGym, homeMinimal, bodyweightOnly }
