import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:arch/feature/home/domain/models/home_models.dart'; // Model
import 'package:arch/feature/home/domain/repository/home_repo.dart'; // Repository
class AuthController extends GetxController {
  final TextEditingController userIdController = TextEditingController();
  final Rx<String?> validationError = Rx<String?>(null);
  final RxBool isLoading = false.obs;
  final RxList<Chargerdetails> chargerDetails = <Chargerdetails>[].obs;

  final ChargerRepository _chargerRepository = ChargerRepository();

  String? validateUserId() {
    final userId = userIdController.text;
    if (userId.isEmpty) {
      return 'Please enter a user ID.';
    }
    if (int.tryParse(userId) == null) {
      return 'Please enter a valid numeric user ID.';
    }
    return null;
  }

  Future<void> handleGetChargerDetails() async {
    final error = validateUserId();
    if (error != null) {
      validationError.value = error;
      return;
    }

    validationError.value = null;
    isLoading.value = true;

    final userId = int.parse(userIdController.text);

    try {
      final details = await _chargerRepository.getChargerDetails(userId);
      chargerDetails.assignAll(details);
    } catch (e) {
      validationError.value = 'Error fetching details. Please try again.';
      print(e);
    } finally {
      isLoading.value = false;
    }
  }
}
