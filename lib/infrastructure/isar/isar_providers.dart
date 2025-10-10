import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:my_fitness_tracker/infrastructure/metrics/metrics_model.dart';
import 'package:my_fitness_tracker/infrastructure/routines/routine_model.dart';
import 'package:path_provider/path_provider.dart';

final isarProvider = FutureProvider<Isar>((Ref ref) async {
  if (Isar.instanceNames.isNotEmpty) {
    return Future.value(Isar.getInstance());
  }
  final dir = await getApplicationDocumentsDirectory();
  return Isar.open(
    <CollectionSchema>[
      RoutineModelSchema,
      RoutineSessionModelSchema,
      BodyMetricModelSchema,
      MetabolicProfileModelSchema,
    ],
    directory: dir.path,
    inspector: false,
  );
});
