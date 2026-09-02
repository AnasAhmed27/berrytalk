import 'dart:io';

import 'package:berrytalks/Widgets_Component/Utils/VideoThumbnailCache.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Chat video preview: shows a disk-cached thumbnail with play overlay.
class CachedVideoThumbnail extends StatefulWidget {
  final String videoPath;
  final Color fallbackIconColor;
  final bool isDark;
  final bool isUploading;
  final Widget? uploadingOverlay;
  final String? fileName;

  const CachedVideoThumbnail({
    super.key,
    required this.videoPath,
    required this.fallbackIconColor,
    required this.isDark,
    this.isUploading = false,
    this.uploadingOverlay,
    this.fileName,
  });

  @override
  State<CachedVideoThumbnail> createState() => _CachedVideoThumbnailState();
}

class _CachedVideoThumbnailState extends State<CachedVideoThumbnail> {
  Future<String?>? _thumbFuture;

  @override
  void initState() {
    super.initState();
    _thumbFuture = VideoThumbnailCache.getThumbnailPath(widget.videoPath);
  }

  @override
  void didUpdateWidget(covariant CachedVideoThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoPath != widget.videoPath) {
      _thumbFuture = VideoThumbnailCache.getThumbnailPath(widget.videoPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: widget.isDark
              ? Colors.white10
              : Colors.black.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            FutureBuilder<String?>(
              future: _thumbFuture,
              builder: (context, snapshot) {
                final path = snapshot.data;
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ColoredBox(
                    color: Colors.black26,
                    child: Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: widget.fallbackIconColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  );
                }

                if (path != null && path.isNotEmpty && File(path).existsSync()) {
                  return Image.file(
                    File(path),
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                    errorBuilder: (_, __, ___) => _fallback(),
                  );
                }

                return _fallback();
              },
            ),
            // Darken slightly so play button stays readable on bright frames.
            const ColoredBox(color: Color(0x33000000)),
            if (!widget.isUploading)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
            if (widget.isUploading && widget.uploadingOverlay != null)
              widget.uploadingOverlay!,
            if (widget.fileName != null && widget.fileName!.isNotEmpty)
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Text(
                  widget.fileName!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _fallback() {
    return ColoredBox(
      color: widget.isDark ? Colors.white10 : const Color(0x14000000),
      child: Center(
        child: Icon(
          Icons.videocam_rounded,
          size: 48,
          color: widget.fallbackIconColor.withValues(alpha: 0.85),
        ),
      ),
    );
  }
}
