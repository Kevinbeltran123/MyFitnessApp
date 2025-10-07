import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_fitness_tracker/domain/routines/routine_entities.dart';
import 'package:my_fitness_tracker/presentation/home/home_providers.dart';

final routineListControllerProvider = AutoDisposeAsyncNotifierProvider<
  RoutineListController,
  List<Routine>
>(RoutineListController.new);

class RoutineListController extends AutoDisposeAsyncNotifier<List<Routine>> {
  @override
  Future<List<Routine>> build() async {
    final repoAsync = ref.watch(routineRepositoryProvider);
    final repo = repoAsync.value;
    if (repo == null) {
      return const <Routine>[];
    }
    final stream = repo.watchAll(includeArchived: true);
    final sub = stream.listen((List<Routine> value) {
      state = AsyncData(List<Routine>.from(value));
    });
    ref.onDispose(sub.cancel);
    final initial = await stream.first;
    return initial;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final repoAsync = ref.read(routineRepositoryProvider);
    final repo = repoAsync.value;
    if (repo == null) {
      state = const AsyncData(<Routine>[]);
      return;
    }
    final data = await repo.watchAll(includeArchived: true).first;
    state = AsyncData(List<Routine>.from(data));
  }
}
