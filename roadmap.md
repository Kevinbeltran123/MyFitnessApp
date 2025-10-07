# 🛠️ Implementation Plan — My Fitness Tracker (Fitness-Only)

| Phase | Focus | Est. Duration | Current Progress |
| --- | --- | --- | --- |
| 🚀 Phase 1 | Foundation & Core Data Layers | 6 semanas | 0 % |
| 🏗️ Phase 2 | Experiencia de Usuario Intermedia | 5 semanas | 0 % |
| ⚡ Phase 3 | Analítica Avanzada & Modo Live | 6 semanas | 0 % |

---

## 🚀 Phase 1 — Foundation (6 semanas)

### 🔥 Sprint 1: Depuración & Arquitectura (1 semana)

#### 🧹 Eliminación de Nutrición (Dependencia: ninguna)
- [x] (4 h) Revisar `lib/models`, `lib/services`, `lib/screens` y eliminar clases/funciones de nutrición (p.ej. `NutritionEntry`, `nutrition_service.dart`)
- [x] (2 h) Actualizar `AppConstants` retirando `nutritionBaseUrl` y cabeceras asociadas
- [x] (4 h) Ajustar `_HomeSummary` y widgets ligados para remover campos de nutrición, confirmar compilación limpia (`flutter analyze`)
- [x] (2 h) Eliminar activos/strings asociados en `lib/utils/constants.dart`, `l10n`, assets

#### 🧱 Arquitectura Base (Dependencia: limpieza nutrición)
- [x] (1 d) **Plan**: definir árbol de carpetas final (`lib/presentation`, `lib/domain`, `lib/infrastructure`) y documentarlo en `ARCHITECTURE.md`
- [x] (6 h) Seleccionar y configurar estado global (`riverpod: ^3.0.0-dev` o estable más reciente)
- [x] (4 h) Configurar motor de persistencia local (`isar: ^4.0.0` o `drift: ^2.18.0`); preparar decisión con pros/contras
- [x] (4 h) Añadir análisis estático reforzado (`flutter_lints` personalizado) y scripts `flutter analyze`, `dart format`

### 💾 Sprint 2: Persistencia y Rutinas (2.5 semanas)

#### 🟥 Pre-Implementation Setup — Sistema de Rutinas Personalizadas
- [ ] (1 d) Modelar entidades: `Routine`, `RoutineExercise`, `RoutineSession`, `SetLog` (UML + doc)
- [ ] (6 h) Diseñar esquema Isar: colecciones, índices (por fecha, músculo, rutina)
- [ ] (4 h) Identificar paquetes UI adicionales (`go_router: ^14.0.0`, `flex_color_scheme: ^7.3.0` si aplica)
- [ ] (1 d) Wireframes: `RoutineListScreen`, `RoutineBuilderScreen`, `RoutineDetailScreen`, flujos en FigJam
- [ ] (4 h) Diagrama de flujo de usuario desde creación → ejecución → registro

#### 🟦 Backend/Data Layer — Rutinas
- [ ] (2 d) Implementar colecciones Isar y migraciones (scripts `isar_schema.g.dart`)
- [ ] (1 d) Crear DAO/Repositories (`RoutineRepository`, `RoutineSessionRepository`) con interfaces en `domain`
- [ ] (1 d) Servicios de negocio `RoutineService` (validaciones series/reps > 0, clonado de rutinas)
- [ ] (6 h) Cacheo en memoria + invalidación (usar `riverpod` `AsyncNotifier`)
- [ ] (6 h) Implementar sincronización diferida placeholder (preparar para backend futuro)

#### 🟩 UI Implementation — Rutinas
- [ ] (3 d) `RoutineListScreen`: listview, filtros, CTA “Crear”
- [ ] (3 d) `RoutineBuilderScreen`: formularios dinámicos, selector de ejercicios (reuse `ExerciseSearchBar`)
- [ ] (2 d) `RoutineDetailScreen` con resumen, duplicar, activar modo live
- [ ] (1 d) Widgets reutilizables: `ExercisePickerSheet`, `SetConfigCard`
- [ ] (1 d) Estados de carga/error, validaciones en formularios (usar `reactive_forms: ^17.0.0` opcional)

#### 🟨 Integration & Testing — Rutinas
- [ ] (1 d) Conectar vistas a repositorios Riverpod
- [ ] (1 d) Implementar manejo de errores (snackbars, `ErrorCardWidget`)
- [ ] (2 d) Tests unitarios `RoutineRepository`, `RoutineService` (100 % paths críticos)
- [ ] (1 d) Widget tests `RoutineBuilderScreen` (validaciones de reglas)
- [ ] (1 d) QA manual: creación, edición, duplicado, eliminación; casos de series = 0 (debe bloquear)

### 📊 Sprint 3: Tracker de Métricas Corporales (2 semanas)

#### Pre-Implementation Setup — Métricas
- [ ] (1 d) Modelar `BodyMetric` (peso, medidas), `MetabolicProfile`; relacionar con `RoutineSession` (referencia cruzada)
- [ ] (4 h) Definir fórmulas TMB (Mifflin-St Jeor) y estrategias de almacenamiento (float/double, unidades)
- [ ] (6 h) Elegir paquete de gráficos (`fl_chart: ^0.66.0`) y plan de reutilización
- [ ] (1 d) Wireframes `MetricsDashboardScreen`, `MetricEntrySheet`, `MetricHistoryScreen`
- [ ] (4 h) Diseñar flujos: ingreso de datos -> dashboard -> histórico

#### Backend/Data Layer — Métricas
- [ ] (1 d) Crear tablas/colecciones `BodyMetric`, `MetabolicRateEntry` + migraciones
- [ ] (6 h) DAOs y repos `MetricsRepository` (consultas por rango de fechas, agregados)
- [ ] (1 d) Servicios `MetricCalculatorService` (TMB, calorías mantenimiento)
- [ ] (6 h) Tareas en background: recálculo TMB al actualizar datos personales
- [ ] (4 h) Cache/memoization de consultas por semana/mes

#### UI Implementation — Métricas
- [ ] (2 d) `MetricsDashboardScreen`: tarjetas resumen, gráficas
- [ ] (1 d) `MetricEntrySheet`: formularios con validaciones, unidades alternas
- [ ] (1 d) `MetricHistoryScreen`: lista + filtros (mes, trimestre)
- [ ] (1 d) Integrar `ProgressChart` (líneas), `MetricTrendCard`
- [ ] (1 d) Animaciones suaves para cambios de métricas (implicit animations)

#### Integration & Testing — Métricas
- [ ] (1 d) Conectar a Riverpod providers, combinar con rutinas para mostrar correlación básica
- [ ] (1 d) Manejar errores (valores fuera de rango) con toasts y highlights
- [ ] (2 d) Tests unitarios fórmulas TMB (casos por género, unidades)
- [ ] (1 d) Widget tests para Dashboard (render de gráficas con datos dummy)
- [ ] (1 d) QA manual: ingresar, editar, borrar métricas; cambiar unidades

---

## 🏗️ Phase 2 — Core Features (5 semanas)

### ⏱️ Sprint 4: Sistema de Cronómetro Integrado (2 semanas)

#### Pre-Implementation Setup — Cronómetro
- [ ] (4 h) Definir modelos `RestTimerProfile`, `RestTimerLog` (relación con `RoutineSession` y `SetLog`)
- [ ] (4 h) Diagramar flujo: finalizar serie → iniciar descanso → notificación
- [ ] (4 h) Seleccionar paquetes (`flutter_local_notifications: ^17.1.2`, `android_alarm_manager_plus: ^4.0.2`, `wakelock_plus: ^1.1.1`)
- [ ] (4 h) Wireframe `TimerOverlay`, `RestNotificationCard`

#### Backend/Data Layer — Cronómetro
- [ ] (1 d) Tablas/logs para descansos + migraciones
- [ ] (1 d) Crear `RestTimerController` (service) con streams y persistencia
- [ ] (1 d) Configurar notificaciones locales en iOS/Android (canales, permisos)
- [ ] (6 h) Background handlers para precisión con app en background
- [ ] (4 h) Configurar políticas de batería (Android Foreground service stub)

#### UI Implementation — Cronómetro
- [ ] (1 d) Integrar overlay en `RoutineSessionScreen` (HUD)
- [ ] (1 d) Widgets `TimerBar`, `RestAdjustSheet`, `QuickStartButton`
- [ ] (1 d) Animaciones para countdown, vibraciones (uso de `HapticFeedback`)
- [ ] (1 d) Formulario de presets por ejercicio/rutina
- [ ] (1 d) Estados de error (notificación denegada) y fallback manual

#### Integration & Testing — Cronómetro
- [ ] (1 d) Conectar a `RoutineService` para auto-iniciar descanso al registrar sets
- [ ] (1 d) Estado global con Riverpod: provider `restTimerProvider` observado por UI
- [ ] (1 d) Tests unitarios controladores (pausar/reanudar, cambio duración)
- [ ] (1 d) Integration tests simulando background (usar `integration_test`)
- [ ] (0.5 d) QA manual en dispositivo real (Android + iOS) con notificaciones

### 📈 Sprint 5: Refinamientos & Persistencia Extendida (3 semanas)

#### Mejoras Técnicas (arrastran dependencias Fase 1)
- [ ] (1 d) Implementar sincronización offline-first: colas para rutinas/metricas sin conexión
- [ ] (1 d) Lazy loading en catálogos de ejercicios (mejora de `ExercisesScreen`)
- [ ] (0.5 d) Instrumentación básica (`firebase_analytics` o `amplitude_flutter`) para eventos clave
- [ ] (1 d) Refactor `HomeScreen` → `DashboardScreen` modular (widgets separados, proveedores)
- [ ] (1 d) Documentar API interna (doc comments, diagramas actualizados)

#### UX Enhancements
- [ ] (1 d) Ajustar theming responsivo (tablets, landscape)
- [ ] (1 d) Agregar tutorial onboarding para nuevas funciones (rutinas, métricas)
- [ ] (1 d) Soporte accesibilidad (VoiceOver/TalkBack) en formularios y timers
- [ ] (1 d) Optimizar rendimiento listados (use `ListView.builder`, `AutomaticKeepAlive`)

#### QA & Stabilization
- [ ] (1 d) Plan de pruebas cruzadas dispositivos (iOS 15+, Android 10+)
- [ ] (1 d) Tests e2e básicos con `integration_test` (crear rutina, ejecutar descanso, registrar métrica)
- [ ] (0.5 d) Crear dashboards internos (Notion/Jira) para bugs
- [ ] (0.5 d) Retro y backlog grooming para Phase 3

---

## ⚡ Phase 3 — Advanced Features (6 semanas)

### 📊 Sprint 6: Análisis de Rendimiento Avanzado (3 semanas)

#### Pre-Implementation Setup
- [ ] (1 d) Diseño de motor analítico (`PerformanceAnalyzer`): entradas (SetLogs, Metrics), salidas (snapshots)
- [ ] (1 d) Definir modelos `ExercisePerformanceSnapshot`, `MonthlyComparison`, `WeaknessInsight`
- [ ] (4 h) Decidir librería de gráficos avanzada (reutilizar `fl_chart`)
- [ ] (1 d) Wireframes `PerformanceOverviewScreen`, `ExerciseDetailAnalyticsScreen`
- [ ] (4 h) Diagramas de secuencia para cálculos (uso de isolates)

#### Backend/Data Layer — Analítica
- [ ] (1 d) Implementar agregaciones (volumen, intensidad) en isolates (`compute` o `isolate_runner`)
- [ ] (1 d) Repositorio `AnalyticsRepository` con caché y almacenamiento incremental
- [ ] (1 d) Algoritmos 1RM (Epley, Brzycki) + configuración en `Settings`
- [ ] (6 h) Mecanismo de comparativas mensual (guardar snapshots)
- [ ] (6 h) Generador de insights (puntos fuertes/débiles)

#### UI Implementation — Analítica
- [ ] (2 d) `PerformanceOverviewScreen`: widgets `TrendChart`, `ComparisonCard`, filtros
- [ ] (1 d) `ExerciseDetailAnalyticsScreen`: selector ejercicios, gráficas por set/peso
- [ ] (1 d) Animaciones (hero transitions, smooth graph updates)
- [ ] (1 d) Estados offline (usar cached snapshots)
- [ ] (1 d) Exportar datos (share CSV, optional backlog)

#### Integration & Testing — Analítica
- [ ] (1 d) Integrar con rutinas y métricas (providers combinados)
- [ ] (1 d) Manejo de errores (datos incompletos, division by zero)
- [ ] (2 d) Tests unitarios algoritmos volumen/intensidad/1RM
- [ ] (1 d) Tests widget gráficos (pumping data sets)
- [ ] (1 d) QA manual: comparativas mes actual vs anterior, detección puntos débiles

### 🟢 Sprint 7: Modo Entrenamiento en Vivo (3 semanas)

#### Pre-Implementation Setup
- [ ] (1 d) Arquitectura Modo Live: `LiveWorkoutController` (Riverpod StateNotifier + Streams)
- [ ] (1 d) Modelos adicionales (LiveSessionState, LiveSetState) enlazados a rutinas
- [ ] (4 h) Dependencias: `wakelock_plus`, `audio_service`, `just_audio` para control música
- [ ] (1 d) Wireframes `LiveWorkoutScreen`, `QuickAdjustPanel`, `SessionSummarySheet`
- [ ] (4 h) Definir flujos: entrada → ejecución → resumen → compartir

#### Backend/Data Layer — Modo Live
- [ ] (1 d) Servicios para auto-logging sets con timestamps, peso actual
- [ ] (1 d) Persistencia incremental (guardar tras cada set)
- [ ] (6 h) Integración con RestTimer (auto inicio)
- [ ] (1 d) Control multimedia (intents Android, `MPNowPlayingInfoCenter` iOS)
- [ ] (6 h) Notificaciones hápticas, fallback vibración (config platform channels)

#### UI Implementation — Modo Live
- [ ] (2 d) `LiveWorkoutScreen`: layout full-screen, timers prominentes, lista de ejercicios
- [ ] (1 d) Gestos (swipe para completar, tap prolongado para editar)
- [ ] (1 d) Quick-actions para ajustar peso/reps (`BottomSheet` + number pickers)
- [ ] (1 d) HUD de timers + estado actual, integrando `RestTimerController`
- [ ] (1 d) Resumen post-entrenamiento (`SessionSummarySheet`) con métricas clave

#### Integration & Testing — Modo Live
- [ ] (1 d) Conectar a Rutinas, Métricas y Analítica (actualizar insights al cerrar sesión)
- [ ] (1 d) Estado global con Riverpod + `StateNotifier` para sincronizar UI/Timers
- [ ] (2 d) Tests de integración: completar rutina, pausas, reanudaciones
- [ ] (1 d) Pruebas de estrés (sesiones largas, >100 sets)
- [ ] (1 d) QA manual con dispositivos reales (verificar wakelock, música, notificaciones)

---

## 📦 Technical Specifications Snapshot

| Feature | Packages | State Mgmt | DB Ops | Perf Considerations | Platform Notes |
| --- | --- | --- | --- | --- | --- |
| Rutinas | `isar`/`drift`, `riverpod`, `go_router` | Riverpod `AsyncNotifier` | CRUD rutinas, sesiones, set logs | Lazy caching, indexes por fecha/músculo | Verificar esquemas iOS arm64 |
| Métricas | `fl_chart`, `intl` | Riverpod providers combinados | Tablas métricas, migraciones TMB | Memoización consultas, batch inserts | Unidades imperiales (US) |
| Cronómetro | `flutter_local_notifications`, `android_alarm_manager_plus`, `wakelock_plus` | Riverpod `Notifier` + Streams | Tabla logs descansos | Timers en background, minimizar drift | Foreground service Android, permiso notifications iOS |
| Analítica | `fl_chart`, isolates (`compute`) | Riverpod selectors | Tablas snapshots, agregados | Cálculos en isolates, throttling updates | Comprobar precisión float |
| Modo Live | `audio_service`, `just_audio`, `wakelock_plus` | Riverpod `StateNotifier` | Persistencia incremental sets | Wakelock, throttled rebuilds | Controles multimedia iOS/Android difieren |

---

## ⚠️ Risk Mitigation Checklist

### Technical
- [ ] Evaluar rendimiento de Isar/Drift con datos > 10 000 registros (benchmark)
- [ ] (4 h) Pruebas de consumo batería con timers activos (Android/iOS)
- [ ] (4 h) Estrategia offline/online (reintentos, banners de estado)
- [ ] (4 h) Plan de fallback si notificaciones son bloqueadas por el usuario
- [ ] (4 h) Documentar compatibilidad mínima (Android 10+, iOS 15+)

### Development
- [ ] (4 h) Capacitación interna en Riverpod avanzado y Isar migraciones
- [ ] (4 h) Workshops sobre integración de `flutter_local_notifications` & background tasks
- [ ] (4 h) Estimar buffers para debugging timers (añadir 15 % tiempo)
- [ ] (4 h) Establecer guardrails de alcance (change requests vía PM semanal)

---

## ✅ Quality Gates por Fase

### After Phase 1
- [ ] Code review checklist (arquitectura limpia, sin referencias a nutrición)
- [ ] Performance: DB operaciones < 50 ms promedio, scroll fluido sin jank
- [ ] User testing: flujo creación rutina + métricas con 5 usuarios internos
- [ ] Bug triage: resolver todos los bloqueantes y mayores antes de avanzar

### After Phase 2
- [ ] Code review: validaciones UX, manejo de notificaciones, accesibilidad
- [ ] Benchmarks: timers precisión ±1 s, dashboards < 16 ms frame budget
- [ ] User testing: sesiones entrenamiento con cronómetro + métricas (grupo piloto)
- [ ] Bug prioritization: cerrar críticos; documentar medium para Phase 3

### After Phase 3
- [ ] Code review: motor analítico, Modo Live, control multimedia
- [ ] Performance: cálculos analíticos < 300 ms en isolates, Live UI 60 fps
- [ ] Beta testing: 2 semanas con usuarios reales, recolectar feedback
- [ ] Bugfix: cerrar todos los issues de severidad alta/medium, backlog solo low

---

## 🔄 Dependency Mapping Summary

- Rutinas (Phase 1) ➜ prerequisito para Cronómetro, Analítica, Modo Live
- Métricas (Phase 1) ➜ necesario para Analítica avanzada
- Cronómetro (Phase 2) ➜ requerido por Modo Live
- Analítica (Phase 3) ➜ depende de registros robustos de Rutinas + Métricas
- Modo Live (Phase 3) ➜ integra Rutinas + Cronómetro + Analítica

---

## 📊 Progress Tracking (initial targets)

- Fase 1 completion = 0 % (meta: Git milestone `v1-foundation`)
- Fase 2 completion = 0 % (meta: milestone `v2-core`)
- Fase 3 completion = 0 % (meta: milestone `v3-advanced`)
- Actualizar % tras cada review de sprint en Jira/Linear y reflejar en README/Changelog.

---

💡 **Siguiente paso recomendado:** iniciar Sprint 1 con reunión de arranque para alinear arquitectura, confirmar elección de base de datos local y crear historias de usuario en el sistema de gestión (Jira/Linear).
