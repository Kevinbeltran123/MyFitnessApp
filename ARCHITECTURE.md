# Architecture Plan — My Fitness Tracker

## 1. Overview
My Fitness Tracker evoluciona a una arquitectura en capas inspirada en Clean Architecture ligera para soportar rutinas personalizadas, analítica avanzada y modo de entrenamiento en vivo. El objetivo es aislar la lógica de dominio de la interfaz y facilitar pruebas, escalabilidad y mantenibilidad.

```
lib/
  presentation/    # Widgets, pantallas, controladores de estado de UI
  application/     # Casos de uso, coordinadores y validaciones
  domain/          # Entidades, value objects, contratos abstractos
  infrastructure/  # Fuentes de datos (API, persistencia), implementaciones concretas
  shared/          # Temas, utilidades comunes, estilos, recursos
```

Durante la transición, los archivos actuales en `lib/screens`, `lib/services`, `lib/models`, `lib/widgets` y `lib/utils` se migrarán gradualmente a los nuevos paquetes manteniendo compatibilidad temporal mediante exportaciones de conveniencia.

## 2. Layer Responsibilities
- **presentation**: Widgets de Flutter, rutas, providers Riverpod, controladores de estado (StateNotifier/AsyncNotifier). No contiene lógica de negocio compleja ni llamadas directas a infra.
- **application**: Casos de uso (p.ej. `CreateRoutine`, `LogSet`, `CalculateBasalMetabolicRate`), validaciones específicas y orquestación entre servicios. Consumirá contratos definidos en `domain`.
- **domain**: Entidades inmutables (`Routine`, `WorkoutPlan`, `BodyMetric`, etc.), interfaces (`RoutineRepository`, `MetricsRepository`, `AnalyticsService`), reglas de negocio puras.
- **infrastructure**: Implementaciones concretas de repositorios (`IsarRoutineRepository`, `HttpWorkoutService`), clientes API (`ApiClient`), adaptadores de base de datos y fuentes locales.
- **shared**: Theming, componentes comunes (colores, tipografías), utilidades (logger, formatters), configuración.

## 3. Migration Roadmap
1. **Rutinas**
   - Crear paquetes `lib/domain/routines`, `lib/infrastructure/routines`, `lib/presentation/routines`.
   - Mover `WorkoutPlan` y asociados a `lib/domain/workouts` con adaptadores en infra.
   - Reemplazar llamadas directas desde pantallas por casos de uso en `application/routines`.
2. **Métricas Corporales**
   - Definir entidades en `domain/metrics`.
   - Infraestructura local (Isar/Drift) en `infrastructure/metrics`.
   - Providers en `presentation/metrics`.
3. **Cronómetro y Modo Live**
   - Controladores de timers en `application/sessions`.
   - Servicios de notificaciones e integración multimedia en `infrastructure/system`.
   - UI en `presentation/live_workout`.
4. **Analítica**
   - Motor analítico en `application/analytics` + `domain/analytics`.
   - Almacenamiento de snapshots en `infrastructure/analytics`.

## 4. Transitional Guidelines
- Mantener exportadores temporales en `lib/screens/screens.dart`, `lib/services/services.dart`, etc., que reexporten las nuevas rutas hasta completar la migración de imports.
- Adoptar Riverpod como capa de estado única; descartar proveedores por `StatefulWidget` donde se requiera estado compartido.
- Registrar módulos en `lib/shared/di/providers.dart` para inyectar repositorios vía Riverpod.
- Documentar cada movimiento en el CHANGELOG para evitar conflictos con ramas paralelas.

## 5. Next Steps (Sprint 1)
- Crear carpetas iniciales (`lib/presentation`, `lib/application`, `lib/domain`, `lib/infrastructure`, `lib/shared`).
- Mover `ApiClient` a `lib/infrastructure/network/api_client.dart` manteniendo export temporal.
- Crear archivo `lib/domain/workouts/entities.dart` y trasladar `WorkoutPlan`, `WorkoutPlansResponse`, etc.
- Generar plantilla de providers en `lib/presentation/home/home_providers.dart` que consuma `WorkoutService` vía Riverpod.

## 6. Persistence Stack Decision
- **Motor elegido**: [Isar](https://isar.dev/) (`isar: ^3.1.0+3`) por su rendimiento nativo, soporte offline-first y consultas reactivas sin necesidad de código boilerplate extenso.
- **Complementos**: `isar_flutter_libs` para bindings nativos y `isar_generator` + `build_runner` para generar esquemas.
- **Ventajas**: consultas embebidas rápidas, soporte multiplataforma, migraciones automáticas controladas por versiones.
- **Retos**: requiere aislamiento para operaciones largas y manejo cuidadoso de colecciones anidadas; se mitigará con repositorios que expongan streams controlados y pruebas de estrés.
- **Fallback**: Si surgen limitaciones en web/desktop, se evaluará `drift` como alternativa compatible.

Esta arquitectura permitirá incorporar fácilmente sincronización offline, analítica y modo live sin que la UI dependa de detalles de infraestructura.
