# Fitness Tracker App - Development Guidelines

## Project Overview
This ## Coding Style & Naming Conventions
Follow the defaults from `package:flutter_lints`; keep indentation at two spaces and prefer trailing commas to trigger Flutter's formatter-friendly layouts. Format code with `dart format lib test` before committing. Name classes and enums with UpperCamelCase, files and directories with lower_snake_case, and constants with `kPrefixCamelCase`. Avoid `print`; rely on `debugPrint` or logging utilities instead.

### Fitness App Specific Conventions
- **Model Classes**: Use descriptive names like `FoodModel`, `NutritionData`, `ExerciseModel`
- **Service Classes**: Suffix with `Service` (e.g., `NutritionService`, `ExerciseService`)
- **Screen Classes**: Suffix with `Screen` (e.g., `FoodDetailScreen`, `ExerciseListScreen`)
- **Widget Classes**: Use descriptive names like `FoodCard`, `NutritionInfoWidget`
- **API Constants**: Group by service (e.g., `EdamamApi.baseUrl`, `ExerciseDbApi.endpoints`)

## Screen Flow & User Experience
Design for fitness enthusiasts with clear navigation and quick access to information:

### Navigation Structure
1. **Home Screen**: Central hub with quick access to both modules
2. **Food Module**: Search → List → Detail (with nutritional breakdown)
3. **Exercise Module**: Browse → Filter → Detail (with instructions)

### UI/UX Principles
- Use health-focused color scheme (greens, blues, clean whites)
- Implement intuitive search and filtering
- Show loading states for all API calls
- Provide offline capabilities where possible
- Ensure responsive design for various screen sizes a Flutter fitness tracking application that helps users monitor nutrition and exercise. The app consumes external APIs to provide comprehensive food calorie information and exercise databases.

### Core Features
- **Nutrition Module**: Display foods with detailed caloric and nutritional information
- **Exercise Module**: Browse and filter exercises by muscle group and type
- **API Integration**: Real-time data from Edamam Nutrition API and ExerciseDB API

## Project Structure & Module Organization
This Flutter app follows a modular architecture with clear separation of concerns:

```
lib/
├── main.dart                 # App entry point and routing
├── models/                   # Data models for API responses
│   ├── food_model.dart       # Food and nutrition data structures
│   ├── nutrition_model.dart  # Detailed nutritional information
│   └── exercise_model.dart   # Exercise data structures
├── services/                 # API service layer
│   ├── nutrition_service.dart # Edamam API integration
│   └── exercise_service.dart  # ExerciseDB API integration
├── screens/                  # UI screens/pages
│   ├── home_screen.dart      # Main navigation hub
│   ├── food_screen.dart      # Food list and search
│   ├── food_detail_screen.dart # Nutritional details
│   ├── exercise_screen.dart   # Exercise catalog
│   └── exercise_detail_screen.dart # Exercise instructions
├── widgets/                  # Reusable UI components
│   ├── food_card.dart        # Food item display card
│   ├── exercise_card.dart    # Exercise item display card
│   └── nutrition_info.dart   # Nutrition facts widget
└── utils/                    # Constants and utilities
    ├── constants.dart        # App-wide constants
    └── api_constants.dart    # API endpoints and keys
```

Platform-specific configuration stays in the generated `android/`, `ios/`, `linux/`, `macos/`, `web/`, and `windows/` directories. Mirror all lib/ folders with matching `*_test.dart` files inside `test/`.

## API Integration Guidelines

### External APIs Used
1. **Edamam Nutrition Analysis API**
   - Base URL: `https://api.edamam.com/api/nutrition-data`
   - Authentication: API Key + App ID
   - Rate Limit: 5,000 requests/month (free tier)
   - Purpose: Food nutritional information and calorie data

2. **ExerciseDB API (RapidAPI)**
   - Base URL: `https://exercisedb.p.rapidapi.com`
   - Authentication: RapidAPI Key
   - Rate Limit: 100 requests/day (free tier)
   - Purpose: Exercise database with muscle group categorization

### API Best Practices
- Implement robust error handling for network failures and rate limits
- Use caching to minimize API calls and improve performance
- Show loading states during API requests
- Handle API key security (use environment variables or secure storage)
- Implement retry logic for failed requests

## Build, Test, and Development Commands
Run `flutter pub get` after dependency updates to refresh the lockfile. Use `flutter run -d chrome` for quick web previews, or omit the device flag to let Flutter pick a connected target. `flutter build apk --release` produces a packed Android artifact. Guard regressions with `flutter analyze` and `flutter test`; add `--coverage` when you need LCOV output.

### Required Dependencies
Essential packages for this fitness app:
- `http` or `dio`: HTTP client for API requests
- `provider` or `riverpod`: State management
- `cached_network_image`: Optimized image loading and caching
- `flutter_spinkit`: Loading indicators
- `google_fonts`: Custom typography

## Coding Style & Naming Conventions
Follow the defaults from `package:flutter_lints`; keep indentation at two spaces and prefer trailing commas to trigger Flutter’s formatter-friendly layouts. Format code with `dart format lib test` before committing. Name classes and enums with UpperCamelCase, files and directories with lower_snake_case, and constants with `kPrefixCamelCase`. Avoid `print`; rely on `debugPrint` or logging utilities instead.

## Testing Guidelines
Write widget and unit tests under `test/`, mirroring the folder structure from `lib/`. Test files should end with `_test.dart` and organize expectations inside `group` blocks for readability. Execute `flutter test` locally before pushing; include golden tests only when assets are checked into version control. Maintain meaningful coverage on new features, aiming to exercise key state transitions and async branches.

### Fitness App Testing Priorities
- **API Service Tests**: Mock HTTP responses for both Edamam and ExerciseDB APIs
- **Model Tests**: Validate JSON parsing for food, nutrition, and exercise data
- **Widget Tests**: Test food cards, exercise cards, and navigation flows
- **Integration Tests**: End-to-end user journeys (search food → view details)
- **Error Handling Tests**: Network failures, API rate limits, invalid responses

### Mock Data Strategy
Create realistic mock data for:
- Common foods with nutritional information
- Popular exercises across different muscle groups
- API error responses for robust error handling testing

## Development Phases & Priorities

### Phase 1: Core Foundation
1. Set up project structure and dependencies
2. Implement basic models for Food and Exercise data
3. Create API service classes with error handling
4. Build basic UI screens with navigation

### Phase 2: API Integration
1. Integrate Edamam Nutrition API for food data
2. Integrate ExerciseDB API for exercise information
3. Implement caching strategy for API responses
4. Add loading states and error handling UI

### Phase 3: Enhanced Features
1. Advanced search and filtering capabilities
2. Detailed nutritional breakdowns and visualizations
3. Exercise categorization and filtering
4. Performance optimizations and offline support

### Phase 4: Polish & Testing
1. Comprehensive testing suite
2. UI/UX refinements
3. Performance optimizations
4. Accessibility improvements

## Commit & Pull Request Guidelines
Use Conventional Commits format:
- `feat(nutrition):` for food/nutrition module features
- `feat(exercise):` for exercise module features
- `fix(api):` for API integration fixes
- `ui:` for user interface improvements
- `test:` for testing additions

Include screenshots for UI changes and describe API integration impacts. Call out any configuration steps (API keys, environment setup) reviewers must perform.

## Performance & Security Considerations
- **API Keys**: Store securely, never commit to version control
- **Rate Limiting**: Implement client-side rate limiting to respect API quotas
- **Caching**: Cache API responses to reduce network calls and improve UX
- **Image Loading**: Use lazy loading and caching for food/exercise images
- **Memory Management**: Dispose of controllers and streams properly
- **Error Resilience**: Graceful degradation when APIs are unavailable
