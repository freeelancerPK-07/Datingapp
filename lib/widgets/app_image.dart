import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Centralized image widget supporting both remote Network URLs and local File paths
/// from Camera/Gallery uploads, with graceful fallback for empty or broken images.
class AppImage extends StatelessWidget {
  final String? path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const AppImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = path?.trim() ?? '';
    Widget imageWidget;

    if (imagePath.isEmpty) {
      imageWidget = _buildFallback();
    } else if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      imageWidget = Image.network(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ??
              Container(
                width: width,
                height: height,
                color: const Color(0xFFF3F4F6),
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007A78)),
                    ),
                  ),
                ),
              );
        },
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ?? _buildFallback(),
      );
    } else {
      // Local file path from Camera or Gallery
      final file = File(imagePath);
      if (file.existsSync() || imagePath.contains(Platform.pathSeparator) || imagePath.startsWith('/')) {
        imageWidget = Image.file(
          file,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) =>
              errorWidget ?? _buildFallback(),
        );
      } else {
        imageWidget = _buildFallback();
      }
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }
    return imageWidget;
  }

  Widget _buildFallback() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFE5E7EB),
      child: Center(
        child: Icon(
          Icons.person_rounded,
          size: width != null ? (width! * 0.45).clamp(16.0, 48.0) : 24,
          color: const Color(0xFF9CA3AF),
        ),
      ),
    );
  }
}

/// Helper to get ImageProvider for CircleAvatar or DecorationImage
ImageProvider? getAppImageProvider(String? path) {
  final imagePath = path?.trim() ?? '';
  if (imagePath.isEmpty) return null;
  if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
    return NetworkImage(imagePath);
  }
  return FileImage(File(imagePath));
}

/// Service for real Camera and Gallery image capture
class AppImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  /// Captures a live photo using the device camera
  static Future<String?> pickFromCamera({
    int imageQuality = 85,
    double maxWidth = 1200,
    double maxHeight = 1200,
  }) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );
      return file?.path;
    } catch (e) {
      debugPrint('Error picking from camera: $e');
      return null;
    }
  }

  /// Selects a photo from the device photo gallery / camera roll
  static Future<String?> pickFromGallery({
    int imageQuality = 85,
    double maxWidth = 1200,
    double maxHeight = 1200,
  }) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );
      return file?.path;
    } catch (e) {
      debugPrint('Error picking from gallery: $e');
      return null;
    }
  }
}
