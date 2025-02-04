import 'package:arch/feature/home/data/api.dart'; // API Calls
import 'package:arch/feature/home/domain/models/home_models.dart'; // Model




class ChargerRepository {
  final AuthAPICalls _api = AuthAPICalls();

  Future<List<Chargerdetails>> getChargerDetails(int userId) async {
    try {
      final responseJson = await _api.getChargerDetails(userId);

      if (responseJson != null && responseJson['data'] != null && responseJson['data'].isNotEmpty) {
        // Map all items in the "data" array
        return responseJson['data'].map<Chargerdetails>((json) => Chargerdetails.fromJson(json)).toList();
      } else {
        throw Exception("Empty response or invalid data");
      }
    } catch (e) {
      throw Exception("Error fetching charger details: $e");
    }
  }
}

