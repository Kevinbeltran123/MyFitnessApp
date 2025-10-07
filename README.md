# My Fitness Tracker

My Fitness Tracker is a Flutter application that helps you explore workout routines and keep an eye on your daily activity. The UI is written in Spanish-first copy and showcases Material 3 design with dynamic surface colors, pull to refresh, and smooth navigation between a home dashboard and an exercise explorer fed by public APIs.

## Features
- Home dashboard that aggregates daily nutrition, exercise count, and activity streaks using `_HomeSummary` in `lib/screens/home_screen.dart`.
- Exercise explorer with debounced search, filter chips for target muscles and equipment, infinite scroll, and detail bottom sheets defined under `lib/screens` and `lib/widgets`.
- Resilient API layer built around `ApiClient` and `WorkoutService` with request timeouts, custom exceptions, and response caching helpers (`lib/services` and `lib/utils`).
- Strongly typed domain models for workouts and nutrition entries with JSON serialization support (`lib/models`).
- Reusable UI components (`SummaryCard`, `ExerciseGridItem`, `WorkoutDetailSheet`, etc.) to keep the interface consistent across screens.

## Project Structure
- `lib/main.dart` bootstraps the Flutter app and provides theming.
- `lib/screens/` contains feature screens such as the dashboard and exercise browser.
- `lib/models/` includes the domain entities and DTOs used throughout the app.
- `lib/services/` wraps remote APIs (ExerciseDB and TheMealDB) and exposes typed methods for fetching data.
- `lib/widgets/` holds composable UI pieces shared between screens.
- `lib/utils/` provides constants, date helpers, and exception types.

## External Services
Workout data is fetched from https://www.exercisedb.dev (see `AppConstants.workoutsBaseUrl`), while nutrition endpoints are prepared for TheMealDB (`AppConstants.nutritionBaseUrl`). Update the URLs or add API keys in `lib/utils/constants.dart` if you migrate to a different backend.

## Getting Started
1. Install Flutter (3.19 or newer recommended) and run `flutter doctor`.
2. Fetch dependencies with `flutter pub get`.
3. Launch a simulator or connect a device, then run `flutter run`.
4. Optional: run `flutter test` to execute widget and unit tests (create suites under `test/` as needed).

## Development Tips
- Customize theming and colors in `lib/main.dart`.
- Handle new API errors by extending the utilities in `lib/utils/app_exceptions.dart`.
- Use `dart format lib test` and `flutter analyze` before committing changes.

## Roadmap Ideas
- Complete the nutrition section that is currently stubbed on the home screen.
- Persist recent searches and favorite exercises locally.
- Add offline caching for the most accessed workout plans.
