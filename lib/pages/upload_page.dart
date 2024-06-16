import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:komunly/pages/post_image_page.dart';
import 'package:komunly/pages/profile/profile_image_page.dart';
import 'package:komunly/pages/story_image_page.dart';
import 'package:komunly/widgets/appBar.dart';
import 'package:photo_manager/photo_manager.dart';

class UploadPage extends StatefulWidget {
  final String? postType;

  const UploadPage({super.key, required this.postType});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final ImagePicker _picker = ImagePicker();

  final List<File> _mediaFiles = [];

  Future<void> _pickMedia() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (!ps.hasAccess) {
      return;
    }

    await PhotoManager.setIgnorePermissionCheck(true);

    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
      onlyAll: true,
      type: RequestType.image,
    );

    if (paths.isEmpty) {
      return;
    }

    AssetPathEntity? path = paths.first;

    List<AssetEntity> entities =
        await path.getAssetListPaged(page: 0, size: 100);
    for (var asset in entities) {
      File? file = await asset.file;
      _mediaFiles.add(file!);
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _pickMedia();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CustomAppBar(title: "Galería"),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemCount: _mediaFiles.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return GestureDetector(
                    onTap: _takePhoto,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Container(
                        color: Colors.grey,
                        child: const Icon(
                          Icons.camera_alt,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                } else {
                  var media = _buildMediaItem(index - 1);

                  return GestureDetector(
                    onTap: () {
                      _uploadMedia(_mediaFiles[index - 1]);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Container(
                        color: Colors.grey,
                        child: media,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaItem(int index) {
    File image = _mediaFiles[index];

    return Hero(tag: image, child: Image.file(image, fit: BoxFit.cover));
  }

  Future<void> _takePhoto() async {
    final image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _mediaFiles.add(File(image.path));
      });
    }
  }

  void _uploadMedia(File mediaFile) {
    if (widget.postType == "Story") {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => StoryImagePage(image: mediaFile)));
    } else if (widget.postType == "Post") {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => PostImagePage(image: mediaFile)));
    } else if (widget.postType == "Profile") {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ProfileImagePage(image: mediaFile)));
    } else {
      return;
    }
  }
}
