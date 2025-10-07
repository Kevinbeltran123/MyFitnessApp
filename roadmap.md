# 🛠️ Implementation Plan — My Fitness Tracker (Fitness-Only)

| Phase | Focus | Est. Duration | Current Progress |
| --- | --- | --- | --- |
| 🚀 Phase 1 | Foundation & Core Data Layers | 6 semanas | 80 % |
| 🏗️ Phase 2 | Experiencia de Usuario Intermedia | 5 semanas | 45 % |
| ⚡ Phase 3 | Analítica Avanzada & Modo Live | 6 semanas | 30 % |

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
- [x] (6 h) Seleccionar y configurar estado global (`riverpod` + `ProviderScope`)
- [x] (4 h) Configurar motor de persistencia local (`isar`) y documentar decisión
- [x] (4 h) Añadir análisis estático reforzado (`flutter_lints` personalizado) y scripts `flutter analyze`, `dart format`
- [x] (0.5 d) Refactor de `home_providers.dart` para usar `FutureProvider`/`StateNotifier` unificados

### 💾 Sprint 2: Persistencia y Rutinas (2.5 semanas)

#### 🟥 Pre-Implementation Setup — Sistema de Rutinas Personalizadas
- [x] (1 d) Modelar entidades: `Routine`, `RoutineExercise`, `RoutineSession`, `SetLog`
- [x] (6 h) Diseñar esquema Isar (colecciones, índices por fecha/músculo)
- [x] (4 h) Identificar paquetes UI adicionales (`go_router`, `flex_color_scheme`)
- [x] (1 d) Wireframes: `RoutineListScreen`, `RoutineBuilderScreen`, `RoutineDetailScreen`
- [x] (4 h) Diagramar flujo usuario creación → ejecución → registro

#### 🟦 Backend/Data Layer — Rutinas
- [x] (2 d) Implementar colecciones Isar y migraciones (`isar_schema.g.dart`)
- [x] (1 d) Crear DAO/Repositories (`RoutineRepository`, `RoutineSessionRepository`)
- [x] (1 d) Servicios `RoutineService` (validaciones, duplicado, archivado)
- [x] (6 h) Cacheo en memoria + invalidación con Riverpod
- [ ] (6 h) Implementar sincronización diferida placeholder (preparar backend futuro)

#### 🟩 UI Implementation — Rutinas
- [x] (3 d) `RoutineListScreen`: listview, filtros, CTA “Crear”
- [x] (3 d) `RoutineBuilderScreen`: formularios dinámicos, selector de ejercicios reutilizando catálogo
- [x] (2 d) `RoutineDetailScreen` con resumen, duplicado, quick-edit y puente a modo live
- [x] (1 d) Widgets reutilizables: `ExercisePickerSheet`, `SetConfigCard`
- [ ] (1 d) Estados avanzados de carga/error y validaciones con `reactive_forms`

#### 🟨 Integration & Testing — Rutinas
- [x] (1 d) Conectar vistas a repositorios mediante `FutureProvider` y `StateNotifier`
- [x] (1 d) Implementar manejo de errores en UI (snackbars/refresh tras operaciones)
- [ ] (2 d) Tests unitarios `RoutineRepository`, `RoutineService` (100 % paths críticos)
- [x] (1 d) Widget tests `RoutineBuilderScreen` (creación/edición)
- [ ] (1 d) QA manual: creación, edición, duplicado, eliminación; validación series > 0

### 📊 Sprint 3: Tracker de Métricas Corporales (2 semanas)
*(Pendiente — sin cambios recientes)*
- [ ] Modelamiento entidades métricas (`BodyMetric`, `MetabolicProfile`)
- [ ] Fórmulas TMB (Mifflin-St Jeor) y almacenamiento
- [ ] Wireframes `MetricsDashboardScreen`, `MetricEntrySheet`, `MetricHistoryScreen`
- [ ] Implementación repositorio/servicios/consultas
- [ ] UI dashboards + gráficos (`fl_chart`)

> **Nueva dependencia:** integrar métricas con `RoutineSession` para analítica cruzada en Fase 3.

---

## 🏗️ Phase 2 — Experiencia de Usuario Intermedia (5 semanas)

### ⚙️ Cronograma Actualizado
- [x] Quick edit desde `RoutineDetailScreen` (reutiliza builder con rutina precargada)
- [x] Navegación cohesiva: lista → detalle → builder → modo live
- [x] Refactor navegación a `FutureProvider` para evitar estados nulos
- [ ] Pulir UX formularios (validaciones en vivo, mensajes in-app)
- [ ] Mejorar accesibilidad (lectores de pantalla, contraste)
- [ ] Persistencia incremental durante edición (autoguardado)

### 🛠️ Tareas Prioritarias
- [ ] Completar catálogo de mensajes de error y vacíos reutilizables
- [ ] Introducir snackbars unificados (`AppNotice`) con niveles de severidad
- [ ] Añadir tests widget adicionales (`RoutineDetailScreen` happy-path + edge cases)

---

## ⚡ Phase 3 — Analítica Avanzada & Modo Live (6 semanas)

### ✅ Logros Recientes
- [x] `RoutineSessionNotifier` (StateNotifier + `AsyncValue`) para gestionar sesiones activas
- [x] `RoutineSessionScreen` funcional: cronómetro global, timer de descanso, logging de sets, notas, resumen de volumen
- [x] Integración completa con repositorio/local storage (`RoutineSession` persistido vía `RoutineService.logSession`)
- [x] Cobertura de tests (unitarios + widget) para flujo logging/guardado/live navigation

### 🔄 Backlog Inmediato — Sistema de Cronómetro Integrado
- [ ] Persistencia incremental (guardar tras cada set en vez de bulk al finalizar)
- [ ] Servicio de descanso en background + notificaciones (`android_alarm_manager_plus`, `flutter_local_notifications`)
- [ ] Modo sin conexión: reintentos para sesiones pendientes
- [ ] Benchmarks de precisión de timers (>30 min sesiones)

### 🖥️ Modo Entrenamiento en Vivo — UI/UX
- [ ] HUD avanzado con quick actions (ajustar peso/reps, saltar ejercicio)
- [ ] Gestos optimizados (swipe completar, long-press editar set)
- [ ] Control multimedia (hooks `audio_service` / `just_audio`)
- [ ] Mantener pantalla activa + integración háptica (iOS/Android)

### 📈 Analítica y Comparativas
- [ ] Volumen semanal/mensual por ejercicio (gráficas) usando datos `RoutineSession`
- [ ] Tracking intensidad relativa (%1RM teórico)
- [ ] Comparativas de rendimiento (este mes vs anterior) + reporte posterior a sesión
- [ ] Insights automáticos (identificar músculos rezagados, frecuencia semanal)

---

## 📦 Technical Specifications Snapshot (Actualizado)

| Feature | Packages | State Mgmt | DB Ops | Perf Considerations | Platform Notes |
| --- | --- | --- | --- | --- | --- |
| Rutinas | `isar`, `riverpod`, `go_router` | `StateNotifier`/`FutureProvider` | CRUD rutinas, sesiones | Caché + invalidación Riverpod | Revisar schema migraciones en CI |
| Métricas | `fl_chart`, `intl` | `StateNotifier` planned | Colecciones métricas | Memoización queries semanales | Unidades métricas/imperiales |
| Cronómetro | `flutter_local_notifications`, `android_alarm_manager_plus`, `wakelock_plus` | `StateNotifier` + timers | Logs descanso, persistencia incremental | Minimizar drift (tick de 1 s) | Foreground service Android, permisos iOS |
| Analítica | `compute`, `fl_chart` | Selectores derivados | Agregados por periodo | Ejecutar cálculos en isolates | Validar precisión float |
| Modo Live | `just_audio` (pendiente), `wakelock_plus` | `StateNotifier` | Guardado incremental set a set | Wakelock + throttled rebuilds | Control multimedia diferenciado |

---

## ⚠️ Risk Mitigation Checklist

### Technical
- [ ] Benchmark Isar con >10 000 registros (incluyendo `RoutineSession`)
- [ ] Ensayo consumo batería con timers en background (Android/iOS)
- [ ] Estrategia offline/online (cola de sesiones pendientes)
- [ ] Plan de fallback si notificaciones son bloqueadas por usuario
- [ ] Documentar compatibilidad mínima (Android 10+, iOS 15+)

### Development
- [ ] Capacitación interna en Riverpod avanzado + patrones `StateNotifier`
- [ ] Workshop de background tasks (`android_alarm_manager_plus`, notifications)
- [ ] Buffer adicional 15 % para debugging de timers
- [ ] Guardrails de alcance (change requests vía PM semanal)

---

## ✅ Quality Gates por Fase (sin cambios, referencia)
- After Phase 1: arquitectura limpia, performance DB, smoke-tests rutinas, bug triage
- After Phase 2: UX validations, accesibilidad, timers ±1 s, user testing piloto
- After Phase 3: motor analítico + live mode 60 fps, beta 2 semanas, backlog solo low

---

## 🔄 Dependency Mapping Summary

- Rutinas (Phase 1) ➜ prerequisito para Cronómetro, Analítica, Modo Live
- Métricas (Phase 1) ➜ necesario para Analítica avanzada
- Cronómetro (Phase 2) ➜ requerido por Modo Live (timers/background)
- Analítica (Phase 3) ➜ depende de registros robustos de Rutinas + Métricas
- Modo Live (Phase 3) ➜ integra Rutinas + Cronómetro + Analítica

---

## 📊 Progress Tracking (actualizado)

- Fase 1 = 80 % (refactor providers + rutina live-ready)
- Fase 2 = 45 % (UX quick edit, navegación) — faltan validaciones avanzadas
- Fase 3 = 30 % (motor live básico + logging) — faltan timers background/analítica
- Actualizar % tras cada review de sprint en Jira/Linear y reflejar en README/Changelog.

---

💡 **Siguientes pasos recomendados**
1. Diseñar servicio de timers en background (API + notificaciones) y su interfaz (`RestTimerController`).
2. Definir modelo `BodyMetric` y esquema Isar asociado para iniciar Sprint 3.1 (Tracker de métricas).
3. Preparar suite de integración end-to-end (List → Detail → Live logging → Persistencia) usando `integration_test`.

---

### 🌱 Nuevas tareas sugeridas
- [ ] Documentar guía de contribución para nuevos `StateNotifier` (patrones adoptados)
- [ ] Instrumentar logging estructurado para sesiones (volumen, duración, descanso efectivo)
- [ ] Crear script de migración automática para añadir `RoutineSession` existentes al nuevo esquema si cambia
- [ ] Establecer experimentos A/B para UI del modo live (timers compactos vs completos)
- [ ] Auditoría de accesibilidad del modo live (lectores de pantalla, tamaños táctiles)

