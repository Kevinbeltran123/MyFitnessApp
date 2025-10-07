import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_fitness_tracker/application/timers/rest_timer_service.dart';
import 'package:my_fitness_tracker/domain/timers/rest_timer_entities.dart';
import 'package:my_fitness_tracker/presentation/home/home_providers.dart';

final restTimerControllerProvider = StateNotifierProvider.autoDispose
    .family<RestTimerController, RestTimerSnapshot, RestTimerRequest>((
      Ref ref,
      RestTimerRequest request,
    ) {
      final manager = ref.watch(restTimerManagerProvider);
      return RestTimerController(manager: manager, initialRequest: request);
    });

class RestTimerController extends StateNotifier<RestTimerSnapshot> {
  RestTimerController({
    required RestTimerManager manager,
    required RestTimerRequest initialRequest,
  }) : _manager = manager,
       _request = initialRequest,
       super(
         RestTimerSnapshot(
           status: RestTimerStatus.idle,
           elapsed: Duration.zero,
           config: initialRequest.config,
         ),
       ) {
    _subscription = _manager
        .watchByKey(
          initialRequest.routineId,
          initialRequest.exerciseId,
          initialRequest.setIndex,
        )
        .listen((RestTimerSnapshot snapshot) {
          state = snapshot;
        });
  }

  final RestTimerManager _manager;
  RestTimerRequest _request;
  late final StreamSubscription<RestTimerSnapshot> _subscription;

  Future<void> start({required RestTimerConfig config}) async {
    _request = _request.copyWith(config: config);
    await _manager.start(_request);
  }

  Future<void> pause() => _manager.pause(_request);

  Future<void> resume() => _manager.resume(_request);

  Future<void> cancel() => _manager.cancel(_request);

  RestTimerConfig get config => _request.config;

  void updateConfig(RestTimerConfig config) {
    _request = _request.copyWith(config: config);
    if (state.status == RestTimerStatus.running ||
        state.status == RestTimerStatus.paused) {
      // Restart timer with new configuration.
      unawaited(start(config: config));
    } else {
      state = state.copyWith(config: config);
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
