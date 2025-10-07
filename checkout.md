# 📦 Checkout Roadmap — My Fitness Tracker

## 1. ESTADO ACTUAL
- 🧭 **Funcionalidades vigentes**: inicio en `lib/main.dart` con theming Material 3, `HomeScreen` con resumen diario (ejercicios destacados y contador de interacciones), explorador de ejercicios con búsqueda, filtros y paginación en `ExercisesScreen`, componentes reutilizables (`SummaryCard`, `ExerciseGridItem`, `WorkoutDetailSheet`) y capa de red tipada (`ApiClient`, `WorkoutService`).
- 🏗️ **Arquitectura**: transición en curso hacia capas (`lib/presentation`, `lib/application`, `lib/domain`, `lib/infrastructure`, `lib/shared`) documentada en `ARCHITECTURE.md`; se mantiene estructura original mientras se migran módulos; gestión de estado local por `StatefulWidget` con preparación para Riverpod.
- 🌐 **APIs integradas**: ExerciseDB (`AppConstants.workoutsBaseUrl`) activo para catálogos de ejercicios; no existen dependencias vigentes hacia servicios de nutrición.
- ✅ **Depuración completada**: se eliminaron `lib/models/nutrition_entry.dart`, `lib/services/nutrition_service.dart`, los campos de nutrición en `HomeScreen` y `AppConstants`, dejando la app enfocada exclusivamente en entrenamiento.
- 🧱 **Infraestructura nueva**: modelos de dominio de rutinas (`lib/domain/routines`) y esquemas Isar (`lib/infrastructure/routines`) listos, con repositorio `RoutineRepositoryIsar` y providers Riverpod iniciales (`lib/presentation/home/home_providers.dart`).
- 🗂️ **Diseño de UI**: wireframes y flujos documentados en `docs/routines_wireframes.md` para RoutineList/Builder/Detail.

## 2. PENDIENTES IDENTIFICADOS
- 💾 Persistencia fuera de memoria para búsquedas y filtros frecuentes (hoy solo hay caché volátil en `_cache`).
- 🧪 Cobertura de pruebas unitaria/widget para servicios, transformación de modelos y UI crítica.
- ☁️ Sincronización y resiliencia offline (no hay estrategia para reconexión o almacenamiento diferido).
- 📊 Métricas e instrumentación básica (logging estructurado, analítica de uso de funciones clave) aún sin implementar.

## 3. NUEVAS FUNCIONALIDADES PROPUESTAS

### A. Sistema de Rutinas Personalizadas
- 🎯 **Objetivo**: permitir que cada persona diseñe, ejecute y evalúe rutinas de fuerza orientadas a objetivos concretos.
- 🧩 **Componentes necesarios**: nuevos modelos `Routine`, `RoutineExercise`, `RoutineSession`; servicios de persistencia (`RoutineRepository` con almacenamiento local y sincronización futura); pantallas `RoutineListScreen`, `RoutineBuilderScreen`, `RoutineDetailScreen`; widgets de selección de ejercicios reutilizando `ExerciseSearchBar`, `ExerciseGridItem`.
- 🔁 **Flujo de usuario**: 1) Usuario crea rutina y agrega ejercicios desde catálogo → 2) configura series/reps/peso objetivo → 3) guarda rutina → 4) inicia rutina desde Modo Entrenamiento → 5) al completar series se registra progreso histórico.
- 🛠️ **Consideraciones técnicas**: usar base local (SQLite via `floor`/`drift` o `isar`) para rutinas y sesiones; validaciones de repeticiones/series > 0; hook con `WorkoutService` para mantener datos actualizados; UI accesible (formularios con validación en vivo).
- 🔗 **Dependencias**: catálogos de ejercicios existentes; widgets de detalle (`WorkoutDetailSheet`).
- ⏫ **Prioridad**: Alta — base para todas las funciones avanzadas y valor central para usuarios fitness.

### B. Calculadora y Tracker de Métricas Corporales
- 🎯 **Objetivo**: ofrecer seguimiento cuantitativo del cuerpo (peso, medidas, TMB) para relacionar progreso con volumen de entrenamiento.
- 🧩 **Componentes necesarios**: modelos `BodyMetric` (peso, % grasa, medidas) y `MetabolicRateEntry`; servicio `MetricsService` con cálculos de TMB (Mifflin-St Jeor) y almacenamiento; pantallas `MetricsDashboardScreen` y `MetricEntrySheet`; widgets de gráficas (`ProgressChart`, `MetricTrendCard`).
- 🔁 **Flujo de usuario**: 1) usuario ingresa peso, medidas y datos personales → 2) app calcula TMB y guarda registro → 3) dashboard presenta evolución con gráficas → 4) usuario consulta historial y edita valores si es necesario.
- 🛠️ **Consideraciones técnicas**: persistir historiales en base local cifrada opcional; validar entradas (formatos, unidades, edad mínima); cálculos en background para TMB y calorías de mantenimiento (sin mostrar alimentación); UI con accesibilidad visual (colores, contraste) y soporte para unidades métricas/imperiales.
- 🔗 **Dependencias**: timeline y componentes de gráficas reutilizables para otras métricas; estructura de repositorios a compartir con rutinas.
- ⏫ **Prioridad**: Alta — provee KPIs personales y habilita análisis cruzado con volumen.

### C. Análisis de Rendimiento Avanzado
- 🎯 **Objetivo**: transformar datos de rutinas y métricas en insights (volumen, intensidad, tendencias, comparativas mensuales).
- 🧩 **Componentes necesarios**: motor analítico (`PerformanceAnalyzer`) que procesa registros de entrenamiento; modelos `ExercisePerformanceSnapshot`; servicio `AnalyticsRepository`; pantallas `PerformanceOverviewScreen`, `ExerciseDetailAnalyticsScreen`; widgets `TrendChart`, `ComparisonCard`.
- 🔁 **Flujo de usuario**: 1) usuario registra sesiones → 2) analizador calcula volumen (series × reps × peso), intensidad relativa (%1RM estimado) → 3) dashboard muestra gráficos por ejercicio, mes y tendencias → 4) comparativas resaltan puntos fuertes/débiles y recomiendan ajustes.
- 🛠️ **Consideraciones técnicas**: algoritmos para estimar 1RM (Epley/Brzycki); cálculos diferidos usando isolates para no bloquear UI; almacenamiento incremental de agregados; filtros por fecha, grupo muscular y rutina; internacionalización de unidades.
- 🔗 **Dependencias**: registros de rutina y métricas corporales; widgets de gráfica del módulo B.
- ⏫ **Prioridad**: Media — depende de captura de datos robusta, aporta diferenciación avanzada.

### D. Sistema de Cronómetro Integrado
- 🎯 **Objetivo**: optimizar tiempos de descanso mediante timers adaptables y con historial.
- 🧩 **Componentes necesarios**: gestor `RestTimerController`, almacenamiento `RestTimerLog`; widgets `TimerBar`, `RestNotificationCard`; integración en `RoutineSessionScreen` y `WorkoutDetailSheet`.
- 🔁 **Flujo de usuario**: 1) al cerrar serie, app inicia descanso sugerido → 2) usuario puede ajustar duración → 3) notificación háptica/visual al concluir → 4) historial permite analizar adherencia y ajustar descansos.
- 🛠️ **Consideraciones técnicas**: usar `TickerProvider` + `Timers` resguardados en background; persistencia ligera en base local; soporte para notificaciones locales y vibración; asegurar precisión cuando app está en background (usar `android_alarm_manager_plus`, `flutter_local_notifications`).
- 🔗 **Dependencias**: rutinas y Modo Entrenamiento para detonar timers; capa de notificaciones que también se usa en Modo Live.
- ⬆️ **Prioridad**: Media — habilita experiencia pro y prepara Modo Live.

### E. Modo Entrenamiento en Vivo
- 🎯 **Objetivo**: ofrecer experiencia inmersiva durante la sesión con control total de ejercicios, timers y logging rápido.
- 🧩 **Componentes necesarios**: pantalla dedicada `LiveWorkoutScreen`; gestor de estado global (`LiveWorkoutController` con patrón Bloc/Riverpod); widgets `LiveTimerHUD`, `QuickAdjustPanel`, `SetCompletionSwiper`; integración con servicios de música (intents a reproductores externos); soporte para pantalla siempre encendida (`wakelock_plus`).
- 🔁 **Flujo de usuario**: 1) selecciona rutina → 2) ingresa Modo Live con timers activos → 3) registra series mediante gestos rápidos → 4) ajusta peso/reps con quick-actions → 5) recibe notificaciones hápticas/visuales → 6) sale con resumen de la sesión y feedback.
- 🛠️ **Consideraciones técnicas**: coordinar timers y estado con `Stream`/`StateNotifier`; manejar paulatinamente modo background; integración opcional con controles multimedia (`audio_service`); resumen post-entrenamiento generado a partir de logs; garantizar modo full-screen y wakelock activado.
- 🔗 **Dependencias**: rutinas (datos de la sesión), cronómetro integrado, analítica para generar resumen.
- ⏫ **Prioridad**: Alta — propuesta de valor diferenciada y visible para usuarios finales.

## 4. PLAN DE IMPLEMENTACIÓN
- 🏁 **Fase 1 — Fundaciones (6 semanas)**: eliminar módulos de nutrición; crear infraestructura de persistencia local; implementar Sistema de Rutinas y Tracker de Métricas con vistas básicas; habilitar timers simples dentro de rutinas. Riesgos: migración de datos heredados → Mitigación: script de limpieza y pruebas guiadas.
- 🚀 **Fase 2 — Experiencia Intermedia (5 semanas)**: ampliar cronómetro con notificaciones y historial; desplegar dashboards iniciales de métricas; preparar componentes de gráficas reutilizables; cubrir pruebas automatizadas clave. Riesgos: rendimiento en renderizado de gráficos → Mitigación: usar `fl_chart` optimizando datasets y memoización.
- 🔬 **Fase 3 — Analítica Avanzada & Modo Live (6 semanas)**: desarrollar Performance Analyzer, comparativas y tendencias; lanzar Modo Entrenamiento en Vivo con auto-logging, quick-actions y resúmenes; iterar feedback de usuarios beta. Riesgos: complejidad de coordinación de timers y estado global → Mitigación: adoptar patrón Bloc/Riverpod con pruebas de integración y monitoreo de errores.

## 5. ARQUITECTURA RECOMENDADA
- 🧱 **Reestructuración**: introducir capa `lib/repositories` para persistencia (rutinas, métricas, historial); mover lógica analítica a `lib/domain/services`; mantener UI en `lib/presentation` para escalar. Refactorizar `HomeScreen` en módulos independientes (dashboard, spotlight, quick actions).
- 🪓 **Depuración de nutrición**: eliminar archivos y referencias listadas, ajustar modelos `_HomeSummary`, `AppConstants`, tests y strings. Reemplazar copy por mensajes centrados en entrenamiento.
- 🧠 **Patrones propuestos**: usar Riverpod/Bloc para estado global (especialmente Modo Live y timers); aplicar Clean Architecture ligera (presentation → application → domain → infrastructure) para aislar cálculos de interfaz.
- ⚙️ **Escalabilidad y rendimiento**: cálculos intensivos en isolates; memoización de gráficos; sincronización futura con backend mediante repositorios; manejo de grandes historiales con paginación y agregaciones precalculadas.
- ⏱️ **Modo entrenamiento en vivo**: estado compartido para timers y sets; notificaciones locales y hápticas; integración con `wakelock_plus` y `audio_session`; fallback cuando el SO limite tareas en background.

- ✅ **Pruebas**: Tests unitarios de servicio/controlador y flujo de rutina en `test/integration/routine_service_flow_test.dart`.