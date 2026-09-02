import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class RecentMediaGridView extends StatefulWidget {
  const RecentMediaGridView({super.key});

  @override
  _RecentMediaGridViewState createState() => _RecentMediaGridViewState();
}

class _RecentMediaGridViewState extends State<RecentMediaGridView> {
  List<AssetEntity> _mediaList = [];
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _requestPermissionAndLoadMedia();
  }

  Future<void> _requestPermissionAndLoadMedia() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth) {
      setState(() => _hasPermission = true);

      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image | RequestType.video, 
      );

      if (albums.isNotEmpty) {
        AssetPathEntity recentAlbum = albums.first;

        List<AssetEntity> media = await recentAlbum.getAssetListRange(start: 0, end: 24);
        
        setState(() {
          _mediaList = media;
        });
      }
    } else {
      setState(() => _hasPermission = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPermission) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Text("Gallery permission is required.", style: TextStyle(color: Colors.grey)),
      );
    }

    if (_mediaList.isEmpty) {
      return const SizedBox(
        height: 150,
        child: Center(child: CircularProgressIndicator(color: Color(0xFF10A37F))),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), 
      itemCount: _mediaList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, 
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemBuilder: (context, index) {
        final asset = _mediaList[index];
        return Stack(
          children: [
            Positioned.fill(
              child: FutureBuilder<Uint8List?>(
                future: asset.thumbnailDataWithSize(const ThumbnailSize(300, 300)), 
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
                    return Image.memory(
                      snapshot.data!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    );
                  }
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF10A37F)))),
                  );
                },
              ),
            ),
            if (asset.type == AssetType.video)
              Positioned(
                bottom: 6,
                left: 6,
                child: Row(
                  children: [
                    const Icon(Icons.videocam_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      _formatDuration(asset.videoDuration),
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}