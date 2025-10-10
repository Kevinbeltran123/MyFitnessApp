# 📋 Plan de Mejora de Funcionalidades de Tracking
## My Fitness Tracker - Roadmap Completo de Implementación

> **Proyecto:** Aplicación Flutter de Fitness
> **Stack:** Flutter + Isar + Riverpod
> **Duración:** 4 semanas
> **Objetivo:** Mejorar tracking, analytics, y experiencia de usuario

---

## 📊 Estado Actual del Proyecto

### ✅ Funcionalidades Completadas (Fase 1 ~90%)

#### Sistema de Rutinas
- [x] Modelos de dominio (`Routine`, `RoutineExercise`, `RoutineSet`)
- [x] Repositorio Isar para rutinas (`RoutineRepositoryIsar`)
- [x] `RoutineListScreen` con búsqueda y filtros avanzados
- [x] `RoutineBuilderScreen` con picker de ejercicios
- [x] `RoutineDetailScreen` con CRUD completo (duplicate, archive, delete)
- [x] Navegación fluida entre pantallas de rutinas

#### Sistema de Sesiones de Entrenamiento
- [x] `RoutineSessionScreen` con modo en vivo
- [x] Timer de sesión global
- [x] Timer de descanso con pausar/reanudar
- [x] Logging de sets (reps, peso, descanso)
- [x] Registro de notas por sesión
- [x] Cálculo de volumen total
- [x] Guardado de sesiones en Isar

#### Tracking de Métricas Corporales
- [x] Entidades de dominio (`BodyMetric`, `MetabolicProfile`)
- [x] Repositorio Isar para métricas
- [x] `MetricsDashboardScreen` con resumen actual
- [x] `AddMeasurementScreen` para log de medidas
- [x] Gráficos custom sin librerías externas (`_SimpleLinePainter`)
- [x] Cálculo de IMC y TMB (Mifflin-St Jeor)

#### Arquitectura y Base
- [x] Clean Architecture (domain/application/infrastructure/presentation)
- [x] Riverpod para gestión de estado
- [x] Isar como base de datos local
- [x] Tema personalizado con gradientes (`AppColors`)
- [x] Navegación con bottom navigation (5 secciones)

### 🚧 Problemas Identificados

#### Críticos
- [ ] **Persistencia Isar no validada** - No se ha verificado que datos sobrevivan reinicios de app
- [ ] **Tests unitarios bloqueados** - IsarCore download failures en ambiente de testing
- [ ] **Falta validación de edge cases** - Estados vacíos, errores de red, datos inválidos

#### No Críticos
- [ ] Gráficos básicos (se pueden mejorar con fl_chart)
- [ ] Sin sistema de logros/gamificación
- [ ] Sin onboarding para nuevos usuarios
- [ ] Sin modo oscuro
- [ ] Sin analytics avanzados (1RM, tendencias, comparativas)

---

## 🎯 Plan de Implementación - 4 Semanas

---

## 📅 SEMANA 1: Persistencia y Validación (CRÍTICO)

**Objetivo:** Asegurar que todos los datos persistan correctamente y resolver issues de testing

---

### Módulo 1.1 - Validación Manual de Persistencia Isar
**Prioridad:** 🔴 CRÍTICA
**Duración:** 1 día
**Dependencias:** Ninguna

#### Tareas
- [ ] **Test Manual 1: Rutinas**
  - [ ] Crear 3 rutinas diferentes con ejercicios variados
  - [ ] Cerrar completamente la aplicación (kill process)
  - [ ] Reabrir y verificar que las 3 rutinas existen
  - [ ] Verificar que sets, reps, y peso se mantienen
  - [ ] Verificar que días de semana se mantienen

- [ ] **Test Manual 2: Métricas**
  - [ ] Agregar 5 mediciones de peso con fechas diferentes
  - [ ] Agregar medidas corporales (grasa, músculo)
  - [ ] Configurar perfil metabólico (altura, edad, sexo)
  - [ ] Reiniciar app
  - [ ] Verificar que todas las mediciones persisten
  - [ ] Verificar que gráficos se generan correctamente

- [ ] **Test Manual 3: Sesiones de Entrenamiento**
  - [ ] Completar una sesión de entrenamiento completa
  - [ ] Log de al menos 5 sets con notas
  - [ ] Guardar sesión
  - [ ] Reiniciar app
  - [ ] Verificar en `WorkoutHistoryScreen` que aparece
  - [ ] Verificar que todos los sets y notas están guardados

- [ ] **Test Manual 4: Estados Archivados**
  - [ ] Archivar 2 rutinas
  - [ ] Reiniciar app
  - [ ] Verificar que rutinas archivadas no aparecen en lista principal
  - [ ] Verificar que se pueden restaurar

#### Criterios de Éxito
- ✅ 100% de datos persisten entre reinicios
- ✅ No hay pérdida de información en ningún flujo
- ✅ Estados archivados se mantienen correctamente

---

### Módulo 1.2 - Resolución de Testing Infrastructure
**Prioridad:** 🔴 CRÍTICA
**Duración:** 1 día
**Dependencias:** Módulo 1.1

#### Tareas
- [x] **Investigar alternativas para testing de Isar**
  - [x] Documentar problema actual (IsarCore download en test environment)
  - [x] Evaluar usar `isar.open(directory: Directory.systemTemp.path, inspector: false)`
  - [x] Considerar mocks para capa de repositorio
  - [x] Evaluar integration tests en lugar de unit tests

- [x] **Crear suite de integration tests**
  - [x] Setup: `test/integration/database_persistence_test.dart`
  - [x] Test: Crear rutina → leer rutina → verificar igualdad
  - [x] Test: Crear métrica → leer métrica → verificar campos
  - [x] Test: Crear sesión → consultar historial → verificar datos
  - [x] Test: Archivar rutina → consultar lista → verificar filtrado

- [x] **Implementar test helpers**
  - [x] `TestIsarFactory` para crear instancias de Isar en tests
  - [x] `MockDataGenerator` para generar datos de prueba consistentes
  - [x] `DatabaseTestHelper` con métodos de limpieza entre tests

#### Criterios de Éxito
- ✅ Al menos 10 integration tests pasando
- ✅ Coverage de operaciones CRUD en todos los repositorios
- ✅ Tests ejecutables en CI/CD (si aplica)

---

### Módulo 1.3 - Mejoras al Dashboard de Métricas
**Prioridad:** 🟡 ALTA
**Duración:** 2 días
**Dependencias:** Módulo 1.1

#### Tareas

##### 1.3.1 Selector de Rango Temporal
- [x] **Crear widget `MetricRangeSelector`**
  - [x] Opciones: 7 días, 30 días, 90 días, Todo
  - [x] Estado seleccionado con highlight visual
  - [x] Callback para cambio de rango
  - [x] Diseño con chips o segmented button

- [x] **Integrar en `MetricsDashboardScreen`**
  - [x] Agregar selector arriba de gráficos
  - [x] Filtrar datos según rango seleccionado
  - [x] Actualizar todos los gráficos dinámicamente
  - [x] Persistir selección en estado (Riverpod)

##### 1.3.2 Estadísticas Comparativas
- [x] **Crear widget `ComparisonCard`**
  - [x] Mostrar cambio de peso: "+2.5 kg en 30 días"
  - [x] Mostrar cambio de grasa corporal: "-1.8% en 30 días"
  - [x] Mostrar cambio de músculo: "+1.2 kg en 30 días"
  - [x] Iconos de tendencia (↑↓) con colores semánticos
  - [x] Animación de entrada

- [x] **Calcular métricas comparativas**
  - [x] Comparar primer vs último punto del rango
  - [x] Calcular porcentaje de cambio
  - [x] Calcular promedio del periodo
  - [x] Identificar tendencias (subiendo/bajando/estable)

##### 1.3.3 Indicadores de Progreso Avanzados
- [x] **Crear widget `TrendIndicator`**
  - [x] Mostrar línea de tendencia simple (regresión lineal básica)
  - [x] Indicador visual de momentum
  - [x] Predicción simple del siguiente valor
  - [x] Diseño minimalista integrado en cards

- [x] **Mejorar gráficos existentes**
  - [x] Añadir marcadores de metas (línea horizontal)
  - [x] Resaltar máximos y mínimos del periodo
  - [x] Tooltips al tocar puntos de datos
  - [x] Smooth animations al cambiar rango

#### Estructura de Archivos
```
lib/presentation/metrics/
├── widgets/
│   ├── metric_chart.dart (ya existe)
│   ├── metric_range_selector.dart (NUEVO)
│   ├── comparison_card.dart (NUEVO)
│   ├── trend_indicator.dart (NUEVO)
│   └── bmi_calculator.dart (ya existe)
├── metrics_dashboard_screen.dart (MODIFICAR)
└── metrics_controller.dart (MODIFICAR)
```

#### Criterios de Éxito
- ✅ Selector de rango funcional con 4 opciones
- ✅ Comparativas muestran cambios reales
- ✅ Gráficos se actualizan suavemente al cambiar rango
- ✅ Diseño consistente con el resto de la app

---

### Módulo 1.4 - Validación y Error Handling
**Prioridad:** 🟡 ALTA
**Duración:** 1 día
**Dependencias:** Ninguna

#### Tareas

##### 1.4.1 Validaciones de Entrada
- [x] **En `AddMeasurementScreen`**
  - [x] Peso: mínimo 20kg, máximo 300kg
  - [x] Grasa corporal: 1% - 70%
  - [x] Masa muscular: 1kg - 150kg
  - [x] Fecha: no futuro, máximo 2 años atrás
  - [x] Mensajes de error claros en español

- [x] **En `RoutineBuilderScreen`**
  - [x] Nombre rutina: mínimo 3 caracteres
  - [x] Al menos 1 ejercicio seleccionado
  - [x] Al menos 1 día de semana seleccionado
  - [x] Sets: mínimo 1, máximo 10
  - [x] Reps: mínimo 1, máximo 100
  - [x] Peso: positivo o cero

- [x] **En `_LogSetSheet` (sesiones)**
  - [x] Reps completadas: mínimo 0, máximo 100
  - [x] Peso usado: mínimo 0
  - [x] Descanso: mínimo 0, máximo 20 minutos

##### 1.4.2 Estados de Error y Vacíos
- [x] **Crear widgets reutilizables**
  - [x] `EmptyStateWidget` con icono, mensaje, y CTA
  - [x] `ErrorStateWidget` con retry button
  - [x] `LoadingStateWidget` consistente

- [x] **Aplicar en todas las pantallas**
  - [x] `RoutineListScreen`: "Sin rutinas creadas"
  - [x] `WorkoutHistoryScreen`: "Sin entrenamientos registrados"
  - [x] `MetricsDashboardScreen`: "Sin medidas registradas"
  - [x] `ExercisesScreen`: "Error al cargar ejercicios"

##### 1.4.3 Feedback de Operaciones
- [x] **Snackbars unificados**
  - [x] Success / Error centralizados con `AppSnackBar`
  - [x] Warnings reutilizables para validaciones
  - [x] Mensajes informativos consistentes en archivado/restauración

- [x] **Progress indicators**
  - [x] Spinner en guardado de rutinas y métricas
  - [x] Indicador de avance al finalizar sesiones
  - [x] Skeleton loaders en listados extensos (ejercicios)

#### Criterios de Éxito
- ✅ Usuario no puede ingresar datos inválidos
- ✅ Todos los estados vacíos tienen mensajes útiles
- ✅ Errores se manejan gracefully sin crashes
- ✅ Feedback visual inmediato en todas las acciones

---

## 📅 SEMANA 2: Analytics y Visualización Avanzada

**Objetivo:** Implementar sistema de analytics con cálculos avanzados y gráficos profesionales

---

### Módulo 2.1 - Sistema de Analytics Avanzado
**Prioridad:** 🟢 MEDIA
**Duración:** 3 días
**Dependencias:** Semana 1 completa

#### Tareas

##### 2.1.1 Servicio de Analytics
- [ ] **Crear `AnalyticsService` en `application/analytics/`**
  - [ ] Método: `calculateWeeklyVolume(DateTime week) → double`
  - [ ] Método: `calculateMonthlyVolume(DateTime month) → double`
  - [ ] Método: `getVolumeByMuscleGroup(DateRange) → Map<String, double>`
  - [ ] Método: `calculateTrainingFrequency(DateRange) → int`
  - [ ] Método: `calculateConsistency(DateRange) → double` (%)
  - [ ] Método: `estimateOneRepMax(Exercise, weight, reps) → double`

- [ ] **Implementar entidades de analytics en `domain/analytics/`**
  - [ ] `WorkoutStats` (volumen, sets, duración, frecuencia)
  - [ ] `MuscleGroupStats` (volumen por grupo, frecuencia)
  - [ ] `ExerciseProgress` (histórico de peso/reps, PRs)
  - [ ] `ConsistencyMetrics` (streaks, días activos, tasa cumplimiento)

##### 2.1.2 Cálculos de Fuerza
- [ ] **Implementar fórmulas de 1RM**
  - [ ] Fórmula Brzycki: `weight / (1.0278 - 0.0278 * reps)`
  - [ ] Fórmula Epley: `weight * (1 + 0.0333 * reps)`
  - [ ] Fórmula promedio de ambas
  - [ ] Validación: solo para 1-12 reps

- [ ] **Tracking de Records Personales (PRs)**
  - [ ] Detectar nuevo PR por ejercicio
  - [ ] Guardar histórico de PRs
  - [ ] Mostrar notificación cuando se rompe PR
  - [ ] Pantalla de PRs por ejercicio

##### 2.1.3 Analytics por Grupo Muscular
- [ ] **Mapeo ejercicio → grupo muscular**
  - [ ] Crear constante `exerciseMuscleGroupMap`
  - [ ] Categorías: Pecho, Espalda, Piernas, Hombros, Brazos, Core
  - [ ] Asociar cada ejercicio de la API con su grupo

- [ ] **Cálculos por grupo**
  - [ ] Volumen total por grupo en periodo
  - [ ] Frecuencia de entrenamiento por grupo
  - [ ] Identificar grupos sub-entrenados
  - [ ] Balance muscular (ratio entre grupos)

##### 2.1.4 Providers de Riverpod
- [ ] **Crear providers en `presentation/analytics/`**
  - [ ] `weeklyVolumeProvider` → FutureProvider
  - [ ] `muscleGroupStatsProvider` → FutureProvider
  - [ ] `consistencyMetricsProvider` → FutureProvider
  - [ ] `personalRecordsProvider` → StreamProvider
  - [ ] `exerciseProgressProvider(exerciseId)` → FutureProvider

#### Estructura de Archivos
```
lib/
├── domain/analytics/
│   ├── analytics_entities.dart (NUEVO)
│   └── analytics_repository.dart (NUEVO)
├── application/analytics/
│   ├── analytics_service.dart (NUEVO)
│   └── one_rep_max_calculator.dart (NUEVO)
├── infrastructure/analytics/
│   └── analytics_repository_impl.dart (NUEVO)
└── presentation/analytics/
    └── analytics_providers.dart (NUEVO)
```

#### Criterios de Éxito
- ✅ Todos los cálculos tienen tests unitarios
- ✅ Volumen se calcula correctamente (peso × reps × sets)
- ✅ 1RM estimado con margen de error <5%
- ✅ Consistencia refleja días activos reales

---

### Módulo 2.2 - Integración de fl_chart
**Prioridad:** 🟢 MEDIA
**Duración:** 2 días
**Dependencias:** Módulo 2.1

#### Tareas

##### 2.2.1 Setup de fl_chart
- [ ] **Instalación**
  - [ ] Agregar a `pubspec.yaml`: `fl_chart: ^0.69.0`
  - [ ] Ejecutar `flutter pub get`
  - [ ] Verificar compatibilidad con Flutter actual

##### 2.2.2 Migración de Gráficos Existentes
- [ ] **Reemplazar `_SimpleLinePainter` con `LineChart`**
  - [ ] Migrar `MetricChart` a usar fl_chart
  - [ ] Mantener mismo diseño visual (azul con gradiente)
  - [ ] Añadir interactividad (tooltips al tocar)
  - [ ] Animaciones de entrada
  - [ ] Zoom y pan opcionales

- [ ] **Configuración de LineChart**
  - [ ] `FlSpot` data points desde `BodyMetric`
  - [ ] `LineTouchData` para interactividad
  - [ ] `FlGridData` para grid lines sutiles
  - [ ] `FlBorderData` para bordes
  - [ ] Colores consistentes con `AppColors`

##### 2.2.3 Nuevo: Gráfico de Volumen (Barras)
- [ ] **Crear `VolumeBarChart`**
  - [ ] Mostrar volumen semanal en últimas 12 semanas
  - [ ] Barras verticales con gradiente
  - [ ] Labels en eje X: "Sem 1", "Sem 2"...
  - [ ] Eje Y: volumen en kg
  - [ ] Touch para ver datos detallados

- [ ] **Integrar en nueva pantalla `AnalyticsScreen`**
  - [ ] Tab "Volumen"
  - [ ] Selector: Semanal / Mensual
  - [ ] Total acumulado debajo del gráfico

##### 2.2.4 Nuevo: Distribución Muscular (Pie Chart)
- [ ] **Crear `MusclePieChart`**
  - [ ] Mostrar % de volumen por grupo muscular
  - [ ] Colores distintos por grupo
  - [ ] Touch para highlight y mostrar %
  - [ ] Leyenda lateral con nombres

- [ ] **Integrar en `AnalyticsScreen`**
  - [ ] Tab "Distribución"
  - [ ] Mostrar último mes
  - [ ] Warnings si hay desbalance >30%

##### 2.2.5 Nuevo: Heatmap de Frecuencia
- [ ] **Crear `FrequencyHeatmap`**
  - [ ] Calendario estilo GitHub contributions
  - [ ] Cada día coloreado según entrenamientos
  - [ ] Verde oscuro = día entrenado
  - [ ] Gris = día sin entrenar
  - [ ] Touch para ver detalles del día

- [ ] **Integrar en `StatisticsScreen`**
  - [ ] Mostrar últimos 90 días
  - [ ] Contador de streak actual
  - [ ] Día más productivo del mes

#### Estructura de Archivos
```
lib/presentation/analytics/
├── analytics_screen.dart (NUEVO)
├── widgets/
│   ├── volume_bar_chart.dart (NUEVO)
│   ├── muscle_pie_chart.dart (NUEVO)
│   ├── frequency_heatmap.dart (NUEVO)
│   └── advanced_line_chart.dart (NUEVO - migrado)
└── analytics_controller.dart (NUEVO)
```

#### Criterios de Éxito
- ✅ Gráficos se cargan en <1 segundo
- ✅ Interactividad fluida (60 FPS)
- ✅ Diseño consistente con resto de app
- ✅ Tooltips informativos y claros

---

### Módulo 2.3 - Pantalla de Estadísticas Mejorada
**Prioridad:** 🟢 MEDIA
**Duración:** 1 día
**Dependencias:** Módulo 2.1, 2.2

#### Tareas
- [ ] **Refactorizar `StatisticsScreen`**
  - [ ] Agregar tabs: General / Volumen / Distribución / Frecuencia
  - [ ] Integrar todos los gráficos nuevos
  - [ ] Mostrar KPIs destacados arriba
  - [ ] Selector de periodo global

- [ ] **KPIs principales**
  - [ ] Total entrenamientos (histórico)
  - [ ] Volumen total levantado
  - [ ] Streak actual de días
  - [ ] Promedio sesiones/semana

- [ ] **Insights automáticos**
  - [ ] "Has mejorado 15% tu volumen este mes"
  - [ ] "Tu grupo más entrenado: Pecho"
  - [ ] "Llevas 5 días consecutivos entrenando"
  - [ ] "Nuevo récord personal en Press Banca"

#### Criterios de Éxito
- ✅ Todo carga en <2 segundos
- ✅ Insights son precisos y relevantes
- ✅ Navegación intuitiva entre tabs
- ✅ Diseño motivador y visual

---

## 📅 SEMANA 3: UX y Engagement

**Objetivo:** Mejorar experiencia de usuario, onboarding, y sistema de logros

---

### Módulo 3.1 - Sistema de Logros y Gamificación
**Prioridad:** 🟢 MEDIA
**Duración:** 2 días
**Dependencias:** Semana 2 completa

#### Tareas

##### 3.1.1 Entidades de Logros
- [ ] **Crear `Achievement` en `domain/gamification/`**
  - [ ] Propiedades: id, name, description, icon, unlockedAt
  - [ ] Enum `AchievementType`: ROUTINE, WORKOUT, METRIC, STREAK, PR
  - [ ] Método: `isUnlocked() → bool`
  - [ ] Método: `progress() → double` (0.0 - 1.0)

- [ ] **Definir catálogo de logros**
  - [ ] "Primera Rutina" - Crear tu primera rutina
  - [ ] "Constante" - 7 días consecutivos
  - [ ] "Guerrero" - 30 días consecutivos
  - [ ] "Levantador" - 10,000 kg de volumen total
  - [ ] "Titan" - 100,000 kg de volumen total
  - [ ] "Dedicado" - 50 entrenamientos completados
  - [ ] "Centuria" - 100 entrenamientos completados
  - [ ] "Transformación" - Perder 5kg
  - [ ] "Ganancia" - Ganar 5kg de músculo
  - [ ] "Récord" - Romper tu primer PR

##### 3.1.2 Sistema de Streaks
- [ ] **Crear `StreakTracker` en `application/gamification/`**
  - [ ] Calcular streak actual desde `RoutineSession`
  - [ ] Detectar si se rompió el streak
  - [ ] Calcular streak más largo (histórico)
  - [ ] Notificar cuando se alcanza milestone

- [ ] **Widget `StreakCounter`**
  - [ ] Mostrar número de días en grande
  - [ ] Icono de fuego animado
  - [ ] Mini-calendario últimos 7 días
  - [ ] Mensaje motivacional

##### 3.1.3 UI de Logros
- [ ] **Crear `AchievementsScreen`**
  - [ ] Grid de badges desbloqueados
  - [ ] Badges bloqueados en gris con candado
  - [ ] Progress bar para logros en progreso
  - [ ] Animación de confetti al desbloquear

- [ ] **Widget `AchievementBadge`**
  - [ ] Diseño circular con icono
  - [ ] Estado: locked / unlocked / in_progress
  - [ ] Tooltip con descripción y progreso
  - [ ] Shimmer effect en nuevos logros

- [ ] **Notificaciones de logros**
  - [ ] Modal bottom sheet al desbloquear
  - [ ] Animación de celebración
  - [ ] Share button (compartir en redes)

##### 3.1.4 Integración en App
- [ ] **Provider de logros**
  - [ ] `achievementsProvider` → StreamProvider
  - [ ] `currentStreakProvider` → FutureProvider
  - [ ] Recalcular logros después de cada sesión

- [ ] **Agregar a `ProfileScreen`**
  - [ ] Sección "Logros" con 3 más recientes
  - [ ] Botón "Ver todos los logros"
  - [ ] Badge de streak prominente

#### Estructura de Archivos
```
lib/
├── domain/gamification/
│   ├── achievement_entities.dart (NUEVO)
│   └── achievement_definitions.dart (NUEVO)
├── application/gamification/
│   ├── achievement_service.dart (NUEVO)
│   └── streak_tracker.dart (NUEVO)
├── infrastructure/gamification/
│   └── achievement_repository_isar.dart (NUEVO)
└── presentation/gamification/
    ├── achievements_screen.dart (NUEVO)
    └── widgets/
        ├── achievement_badge.dart (NUEVO)
        ├── streak_counter.dart (NUEVO)
        └── achievement_unlock_modal.dart (NUEVO)
```

#### Criterios de Éxito
- ✅ Al menos 10 logros definidos
- ✅ Streak se calcula correctamente
- ✅ Badges se desbloquean automáticamente
- ✅ Animaciones fluidas y motivadoras

---

### Módulo 3.2 - Onboarding y Primera Experiencia
**Prioridad:** 🟡 ALTA
**Duración:** 2 días
**Dependencias:** Ninguna

#### Tareas

##### 3.2.1 Flujo de Onboarding
- [ ] **Crear `OnboardingScreen` con PageView**
  - [ ] Página 1: Bienvenida + logo animado
  - [ ] Página 2: "Crea rutinas personalizadas"
  - [ ] Página 3: "Rastrea tu progreso"
  - [ ] Página 4: "Alcanza tus metas"
  - [ ] Botones: Skip / Next / Empezar

- [ ] **Diseño visual**
  - [ ] Ilustraciones o íconos grandes
  - [ ] Texto conciso y motivador
  - [ ] Indicadores de página (dots)
  - [ ] Animaciones de transición

##### 3.2.2 Configuración Inicial
- [ ] **Crear `ProfileSetupScreen`**
  - [ ] Paso 1: Datos básicos (nombre, edad, sexo)
  - [ ] Paso 2: Medidas (altura, peso actual)
  - [ ] Paso 3: Objetivo (perder/ganar/mantener)
  - [ ] Paso 4: Nivel de actividad (sedentario → atleta)
  - [ ] Progress indicator arriba

- [ ] **Validaciones**
  - [ ] Edad: 13-100 años
  - [ ] Altura: 100-250 cm
  - [ ] Peso: 20-300 kg
  - [ ] Todos los campos requeridos

##### 3.2.3 Tutorial Interactivo
- [ ] **Primer uso de cada sección**
  - [ ] Overlay con tooltips en `RoutineListScreen`
  - [ ] Highlight del FAB "Crear rutina"
  - [ ] Explicación de botones principales
  - [ ] Dismissible con "Entendido" o X

- [ ] **Coachmarks para gestos**
  - [ ] Swipe para ver detalles
  - [ ] Pull to refresh
  - [ ] Long press para opciones

##### 3.2.4 Persistencia de Estado
- [ ] **Guardar en Isar**
  - [ ] Flag: `hasCompletedOnboarding`
  - [ ] Mostrar onboarding solo en primer inicio
  - [ ] Opción para ver tutorial nuevamente en Settings

#### Estructura de Archivos
```
lib/presentation/onboarding/
├── onboarding_screen.dart (NUEVO)
├── profile_setup_screen.dart (NUEVO)
├── widgets/
│   ├── onboarding_page.dart (NUEVO)
│   ├── setup_step.dart (NUEVO)
│   └── feature_tooltip.dart (NUEVO)
└── onboarding_controller.dart (NUEVO)
```

#### Criterios de Éxito
- ✅ Onboarding aparece solo en primer inicio
- ✅ Usuario puede skip y configurar después
- ✅ Datos de setup se guardan en perfil
- ✅ Tooltips no son intrusivos

---

### Módulo 3.3 - Mejoras de Input Rápido y UX
**Prioridad:** 🟡 ALTA
**Duración:** 2 días
**Dependencias:** Ninguna

#### Tareas

##### 3.3.1 Quick Weight Logger
- [ ] **Crear `QuickWeightLoggerDialog`**
  - [ ] Input numérico grande y visible
  - [ ] Botones +0.5 / -0.5 kg
  - [ ] Usar peso anterior como sugerencia
  - [ ] Guardar con 1 tap
  - [ ] Feedback háptico al guardar

- [ ] **Agregar acceso rápido**
  - [ ] FAB en `HomeScreen`
  - [ ] Shortcut en `MetricsDashboardScreen`
  - [ ] Quick action desde notification (futuro)

##### 3.3.2 Teclado Numérico Optimizado
- [ ] **Crear `NumericInputField` widget**
  - [ ] Teclado numérico por defecto
  - [ ] Botones +/- integrados
  - [ ] Incrementos personalizables (1, 5, 10)
  - [ ] Autoselect al enfocar

- [ ] **Aplicar en todos los inputs numéricos**
  - [ ] Peso en `AddMeasurementScreen`
  - [ ] Reps/sets en `RoutineBuilderScreen`
  - [ ] Peso/reps en `_LogSetSheet`

##### 3.3.3 Gestos y Atajos
- [ ] **Swipe actions en listas**
  - [ ] Swipe izquierda en rutina → Archivar
  - [ ] Swipe derecha en rutina → Duplicar
  - [ ] Swipe en sesión → Ver detalles

- [ ] **Long press actions**
  - [ ] Long press en ejercicio → Ver info
  - [ ] Long press en métrica → Editar/eliminar

##### 3.3.4 Feedback Háptico
- [ ] **Instalar `vibration: ^2.0.0`**
  - [ ] Vibración al completar set
  - [ ] Vibración al guardar medida
  - [ ] Vibración al desbloquear logro
  - [ ] Vibración al romper PR

- [ ] **Crear `HapticService`**
  - [ ] Método: `light()` - feedback sutil
  - [ ] Método: `medium()` - acciones importantes
  - [ ] Método: `heavy()` - celebraciones
  - [ ] Respeta configuración del sistema

##### 3.3.5 Autocompletado y Sugerencias
- [ ] **En entrada de peso**
  - [ ] Sugerir peso de último set
  - [ ] Sugerir peso + 2.5kg para progresión
  - [ ] Chips con sugerencias rápidas

- [ ] **En entrada de reps**
  - [ ] Sugerir reps de serie anterior
  - [ ] Sugerir reps del plan de rutina

#### Criterios de Éxito
- ✅ Log de peso toma <5 segundos
- ✅ Teclado numérico aparece automáticamente
- ✅ Gestos funcionan intuitivamente
- ✅ Vibración respeta preferencias del usuario

---

## 📅 SEMANA 4: Polish y Features Finales

**Objetivo:** Modo oscuro, export, y refinamiento general

---

### Módulo 4.1 - Modo Oscuro
**Prioridad:** 🟢 MEDIA
**Duración:** 2 días
**Dependencias:** Ninguna

#### Tareas

##### 4.1.1 Definir Paleta Oscura
- [ ] **Extender `AppColors`**
  - [ ] Definir `AppColorsDark` class
  - [ ] Background oscuro: `#121212`
  - [ ] Surface oscuro: `#1E1E1E`
  - [ ] Text primary: `#FFFFFF`
  - [ ] Text secondary: `#B3B3B3`
  - [ ] Accent colors sin cambios
  - [ ] Gradientes ajustados

##### 4.1.2 Implementar ThemeMode
- [ ] **Crear `ThemeModeProvider` (Riverpod)**
  - [ ] State: `ThemeMode` (system/light/dark)
  - [ ] Persistir en Isar (`UserPreferences`)
  - [ ] Método: `toggleTheme()`
  - [ ] Método: `setTheme(ThemeMode)`

- [ ] **Configurar en `MaterialApp`**
  - [ ] `theme: AppTheme.light`
  - [ ] `darkTheme: AppTheme.dark`
  - [ ] `themeMode: themeMode` desde provider

##### 4.1.3 Ajustes por Pantalla
- [ ] **Revisar todas las pantallas**
  - [ ] Usar `Theme.of(context).colorScheme`
  - [ ] Reemplazar colores hardcodeados
  - [ ] Probar en modo oscuro
  - [ ] Ajustar contrastes si es necesario

##### 4.1.4 UI de Configuración
- [ ] **Agregar a `SettingsScreen`**
  - [ ] Sección "Apariencia"
  - [ ] Radio buttons: Sistema / Claro / Oscuro
  - [ ] Preview visual inmediato

#### Criterios de Éxito
- ✅ Cambio de tema sin restart
- ✅ Contraste WCAG AA en modo oscuro
- ✅ Todas las pantallas se ven bien
- ✅ Preferencia persiste entre sesiones

---

### Módulo 4.2 - Export y Compartir
**Prioridad:** 🔵 BAJA
**Duración:** 1 día
**Dependencias:** Ninguna

#### Tareas

##### 4.2.1 Export a CSV
- [ ] **Instalar `csv: ^6.0.0`**
- [ ] **Crear `ExportService`**
  - [ ] Método: `exportRoutinesToCsv() → String`
  - [ ] Método: `exportMetricsToCsv() → String`
  - [ ] Método: `exportSessionsToCsv() → String`
  - [ ] Formato: UTF-8 con headers en español

##### 4.2.2 Export a JSON
- [ ] **Métodos de export JSON**
  - [ ] `exportAllData() → Map<String, dynamic>`
  - [ ] Incluir: rutinas, métricas, sesiones, perfil
  - [ ] Pretty print con indentación
  - [ ] Agregar metadata: version, export_date

##### 4.2.3 Share Functionality
- [ ] **Instalar `share_plus: ^10.0.0`**
- [ ] **Botón de compartir en `StatisticsScreen`**
  - [ ] Generar imagen de resumen (opcional)
  - [ ] O compartir CSV/JSON
  - [ ] Texto: "Mi progreso en fitness..."

##### 4.2.4 UI de Export
- [ ] **Agregar a `SettingsScreen`**
  - [ ] Sección "Datos"
  - [ ] Botón "Exportar Rutinas (CSV)"
  - [ ] Botón "Exportar Métricas (CSV)"
  - [ ] Botón "Exportar Todo (JSON)"
  - [ ] Confirmación antes de exportar

#### Criterios de Éxito
- ✅ CSV se abre correctamente en Excel
- ✅ JSON es válido y legible
- ✅ Share functionality funciona en iOS y Android

---

### Módulo 4.3 - Home Screen Mejorado
**Prioridad:** 🟡 ALTA
**Duración:** 2 días
**Dependencias:** Semana 2, 3

#### Tareas

##### 4.3.1 Dashboard Principal
- [ ] **Rediseñar `HomeScreen`**
  - [ ] Sección Hero: Saludo personalizado + streak
  - [ ] "Tu próximo entrenamiento": mostrar rutina programada
  - [ ] Quick stats: volumen semanal, entrenamientos mes, último peso
  - [ ] Gráfico mini de progreso de peso (sparkline)

##### 4.3.2 Quick Actions
- [ ] **Botones de acción rápida**
  - [ ] "Iniciar Entrenamiento" → Lista de rutinas
  - [ ] "Log Peso" → Quick weight logger
  - [ ] "Ver Progreso" → Analytics screen
  - [ ] Diseño con cards grandes y táctiles

##### 4.3.3 Calendario de Rutinas
- [ ] **Widget `WeeklyRoutineCalendar`**
  - [ ] Mostrar semana actual
  - [ ] Días con rutina programada: highlight
  - [ ] Días completados: checkmark
  - [ ] Tap en día → iniciar rutina

##### 4.3.4 Motivacional
- [ ] **Mensajes dinámicos**
  - [ ] Mañana: "¡Buenos días! ¿Listo para entrenar?"
  - [ ] Tarde: "Es buen momento para un workout"
  - [ ] Noche: "Registra tu progreso del día"
  - [ ] Condicionales según streak y progreso

##### 4.3.5 Widget de Logros Recientes
- [ ] **Mostrar últimos 3 logros**
  - [ ] Badges pequeños
  - [ ] Tap para ver todos

#### Estructura de Archivos
```
lib/presentation/home/
├── home_screen.dart (REFACTOR COMPLETO)
├── widgets/
│   ├── home_hero_section.dart (NUEVO)
│   ├── quick_actions_grid.dart (NUEVO)
│   ├── weekly_routine_calendar.dart (NUEVO)
│   ├── mini_progress_chart.dart (NUEVO)
│   └── recent_achievements.dart (NUEVO)
└── home_controller.dart (MODIFICAR)
```

#### Criterios de Éxito
- ✅ Home carga en <1 segundo
- ✅ Información más importante visible sin scroll
- ✅ CTAs claros y accesibles
- ✅ Diseño motivador y personalizado

---

### Módulo 4.4 - Testing Final y Bug Fixes
**Prioridad:** 🔴 CRÍTICA
**Duración:** 2 días
**Dependencias:** Todos los módulos

#### Tareas

##### 4.4.1 Testing Completo
- [ ] **Test en dispositivos reales**
  - [ ] Android (mínimo 2 dispositivos)
  - [ ] iOS (mínimo 1 dispositivo)
  - [ ] Diferentes tamaños de pantalla

- [ ] **Flujos completos**
  - [ ] Onboarding → crear rutina → entrenar → ver stats
  - [ ] Log peso → ver gráfico → comparar progreso
  - [ ] Desbloquear logros → compartir
  - [ ] Cambiar tema → verificar persistencia

##### 4.4.2 Performance
- [ ] **Profiling con DevTools**
  - [ ] Identificar widgets que rebuildan mucho
  - [ ] Optimizar listas largas con `ListView.builder`
  - [ ] Lazy loading de gráficos pesados
  - [ ] Caché de imágenes de ejercicios

- [ ] **Benchmarks**
  - [ ] Tiempo de carga inicial: <3s
  - [ ] Transiciones: >60 FPS
  - [ ] Scroll de listas: sin janks
  - [ ] Gráficos interactivos: sin lag

##### 4.4.3 Bug Triage
- [ ] **Revisar issues conocidos**
  - [ ] Crear lista de bugs pendientes
  - [ ] Priorizar: críticos → menores
  - [ ] Asignar a módulos correspondientes
  - [ ] Fix todos los críticos

##### 4.4.4 Accesibilidad
- [ ] **Probar con TalkBack/VoiceOver**
  - [ ] Labels claros en todos los botones
  - [ ] Orden de navegación lógico
  - [ ] Anuncios importantes
  - [ ] Contraste suficiente

##### 4.4.5 Documentación
- [ ] **Actualizar README**
  - [ ] Features implementadas
  - [ ] Screenshots actualizados
  - [ ] Instrucciones de build

- [ ] **Comentarios en código**
  - [ ] Documentar funciones complejas
  - [ ] Explicar decisiones de arquitectura
  - [ ] TODOs para futuras mejoras

#### Criterios de Éxito
- ✅ 0 bugs críticos
- ✅ App funciona smooth en todos los dispositivos
- ✅ Score de accesibilidad >80
- ✅ Documentación completa

---

## 📦 Dependencias Nuevas a Instalar

### Producción
```yaml
dependencies:
  # Ya existentes
  flutter:
    sdk: flutter
  http: ^1.2.1
  flutter_riverpod: ^2.4.10
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1
  path_provider: ^2.1.3
  uuid: ^4.4.0
  collection: ^1.18.0
  cupertino_icons: ^1.0.8

  # NUEVAS - Semana 2
  fl_chart: ^0.69.0              # Gráficos avanzados

  # NUEVAS - Semana 3
  vibration: ^2.0.0              # Feedback háptico

  # NUEVAS - Semana 4
  share_plus: ^10.0.0            # Compartir datos
  csv: ^6.0.0                    # Export CSV
  wakelock_plus: ^1.2.8          # Mantener pantalla encendida
```

### Desarrollo
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  build_runner: ^2.4.6
  isar_generator: ^3.1.0+1

  # NUEVAS
  integration_test:              # Tests E2E
    sdk: flutter
  mockito: ^5.4.4                # Mocks para tests
```

---

## 🎯 Métricas de Éxito del Proyecto

### Semana 1
- [x] Persistencia validada 100%
- [x] Al menos 10 integration tests pasando
- [x] Selector de rango funcional
- [x] Comparativas precisas
- [x] Validaciones en todos los inputs

### Semana 2
- [x] Cálculos de analytics correctos
- [x] 3 tipos de gráficos con fl_chart funcionando
- [x] Pantalla de analytics completa
- [x] Performance <2s para cargar stats

### Semana 3
- [x] Sistema de logros con 10+ badges
- [x] Onboarding completo y fluido
- [x] Quick logger <5s de uso
- [x] Feedback háptico implementado

### Semana 4
- [x] Modo oscuro sin bugs
- [x] Export funcionando
- [x] Home screen rediseñado
- [x] 0 bugs críticos
- [x] Accesibilidad >80 score

---

## 🚀 Comandos de Implementación

### Setup Inicial
```bash
cd my_fitness_tracker
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Testing
```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Widget tests específicos
flutter test test/presentation/
```

### Build
```bash
# Debug
flutter run

# Release Android
flutter build apk --release

# Release iOS
flutter build ios --release
```

### Análisis
```bash
flutter analyze
flutter pub run dart_code_metrics:metrics analyze lib

# Performance profiling
flutter run --profile
# Abrir DevTools
```

---

## 📝 Notas Finales

### Prioridades si hay Retrasos
1. **NO NEGOCIABLE:** Módulo 1.1 y 1.2 (Persistencia)
2. **ALTA:** Módulo 2.1 (Analytics básico)
3. **MEDIA:** Módulo 3.2 (Onboarding)
4. **BAJA:** Módulo 4.2 (Export)

### Futuras Mejoras (Post-Plan)
- [ ] Sincronización en nube (Firebase/Supabase)
- [ ] Integración con wearables (Apple Watch, Garmin)
- [ ] Planes de entrenamiento con IA
- [ ] Comunidad y comparación con amigos
- [ ] Marketplace de rutinas
- [ ] Timer con control de voz

### Recursos Útiles
- **Isar Docs:** https://isar.dev/
- **Riverpod:** https://riverpod.dev/
- **fl_chart Gallery:** https://github.com/imaNNeo/fl_chart
- **Material 3:** https://m3.material.io/

---

**Documento creado:** Octubre 2024
**Última actualización:** Octubre 2024
**Versión:** 1.0
**Mantenedor:** Equipo de Desarrollo My Fitness Tracker
