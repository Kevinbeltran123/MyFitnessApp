# My Fitness Tracker - Documentación Técnica del Proyecto

## Descripción General

Aplicación móvil de fitness tracking desarrollada en Flutter que implementa Clean Architecture con persistencia local usando Isar Database. La aplicación permite gestionar rutinas de entrenamiento, ejecutar sesiones en vivo con timers, y trackear métricas corporales con análisis estadístico.

---

## Arquitectura del Proyecto

El proyecto sigue **Clean Architecture** con separación clara de responsabilidades en 4 capas principales:

```
lib/
├── domain/           # Entities & Repository Interfaces
├── application/      # Use Cases & Business Logic
├── infrastructure/   # Data Layer & External Dependencies
├── presentation/     # UI Layer (Screens, Controllers, Widgets)
├── services/         # External API Services
├── models/           # Data Transfer Objects
├── widgets/          # Reusable UI Components
├── utils/            # Helpers & Constants
└── shared/           # Common Resources (Theme, Utilities)
```

---

## Estructura Detallada por Carpetas

### 1. `/domain` - Capa de Dominio

Define las entidades de negocio y contratos de repositorios (interfaces). No tiene dependencias de frameworks externos.

#### `/domain/routines`
- **`routine_entities.dart`**: Define las entidades core del sistema de rutinas
  - `Routine`: Entidad principal con id, name, description, focus, exercises, daysOfWeek
  - `RoutineExercise`: Ejercicio dentro de una rutina con sets y configuración
  - `RoutineSet`: Configuración de una serie (repetitions, targetWeight, restInterval)
  - `RoutineFocus`: Enum para categorizar rutinas (fullBody, upperBody, lowerBody, push, pull, core, mobility, custom)
  - `RoutineDay`: Enum de días de la semana
  - `RoutineSession`: Sesión de entrenamiento completada
  - `SetLog`: Registro de una serie ejecutada (repetitions, weight, restTaken)

- **`routine_repository.dart`**: Interface del repositorio
  - Métodos abstractos: `create()`, `getById()`, `getAll()`, `update()`, `delete()`, `archive()`, `restore()`, `duplicate()`
  - Define el contrato que debe implementar la capa de infraestructura

#### `/domain/metrics`
- **`metrics_entities.dart`**: Entidades para tracking corporal
  - `BodyMetric`: Medición corporal (weightKg, bodyFatPercentage, muscleMassKg, recordedAt)
  - `MetabolicProfile`: Perfil metabólico del usuario (heightCm, targetWeightKg, age, gender)
  - `MetricType`: Enum para tipos de métricas (weight, bodyFat, muscleMass)
  - `MetricTrend`: Enum para tendencias (up, down, stable)
  - `MetricRangePreset`: Filtros temporales (week, month, threeMonths, sixMonths, all)

#### `/domain/timers`
- **`rest_timer_entities.dart`**: Entidades para temporizadores
  - `RestTimerConfig`: Configuración del timer (target duration, notifications, vibration)
  - `RestTimerRequest`: Request para iniciar timer (routineId, exerciseId, setIndex, config)
  - `RestTimerSnapshot`: Estado actual del timer
  - `RestTimerStatus`: Enum (idle, running, paused, completed, cancelled)

---

### 2. `/application` - Capa de Aplicación

Contiene los use cases y servicios que orquestan la lógica de negocio.

#### `/application/routines`
- **`routine_service.dart`**: Service principal para gestión de rutinas
  - Provider: `routineServiceProvider` (AsyncNotifier que retorna el service)
  - Operaciones CRUD completas sobre rutinas
  - Lógica de archivado/restauración
  - Duplicación de rutinas con sufijo "(copia)"
  - Maneja excepciones y validaciones

- **`create_routine.dart`**: Use case específico para creación
  - Validaciones de negocio antes de crear
  - Generación de IDs únicos
  - Inicialización de timestamps (createdAt, updatedAt)

#### `/application/timers`
- **`rest_timer_service.dart`**: Servicio de temporizador de descanso
  - Manejo de estado del timer con Ticker
  - Callbacks para notificaciones y vibraciones
  - Persistencia del estado del timer
  - Pausar/Reanudar/Cancelar funcionalidad

---

### 3. `/infrastructure` - Capa de Infraestructura

Implementaciones concretas de persistencia y acceso a datos.

#### `/infrastructure/isar`
- **`isar_providers.dart`**: Configuración de Isar Database
  - Provider: `isarProvider` - Singleton de la instancia Isar
  - Schemas registrados: RoutineModel, MetricsModel
  - Path de la base de datos en el dispositivo

#### `/infrastructure/routines`
- **`routine_model.dart`**: Modelo de datos para Isar (con anotaciones @collection)
  - `RoutineModel`: Modelo mapeado a tabla Isar
  - `RoutineExerciseModel`: Embedded object en Isar
  - `RoutineSetModel`: Embedded object para sets
  - Conversión de/hacia entidades de dominio con métodos `toDomain()` y `fromDomain()`

- **`routine_model.g.dart`**: Código generado por Isar (build_runner)
  - Schema definitions
  - Serializers/Deserializers

- **`routine_repository_isar.dart`**: Implementación del repository usando Isar
  - Provider: `routineRepositoryProvider`
  - Queries con `.filter()`, `.findAll()`, `.get()`
  - Transactions para escrituras
  - Mapeo entre modelos y entidades

#### `/infrastructure/metrics`
- **`metrics_model.dart`**: Modelo de métricas corporales para Isar
  - `BodyMetricModel`: @collection con índices en recordedAt
  - `MetabolicProfileModel`: @collection (singleton)

- **`metrics_model.g.dart`**: Código generado

- **`metrics_repository_isar.dart`**: Repository implementation
  - CRUD operations para métricas
  - Queries con filtros de fecha
  - Ordenamiento por recordedAt

- **`in_memory_metrics_repository.dart`**: Mock repository para testing
  - Implementación en memoria sin persistencia
  - Útil para pruebas unitarias

#### `/infrastructure/sessions`
- **`session_repository_isar.dart`**: Persistencia de sesiones de entrenamiento
  - Guarda RoutineSession completas
  - Queries por rutina o rango de fechas
  - Cálculo de estadísticas (último uso, total de sesiones)

---

### 4. `/presentation` - Capa de Presentación

UI Layer con screens, controllers (state management), y widgets específicos.

#### `/presentation/navigation`
- **`main_navigation.dart`**: Bottom Navigation Bar principal
  - 5 tabs: Home, Workouts, Routines, Exercises, Profile
  - Usa `IndexedStack` para mantener estado de cada tab
  - NavigationBar con Material 3

#### `/presentation/home`
- **`home_providers.dart`**: Providers específicos del home
  - Provider para obtener workout service
  - Provider para summary data

#### `/presentation/routines`

**Screens:**
- **`routine_list_screen.dart`**: Lista de rutinas del usuario
  - State: `ConsumerStatefulWidget`
  - Features:
    - Search bar con filtrado en tiempo real
    - Chips para filtrar por RoutineFocus
    - Separación de rutinas activas vs archivadas
    - Actions: Archive, Restore, Duplicate, Delete
    - Refresh indicator
  - UI States: Loading, Error, Empty, Success
  - Navegación a RoutineDetailScreen y RoutineBuilderScreen

- **`routine_builder_screen.dart`**: Crear/editar rutinas
  - Form con validaciones
  - ExercisePicker para agregar ejercicios
  - SetEditor para configurar series
  - DayOfWeek selector (multi-select chips)
  - FocusSelector dropdown

- **`routine_detail_screen.dart`**: Ver detalles de una rutina
  - Display de información completa
  - Botón para iniciar sesión de entrenamiento
  - Edit/Delete actions
  - Historial de sesiones de esta rutina

- **`routine_session_screen.dart`**: Modo entrenamiento en vivo
  - **Estado:**
    - Session timer con `Timer.periodic`
    - Progress tracker (series completadas/totales)
    - Current exercise & set indicator
  - **Features:**
    - Log set modal (bottom sheet con form)
    - Rest timer integrado con provider
    - Notas de sesión (TextField)
    - Confirmación de salida si hay cambios sin guardar
    - Completion modal con estadísticas
  - **Integración:**
    - `RoutineSessionController` para state management
    - `RestTimerController` para cronómetro
    - Auto-save al finalizar sesión

**Controllers:**
- **`routine_list_controller.dart`**: StateNotifier para lista de rutinas
  - Provider: `routineListControllerProvider`
  - Methods: `refresh()`, `delete()`, `archive()`, `restore()`
  - Maneja AsyncValue<List<Routine>>

- **`routine_session_controller.dart`**: Controller para sesión activa
  - Provider: `routineSessionControllerProvider(routineId)`
  - State: `RoutineSessionState`
    - routine, startedAt, completedSets, totalSets
    - logs: Map<exerciseId, List<SetLog>>
    - currentExercise, currentSet
    - notes, isSaving, isPersisted
  - Methods:
    - `recordSet(repetitions, weight, restTaken)`
    - `finishSession()` -> persiste en repository
    - `updateNotes()`
  - Lógica para avanzar al siguiente set/ejercicio

- **`rest_timer_controller.dart`**: StateNotifier para timer
  - Provider: `restTimerControllerProvider(request)`
  - State: `RestTimerSnapshot`
  - Methods: `start()`, `pause()`, `resume()`, `cancel()`
  - Usa Ticker para actualizar cada segundo

**Widgets:**
- **`routine_exercise_picker.dart`**: Widget para seleccionar ejercicios
  - API integration para fetch exercises
  - Search functionality
  - Multi-select capability

- **`routine_set_editor.dart`**: Editor de series
  - Add/Remove sets
  - Configure reps, weight, rest per set
  - Reorderable list

#### `/presentation/metrics`

**Screens:**
- **`metrics_dashboard_screen.dart`**: Dashboard principal de métricas
  - Gráficas con charts library
  - Range selector (week/month/3m/6m/all)
  - Latest measurement card con gradiente
  - BMI calculator widget
  - Comparison cards (primera vs última medición)
  - Trend indicators con análisis estadístico
  - History list (últimas 10 mediciones)
  - RefreshIndicator para actualizar datos

- **`add_measurement_screen.dart`**: Form para agregar medición
  - TextFormFields para weight, bodyFat, muscleMass
  - DatePicker para recordedAt
  - Validations
  - Auto-dismiss on save

**Controller:**
- **`metrics_controller.dart`**: State management para métricas
  - Providers:
    - `bodyMetricsProvider`: Fetch todas las métricas
    - `latestBodyMetricProvider`: Última medición
    - `filteredMetricsProvider`: Filtradas por range preset
    - `metabolicProfileProvider`: Perfil del usuario
    - `selectedMetricRangeProvider`: StateProvider para filtro activo
  - Cálculos:
    - BMI calculation
    - Trend analysis (slope calculation)
    - Average, delta, percent change

**Widgets:**
- **`metric_chart.dart`**: Line chart para visualizar progreso
  - Acepta MetricType (weight/bodyFat/muscleMass)
  - Goal line opcional
  - Zoom & pan gestures
  - Custom tooltips

- **`trend_indicator.dart`**: Muestra tendencia con ícono y color
  - TrendInsights model con slope, projected value
  - Arrow indicators (up/down/stable)
  - Color-coded (green/red/gray)

- **`comparison_card.dart`**: Comparación inicio vs final
  - ComparisonMetricData model
  - Delta con signo
  - Percentage change
  - Average value

- **`bmi_calculator.dart`**: Calculadora de IMC
  - Formula: weight / (height^2)
  - BMI ranges con colores (underweight/normal/overweight/obese)
  - Interpretación visual

- **`metric_range_selector.dart`**: Chips para seleccionar rango temporal
  - ChoiceChips con presets
  - Actualiza `selectedMetricRangeProvider`

**Models:**
- **`metric_insights.dart`**: Modelos para análisis
  - `TrendInsights`: slope, latestValue, projectedValue, trend
  - `ComparisonMetricData`: label, unit, delta, percentChange, average, trend

#### `/presentation/workouts`
- **`workout_history_screen.dart`**: Lista de sesiones completadas
  - Query al session repository
  - Grouped by date
  - Cards con resumen (duración, volumen total)
  - Navegación a detalle de sesión

- **`workout_history_controller.dart`**: StateNotifier
  - Provider: `workoutHistoryProvider`
  - Fetch sessions con paginación

**Widgets:**
- **`workout_session_card.dart`**: Card para mostrar sesión
  - Routine name
  - Date & duration
  - Total volume (weight × reps)
  - Sets completed

#### `/presentation/profile`
- **`profile_screen.dart`**: Pantalla de perfil
  - User info
  - Navegación a settings y statistics
  - Metabolic profile editor

- **`settings_screen.dart`**: Configuración de la app
  - Preferences (unidades, notificaciones)
  - Data export/import
  - About section

- **`statistics_screen.dart`**: Estadísticas generales
  - Total workouts
  - Total volume lifted
  - Favorite exercises
  - Workout frequency chart

---

### 5. `/services` - External Services

#### `api_client.dart`
- HTTP client configurado con Dio
- Base URL configuration
- Interceptors para logging y error handling
- Token management (si aplica)
- Timeout configuration

#### `workout_service.dart`
- Service para fetch exercises desde API externa
- Provider: `workoutServiceProvider`
- Methods:
  - `fetchExercises(limit, offset, muscle, difficulty)`
  - Response parsing a `WorkoutPlan` models
- Error handling con try-catch
- Caching opcional

---

### 6. `/models` - Data Transfer Objects

#### `workout_plan.dart`
- `WorkoutPlan`: DTO para ejercicios de API
  - name, type, muscle, equipment, difficulty, instructions
- Parsing desde JSON
- Factory constructors `fromJson()`
- `toJson()` methods

---

### 7. `/widgets` - Reusable Components

Widgets reutilizables en toda la app:

#### `loading_indicator.dart`
- `LoadingIndicator`: Spinner centrado con mensaje opcional

#### `summary_card.dart`
- `SummaryCard`: Card estilizada para mostrar stats
- Props: title, value, icon, color

#### `exercise_search_bar.dart`
- `ExerciseSearchBar`: Search field con debounce
- onChanged callback
- Clear button

#### `exercise_grid_item.dart`
- `ExerciseGridItem`: Card para mostrar ejercicio en grid
- Image, name, muscle group
- onTap handler

#### `filter_chips_row.dart`
- `FilterChipsRow`: Horizontal scroll de chips
- Multi-select o single-select
- Custom styling

#### `workout_detail_sheet.dart`
- `WorkoutDetailSheet`: Bottom sheet con detalles de ejercicio
- Instructions, equipment, difficulty
- Add to routine button

---

### 8. `/shared` - Common Resources

#### `/shared/theme`
- **`app_theme.dart`**: Theme configuration
  - `AppTheme.lightTheme`: ThemeData con Material 3
  - Color scheme, typography, component themes
  - Custom elevations y border radius

- **`app_colors.dart`**: Color palette constants
  - Primary, secondary, accent colors
  - Semantic colors (success, error, warning)
  - Gradients definitions
  - Shadow colors

#### `/shared/widgets`
- **`state_widgets.dart`**: Widgets para estados comunes
  - `LoadingStateWidget`: Spinner con mensaje
  - `ErrorStateWidget`: Error display con retry button
  - `EmptyStateWidget`: Empty state con icon, title, message, action button

#### `/shared/utils`
- **`app_snackbar.dart`**: Helper para mostrar snackbars
  - `AppSnackBar.showSuccess(context, message)`
  - `AppSnackBar.showError(context, message)`
  - `AppSnackBar.showInfo(context, message)`
  - Custom styling consistente

---

### 9. `/utils` - Utilities

#### `constants.dart`
- App-wide constants
- API endpoints
- Durations, timeouts
- Default values

#### `app_exceptions.dart`
- Custom exception classes
  - `ApiException`
  - `CacheException`
  - `ValidationException`
- Error codes y messages

#### `date_formatter.dart`
- Date formatting helpers
  - `formatDate(DateTime)`: "DD MMM YYYY"
  - `formatTime(DateTime)`: "HH:MM"
  - `formatRelative(DateTime)`: "hace 2 días"
  - Locale: ES

---

## State Management - Riverpod

### Providers utilizados:

**AsyncNotifierProvider:**
- `routineServiceProvider`
- `routineListControllerProvider`
- `workoutHistoryProvider`
- `bodyMetricsProvider`

**StateNotifierProvider:**
- `routineSessionControllerProvider(routineId)`
- `restTimerControllerProvider(request)`

**FutureProvider:**
- `latestBodyMetricProvider`
- `filteredMetricsProvider`
- `metabolicProfileProvider`

**StateProvider:**
- `selectedMetricRangeProvider`

**Provider:**
- `isarProvider`
- `routineRepositoryProvider`
- `workoutServiceProvider`

### Patrón de uso:
```dart
// En controllers
class RoutineListController extends AsyncNotifier<List<Routine>> {
  @override
  Future<List<Routine>> build() async {
    final repository = await ref.read(routineRepositoryProvider.future);
    return repository.getAll();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = await ref.read(routineRepositoryProvider.future);
      return repository.getAll();
    });
  }
}

// En UI
final routinesAsync = ref.watch(routineListControllerProvider);
routinesAsync.when(
  data: (routines) => ListView(...),
  loading: () => LoadingStateWidget(),
  error: (error, stack) => ErrorStateWidget(...),
);
```

---

## Persistencia - Isar Database

### Schema Models:

**RoutineModel:**
```dart
@collection
class RoutineModel {
  Id id = Isar.autoIncrement;
  late String name;
  late String description;
  @enumerated
  late RoutineFocus focus;
  late List<RoutineExerciseModel> exercises;
  late List<int> daysOfWeek; // stored as ints
  late DateTime createdAt;
  late DateTime updatedAt;
  late bool isArchived;
}
```

**Queries:**
- `.filter().isArchivedEqualTo(false).findAll()`
- `.filter().idEqualTo(id).findFirst()`
- Transactions: `isar.writeTxn(() async { ... })`

### Build Runner:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Flujo de Datos (Data Flow)

### Ejemplo: Crear una rutina

1. **UI Layer** (`routine_builder_screen.dart`):
   - Usuario llena el form y presiona "Guardar"
   - Valida inputs
   - Crea objeto `Routine` (entidad de dominio)

2. **Application Layer** (`routine_service.dart`):
   - Llama a `routineService.create(routine)`
   - Valida reglas de negocio
   - Genera ID y timestamps

3. **Infrastructure Layer** (`routine_repository_isar.dart`):
   - Convierte `Routine` a `RoutineModel`
   - Ejecuta `isar.writeTxn(() => collection.put(model))`
   - Retorna `Routine` guardada

4. **State Management** (Riverpod):
   - Provider notifica cambio
   - UI se actualiza automáticamente

### Ejemplo: Sesión de entrenamiento

1. Usuario inicia sesión desde `routine_detail_screen`
2. Navega a `routine_session_screen`
3. `RoutineSessionController` inicializa estado
4. Usuario registra cada set:
   - `_logCurrentSet()` muestra modal
   - `controller.recordSet()` actualiza estado
   - `RestTimerController.start()` inicia cronómetro
5. Al finalizar:
   - `controller.finishSession()` persiste en repository
   - Navega de vuelta con resultado
   - `workout_history_screen` se actualiza

---

## Testing Strategy

### Unit Tests:
- Entities validation
- Repository implementations
- Service logic
- Utilities & helpers

### Widget Tests:
- Individual widgets (buttons, cards, etc.)
- State widgets (loading, error, empty)

### Integration Tests:
- Complete flows (create routine -> start session -> finish)
- Database operations
- State management

---

## Tecnologías y Dependencias

### Core:
- **Flutter SDK**: 3.x
- **Dart**: 3.x

### State Management:
- **flutter_riverpod**: ^2.4.0
- **riverpod_annotation**: ^2.3.0

### Database:
- **isar**: ^3.1.0
- **isar_flutter_libs**: ^3.1.0

### HTTP:
- **dio**: ^5.3.0

### Code Generation:
- **build_runner**: ^2.4.0
- **riverpod_generator**: ^2.3.0
- **isar_generator**: ^3.1.0

### UI:
- **flutter_charts** o similar para gráficas
- Material 3 components

---

## Build & Run

### Development:
```bash
flutter pub get
flutter pub run build_runner build
flutter run
```

### Generate code:
```bash
flutter pub run build_runner watch
```

### Build APK:
```bash
flutter build apk --release
```

### Build iOS:
```bash
flutter build ios --release
```

---

## Conclusión Técnica

La aplicación implementa:
- ✅ Clean Architecture con separación de concerns
- ✅ State management reactivo con Riverpod
- ✅ Persistencia local robusta con Isar
- ✅ Type-safe code generation
- ✅ Componentes reutilizables
- ✅ Error handling consistente
- ✅ Material Design 3 UI/UX

Arquitectura escalable y mantenible lista para features adicionales como sync con backend, analytics, push notifications, etc.
