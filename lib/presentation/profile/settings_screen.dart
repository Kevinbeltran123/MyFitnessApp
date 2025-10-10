import 'package:flutter/material.dart';
import 'package:my_fitness_tracker/shared/theme/app_colors.dart';

/// Settings screen for app configuration.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _workoutReminders = true;
  bool _progressUpdates = false;
  String _weightUnit = 'kg';
  String _language = 'es';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Notifications section
            Text(
              'Notificaciones',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),

            _SettingCard(
              child: Column(
                children: [
                  SwitchListTile(
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                        if (!value) {
                          _workoutReminders = false;
                          _progressUpdates = false;
                        }
                      });
                    },
                    title: const Text('Activar Notificaciones'),
                    subtitle: const Text('Recibir notificaciones de la app'),
                    activeColor: AppColors.accentBlue,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    value: _workoutReminders,
                    onChanged: _notificationsEnabled
                        ? (value) {
                            setState(() {
                              _workoutReminders = value;
                            });
                          }
                        : null,
                    title: const Text('Recordatorios de Entrenamiento'),
                    subtitle: const Text('Recordar completar rutinas'),
                    activeColor: AppColors.accentBlue,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    value: _progressUpdates,
                    onChanged: _notificationsEnabled
                        ? (value) {
                            setState(() {
                              _progressUpdates = value;
                            });
                          }
                        : null,
                    title: const Text('Actualizaciones de Progreso'),
                    subtitle: const Text('Resumen semanal de logros'),
                    activeColor: AppColors.accentBlue,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Units section
            Text(
              'Unidades',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),

            _SettingCard(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Unidad de Peso'),
                    subtitle: Text(
                      _weightUnit == 'kg' ? 'Kilogramos (kg)' : 'Libras (lbs)',
                    ),
                    trailing: DropdownButton<String>(
                      value: _weightUnit,
                      underline: const SizedBox.shrink(),
                      items: const [
                        DropdownMenuItem(value: 'kg', child: Text('kg')),
                        DropdownMenuItem(value: 'lbs', child: Text('lbs')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _weightUnit = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Language section
            Text(
              'Idioma',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),

            _SettingCard(
              child: ListTile(
                title: const Text('Idioma de la Aplicación'),
                subtitle: Text(_language == 'es' ? 'Español' : 'English'),
                trailing: DropdownButton<String>(
                  value: _language,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(value: 'es', child: Text('Español')),
                    DropdownMenuItem(value: 'en', child: Text('English')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _language = value;
                      });
                      _showComingSoon('Cambio de idioma');
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Data & Privacy section
            Text(
              'Datos y Privacidad',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),

            _SettingCard(
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accentBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.cloud_upload_outlined,
                        color: AppColors.accentBlue,
                      ),
                    ),
                    title: const Text('Exportar Datos'),
                    subtitle: const Text('Descargar tus datos en JSON'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showComingSoon('Exportar datos'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: AppColors.warning,
                      ),
                    ),
                    title: const Text('Borrar Caché'),
                    subtitle: const Text('Liberar espacio de almacenamiento'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _confirmClearCache(),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.warning_outlined,
                        color: AppColors.error,
                      ),
                    ),
                    title: const Text('Eliminar Todos los Datos'),
                    subtitle: const Text('Borrar permanentemente'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _confirmDeleteAllData(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Save button
            FilledButton.icon(
              onPressed: () {
                _saveSettings();
              },
              icon: const Icon(Icons.save),
              label: const Text('Guardar Cambios'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveSettings() {
    // TODO: Implement settings persistence
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuración guardada'),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.of(context).pop();
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature estará disponible próximamente'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _confirmClearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Borrar caché?'),
        content: const Text(
          'Esto eliminará imágenes y datos temporales. Tus entrenamientos y medidas no se verán afectados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Caché eliminado'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAllData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Eliminar todos los datos'),
        content: const Text(
          'Esta acción es irreversible. Se eliminarán TODOS tus entrenamientos, rutinas y medidas permanentemente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoon('Eliminar datos');
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Eliminar Todo'),
          ),
        ],
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  const _SettingCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textTertiary.withValues(alpha: 0.2),
        ),
      ),
      child: child,
    );
  }
}
