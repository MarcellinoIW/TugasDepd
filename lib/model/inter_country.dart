// import 'package:equatable/equatable.dart';
part of 'model.dart';

class InterCountry extends Equatable {
  final String? countryId;
  final String? countryName;

  const InterCountry({this.countryId, this.countryName});

  factory InterCountry.fromJson(Map<String, dynamic> json) => InterCountry(
    countryId: json['country_id'] as String?,
    countryName: json['country_name'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'country_id': countryId,
    'country_name': countryName,
  };

  @override
  List<Object?> get props => [countryId, countryName];
}
