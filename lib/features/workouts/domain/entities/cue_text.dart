import 'package:equatable/equatable.dart';

class CueText extends Equatable {
  final String ar;

  final String en;

  const CueText({required this.ar, required this.en});

  factory CueText.fromJson(Map<String, dynamic> json) => CueText(
        ar: json['ar'] as String? ?? '',
        en: json['en'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {'ar': ar, 'en': en};

  @override
  List<Object?> get props => [ar, en];
}
