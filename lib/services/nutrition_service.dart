import '../models/nutrition_entry.dart';
import '../utils/constants.dart';
import 'api_client.dart';

class NutritionService {
  NutritionService(this._client);

  final ApiClient _client;

  Future<List<NutritionEntry>> fetchDailyNutrition({DateTime? date}) async {
    final uri = Uri.parse(AppConstants.nutritionBaseUrl).replace(
      queryParameters: <String, String>{
        if (date != null) 'date': date.toIso8601String(),
      },
    );
    final json = await _client.get(uri);
    final items = json['items'] as List<dynamic>? ?? <dynamic>[];
    return items
        .map(
          (dynamic item) =>
              NutritionEntry.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }
}
