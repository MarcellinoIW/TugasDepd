import 'package:flutter/material.dart';
import 'package:depd_mvvm/model/model.dart';
import 'package:depd_mvvm/data/response/api_response.dart';
import 'package:depd_mvvm/repository/Inter_repository.dart';

class interViewModel with ChangeNotifier {
  final _interRepo = Inter_repository();

  ApiResponse<List<InterCountry>> countryList = ApiResponse.notStarted();
  setCountryList(ApiResponse<List<InterCountry>> response) {
    countryList = response;
    notifyListeners();
  }

  Future getCountryList({String query = ""}) async {
    setCountryList(ApiResponse.loading());

    _interRepo
        .findInterDestination(query)
        .then((value) {
          setCountryList(ApiResponse.completed(value));
        })
        .onError((error, _) {
          setCountryList(ApiResponse.error(error.toString()));
        });
  }
  ApiResponse<List<InterCost>> interCostList = ApiResponse.notStarted();

  setInterCostList(ApiResponse<List<InterCost>> response) {
    interCostList = response;
    notifyListeners();
  }

  bool isLoading = false;
  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  // Hitung international cost
  Future checkInterCost({
    required String origin,
    required String destinationCountryId,
    required int weight,
    required String courier,
  }) async {
    setLoading(true);
    setInterCostList(ApiResponse.loading());

    _interRepo
        .countInterCost(
          origin: origin,
          destination: destinationCountryId,
          weight: weight,
          courier: courier,
        )
        .then((value) {
          setInterCostList(ApiResponse.completed(value));
          setLoading(false);
        })
        .onError((error, _) {
          setInterCostList(ApiResponse.error(error.toString()));
          setLoading(false);
        });
  }
}