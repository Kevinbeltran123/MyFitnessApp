# Rutinas – Wireframes y Flujos

## 1. RoutineListScreen
- **Header**: título “Mis Rutinas”, botón + flotante.
- **Contenido**: lista vertical de tarjetas con nombre, enfoque, chips de días y progreso semanal.
- **Empty state**: ilustración + CTA para crear primera rutina.
- **Acciones rápidas**: swipe para archivar, duplicar, eliminar.

## 2. RoutineBuilderScreen
- **AppBar** con acciones “Guardar” y “Descartar”.
- **Secciones**:
  - Datos básicos (nombre, objetivo, notas, días).
  - Selector de ejercicios: buscador reutiliza `ExerciseSearchBar`, resultados en grid.
  - Lista de ejercicios seleccionados en orden editable (drag & drop).
  - Editor de sets: modal para series, reps, peso objetivo, descanso sugerido.
- **Validaciones**: nombre obligatorio, mínimo 1 ejercicio y 1 día seleccionado.

## 3. RoutineDetailScreen
- **Resumen**: nombre, enfoque, próximos días, total de ejercicios.
- **Bloques**:
  - Lista ordenada de ejercicios con sets y pesos objetivo.
  - CTA para iniciar Modo Live.
  - Segmento con métricas recientes (volumen semanal, última sesión).
- **Acciones**: duplicar, editar, archivar, borrar.

## Flujos de Usuario
1. **Crear Rutina**
   - Desde lista pulsar + → abrir builder.
   - Completar datos básicos → buscar ejercicios → configurar sets → guardar.
   - Al guardar, regresar a lista y mostrar snackbar de confirmación.
2. **Iniciar Sesión**
   - Abrir detalle → pulsar “Comenzar entrenamiento” → pasar a Modo Live.
3. **Editar Rutina**
   - Desde detalle pulsar editar → builder precargado → aplicar cambios → guardar → volver a detalle.
4. **Archivar**
   - Swipe en lista → confirmar → mover a sección de archivadas.

## Diagramas de Flujo (texto)
- `RoutineList` → `RoutineBuilder` → (validar) → `RoutineRepository.save` → `RoutineList` (refresh stream).
- `RoutineDetail` → `LiveWorkoutScreen` → `RoutineSession.log` → `RoutineRepository.upsertSession` → dashboards y analítica.
