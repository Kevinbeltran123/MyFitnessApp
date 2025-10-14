import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_fitness_tracker/domain/metrics/metrics_entities.dart';
import 'package:my_fitness_tracker/presentation/metrics/metrics_controller.dart';

/// Controls the currently selected profile image path and persists it.
class ProfileImageController extends AutoDisposeNotifier<String?> {
  @override
  String? build() {
    // Keep the local state in sync with the stored profile.
    ref.listen<AsyncValue<MetabolicProfile?>>(metabolicProfileProvider, (
      previous,
      next,
    ) {
      next.whenData((profile) {
        final newPath = profile?.profileImagePath;
        if (state != newPath) {
          state = newPath;
        }
      });
    }, fireImmediately: true);

    final profileAsync = ref.read(metabolicProfileProvider);
    return profileAsync.maybeWhen(
      data: (profile) => profile?.profileImagePath,
      orElse: () => null,
    );
  }

  Future<void> updateImage({
    required MetabolicProfile? profile,
    required String? newPath,
  }) async {
    state = newPath;

    if (profile == null) {
      return;
    }

    final repository = await ref.read(metricsRepositoryProvider.future);
    final updatedProfile = profile.copyWith(
      updatedAt: DateTime.now(),
      profileImagePath: newPath,
      clearProfileImage: newPath == null,
    );
    await repository.saveMetabolicProfile(updatedProfile);
    ref.invalidate(metabolicProfileProvider);
  }
}

final profileImagePathProvider =
    AutoDisposeNotifierProvider<ProfileImageController, String?>(
      ProfileImageController.new,
    );
