# Isar Testing Infrastructure Strategy

_Última actualización: 10 de octubre de 2025_

## 1. Problema Detectado

- Los tests que interactúan con Isar fallaban en entornos sin acceso a red debido a `IsarError: Could not download IsarCore library`.
- El comando `flutter test` intentaba descargar `libisar.dylib` en tiempo de ejecución y quedaba bloqueado dentro de pipelines sin permisos de escritura fuera del workspace.
- Ausencia de utilidades comunes provocaba duplicación de código de inicialización y limpieza de bases temporales.

## 2. Alternativas Evaluadas

| Alternativa | Pros | Contras | Decisión |
|-------------|------|---------|----------|
| Mantener descarga automática (`download: true`) | Configuración mínima | Requiere red y permisos de escritura globales | ❌ Rechazada |
| Usar `isar.open(directory: Directory.systemTemp.path)` con binarios locales | Reutiliza binarios empaquetados, evita descargas | Necesita resolver ruta del paquete dinámicamente | ✅ Adoptada |
| Reemplazar por repositorios mock (sin Isar) | Fácil de ejecutar en CI sin binarios nativos | No valida esquema real ni conversiones | ❌ Rechazada |
| Tests unitarios aislados + pocos integration tests manuales | Menor tiempo de ejecución | Cobertura incompleta sobre persistencia real | ❌ Rechazada |

## 3. Enfoque Seleccionado

1. **Carga manual de binarios locales**  
   - `TestIsarFactory.ensureInitialized()` busca `isar_flutter_libs` en `.dart_tool/package_config.json` y mapea al dylib/so/dll correspondiente.  
   - Si el binario no está presente, hace _fallback_ a `download: true` (ejecutar con `flutter test -j 1` para evitar descargas concurrentes).

2. **Bases temporales aisladas por prueba**  
   - `DatabaseTestHelper` crea directorios en `Directory.systemTemp` y garantiza limpieza en `tearDown()`.

3. **Generadores consistentes de datos**  
   - `MockDataGenerator` produce entidades de dominio (`Routine`, `BodyMetric`, `RoutineSession`, etc.) con fixtures reutilizables.

4. **Suite de integración consolidada**  
   - `test/integration/database_persistence_test.dart` cubre CRUD completo (rutinas, métricas, sesiones, estados archivados) usando los helpers anteriores.

## 4. Lineamientos de Uso

- **Antes de abrir Isar en un test**, invocar `await TestIsarFactory.ensureInitialized();`.
- **Para nuevas colecciones**, agregar su `CollectionSchema` a `moduleOneSchemas`.
- **Nombres de base**: usa valores únicos por test y cierra instancias antes de reabrirlas para simular reinicios.
- **Ejecución en CI**: correr `flutter test test/integration/database_persistence_test.dart` con `-j 1` si se depende del fallback de descarga.

## 5. Próximos Pasos

- Integrar los helpers en futuras suites (analytics, logros) para mantener consistencia.
- Explorar parallelización segura creando subdirectorios por test en lugar de reusar `Directory.systemTemp`.
