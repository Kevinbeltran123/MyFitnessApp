import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_fitness_tracker/shared/theme/app_colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Widget for displaying and picking a profile image.
///
/// Shows a circular avatar with the ability to:
/// - Display a profile image if one exists
/// - Pick an image from gallery
/// - Take a photo with camera
/// - Remove the current profile image
class ProfileImagePicker extends StatelessWidget {
  const ProfileImagePicker({
    super.key,
    this.imagePath,
    required this.onImageSelected,
    this.size = 80,
  });

  final String? imagePath;
  final ValueChanged<String?> onImageSelected;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImageSourceBottomSheet(context),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.white.withValues(alpha: 0.3),
            width: 3,
          ),
        ),
        child: ClipOval(
          child: imagePath != null && File(imagePath!).existsSync()
              ? Image.file(
                  File(imagePath!),
                  key: ValueKey<String>(imagePath!),
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.person,
                    size: 40,
                    color: AppColors.white,
                  ),
                )
              : const Icon(Icons.person, size: 40, color: AppColors.white),
        ),
      ),
    );
  }

  Future<void> _showImageSourceBottomSheet(BuildContext context) async {
    final result = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  'Foto de perfil',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accentBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.photo_library,
                      color: AppColors.accentBlue,
                    ),
                  ),
                  title: const Text('Elegir de galería'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: AppColors.success,
                    ),
                  ),
                  title: const Text('Tomar foto'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                if (imagePath != null) ...[
                  const SizedBox(height: 8),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                      ),
                    ),
                    title: const Text('Eliminar foto'),
                    onTap: () {
                      Navigator.pop(context);
                      onImageSelected(null);
                    },
                  ),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );

    if (result != null && context.mounted) {
      await _pickImage(context, result);
    }
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        // Copy image to permanent storage
        final permanentPath = await _copyImageToPermanentStorage(image.path);

        if (permanentPath != null) {
          // Delete old image if it exists
          if (imagePath != null) {
            await _deleteOldImage(imagePath!);
          }

          onImageSelected(permanentPath);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Foto de perfil actualizada'),
                backgroundColor: AppColors.success,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else {
          throw Exception('No se pudo guardar la imagen');
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Copy the selected image to permanent app storage
  Future<String?> _copyImageToPermanentStorage(String sourcePath) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final profileImagesDir = Directory('${appDir.path}/profile_images');

      // Create directory if it doesn't exist
      if (!await profileImagesDir.exists()) {
        await profileImagesDir.create(recursive: true);
      }

      // Generate unique filename with timestamp
      final extension = path.extension(sourcePath);
      final fileName =
          'profile_${DateTime.now().millisecondsSinceEpoch}$extension';
      final permanentPath = '${profileImagesDir.path}/$fileName';

      // Copy file to permanent location
      await File(sourcePath).copy(permanentPath);

      return permanentPath;
    } catch (e) {
      return null;
    }
  }

  /// Delete old profile image to free up storage
  Future<void> _deleteOldImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Silently fail - not critical if old image can't be deleted
    }
  }
}
