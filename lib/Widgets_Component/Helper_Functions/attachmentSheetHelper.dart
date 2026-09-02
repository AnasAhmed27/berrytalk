import 'dart:io';
import 'package:berrytalks/Widgets_Component/Helper_Functions/attchdoument.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';


class AttachmentSheetHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Maps file extension → send type so Document picker doesn't force `document`
  /// for WhatsApp videos (mp4 / 3gp).
  static String _inferAttachmentType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.mp4') ||
        lower.endsWith('.3gp') ||
        lower.endsWith('.3gpp') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.mkv') ||
        lower.endsWith('.webm')) {
      return 'video';
    }
    if (lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif')) {
      return 'image';
    }
    if (lower.endsWith('.mp3') ||
        lower.endsWith('.m4a') ||
        lower.endsWith('.ogg') ||
        lower.endsWith('.aac') ||
        lower.endsWith('.wav')) {
      return 'audio';
    }
    return 'document';
  }

// ************************************ PICK IMAGE FROM CAMER **************************************************
  static Future<void> pickFromCamera(
    BuildContext context,
    Function(List<File>) onFilesSelected,
  ) async {
    PermissionStatus status = await Permission.camera.request();

    if (status.isGranted) {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (photo != null) {
        onFilesSelected([File(photo.path)]);
      }
    } else if (status.isPermanentlyDenied) {
      _showSettingsDialog(context, "Camera");
    }
  }

  // ******************************* PICK IMAGE FROM GALLERY ****************************************************

  static Future<void> pickFromGallery(
    BuildContext context,
    Function(List<File>) onFilesSelected,
  ) async {
    Permission statusPermission =
        Platform.isAndroid && await _isAndroid13OrNewer()
        ? Permission.photos
        : Permission.storage;

    PermissionStatus status = await statusPermission.request();

    if (status.isGranted) {
      final List<XFile> images = await _picker.pickMultiImage(imageQuality: 80);
      if (images.isNotEmpty) {
        onFilesSelected(images.map((xFile) => File(xFile.path)).toList());
      }
    } else if (status.isPermanentlyDenied) {
      _showSettingsDialog(context, "Gallery");
    }
  }

  //***************************************FOR DOCUMENT ******************************************************************
  static Future<void> pickDocument(
    BuildContext context,
    Function(List<File>) onFilesSelected,
  ) async {
    PermissionStatus status = await Permission.storage.request();

    if (status.isGranted ||
        (Platform.isAndroid && await _isAndroid13OrNewer())) {
      FilePickerResult? result = await FilePicker.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'xlsx'],
      );

      if (result != null && result.paths.isNotEmpty) {
        List<File> files = result.paths
            .where((path) => path != null)
            .map((path) => File(path!))
            .toList();
        onFilesSelected(files);
      }
    } else if (status.isPermanentlyDenied) {
      _showSettingsDialog(context, "Storage");
    }
  }

  //*********************************************************************************************************** */
  static Future<bool> _isAndroid13OrNewer() async {
    return Platform.isAndroid;
  }

  // ************************* SETTING/ PERMISSION ***********************************************************

  static void _showSettingsDialog(BuildContext context, String permissionName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("$permissionName Permission Required"),
        content: Text("You have permanently disabled $permissionName permission. Please enable it from Settings."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  // ******************************* BOTTOM SHEET UI *********************************************************
  

  static void showAttachmentMenu(
    BuildContext context,
    Function(List<File> files, String type) onMediaPicked,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    final backgroundColor = isDarkMode ? const Color(0xFF0B141A) : Colors.white;
    final iconBorderColor = isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;
    final textColor = isDarkMode ? const Color(0xFFE9EDEF) : const Color(0xFF111B21);

    showModalBottomSheet(
      context: context,
      backgroundColor: backgroundColor,
      isScrollControlled: true,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      children: [
                        // Features Grid
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 4,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.85,
                            children: [
                              _buildFeatureItem(
                                icon: Icons.image_rounded,
                                color: const Color(0xFF1E90FF),
                                label: "Gallery",
                                borderColor: iconBorderColor,
                                textColor: textColor,
                                onTap: () async {
                                  Navigator.pop(context); 
                                  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                                  if (image != null) {
                                    onMediaPicked([File(image.path)], "image");
                                  }
                                },
                              ),
                              _buildFeatureItem(
                                icon: Icons.videocam_rounded,
                                color: const Color(0xFFE53935),
                                label: "Video",
                                borderColor: iconBorderColor,
                                textColor: textColor,
                                onTap: () async {
                                  Navigator.pop(context);
                                  // WhatsApp Cloud API: video/mp4 (.mp4), video/3gpp (.3gp), max 16MB
                                  final XFile? video = await _picker.pickVideo(
                                    source: ImageSource.gallery,
                                    maxDuration: const Duration(minutes: 3),
                                  );
                                  if (video != null) {
                                    onMediaPicked([File(video.path)], "video");
                                  }
                                },
                              ),
                              _buildFeatureItem(
                                icon: Icons.camera_alt_rounded,
                                color: const Color(0xFFFF1493),
                                label: "Camera",
                                borderColor: iconBorderColor,
                                textColor: textColor,
                                onTap: () async {
                                  Navigator.pop(context);
                                  final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
                                  if (photo != null) {
                                    onMediaPicked([File(photo.path)], "image");
                                  }
                                },
                              ),
                              _buildFeatureItem(
                                icon: Icons.insert_drive_file_rounded,
                                color: const Color(0xFF9370DB),
                                label: "Document",
                                borderColor: iconBorderColor,
                                textColor: textColor,
                                onTap: () async {
                                  Navigator.pop(context);
                                  FilePickerResult? result = await FilePicker.pickFiles(
                                    allowMultiple: true,
                                    type: FileType.any,
                                  );
                                  if (result != null && result.paths.isNotEmpty) {
                                    List<File> files = result.paths
                                        .where((path) => path != null)
                                        .map((path) => File(path!))
                                        .toList();
                                    // Infer type from first file so videos aren't sent as documents.
                                    final String inferred =
                                        _inferAttachmentType(files.first.path);
                                    onMediaPicked(files, inferred);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        Container(
      margin: const EdgeInsets.only(
        left: 0,
        top: 12, 
        right: 0,
        bottom: 0,
      ),
      padding: const EdgeInsets.only(
        left: 0,
        top: 0,
        right: 0,
        bottom: 0,
      ),
    ),
                        const RecentMediaGridView(),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  
   
 // ******************************** ATTACHMET ITEM BOX ******************************************************

 static Widget _buildFeatureItem({
    required IconData icon,
    required Color color,
    required String label,
    required Color borderColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: 1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          Container(
      margin: const EdgeInsets.only(
        left: 0,
        top: 8, 
        right: 0,
        bottom: 0,
      ),
      padding: const EdgeInsets.only(
        left: 0,
        top: 0,
        right: 0,
        bottom: 0,
      ),
    ),
          Text(
            label,
            style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w400),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

