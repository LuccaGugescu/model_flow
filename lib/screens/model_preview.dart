import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';

class ModelPreview extends StatefulWidget {
  final String argument; // Specify the type of argument
  const ModelPreview({Key? key, required this.argument}) : super(key: key);

  @override
  State<ModelPreview> createState() => _ModelPreviewState();
}

class _ModelPreviewState extends State<ModelPreview> {
  late Future<List<String>> _animationLengthFuture;
  Flutter3DController controller = Flutter3DController();
  String? chosenAnimation;
  String? chosenTexture;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    // Delay the execution of the future by 2 seconds
    _animationLengthFuture = Future.delayed(const Duration(seconds: 4), () {
      return controller.getAvailableAnimations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FutureBuilder<List<String>>(
        future: _animationLengthFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              margin: const EdgeInsets.only(bottom: 32),
              child: const CircularProgressIndicator(
                  backgroundColor: Colors.black, color: Colors.white),
            ); // Placeholder or loading indicator can be added here
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            int animationLength = snapshot.data?.length ?? 0;
            return animationLength > 0
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton.small(
                        heroTag: null,
                        onPressed: () {
                          setState(() {
                            isPlaying = !isPlaying;
                          });
                          isPlaying
                              ? controller.playAnimation()
                              : controller.pauseAnimation();
                        },
                        child: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                      ),
                      const SizedBox(height: 4),
                      FloatingActionButton.small(
                        heroTag: null,
                        onPressed: () {
                          controller.resetAnimation();
                        },
                        child: const Icon(Icons.replay_circle_filled),
                      ),
                      const SizedBox(height: 4),
                      FloatingActionButton.small(
                        heroTag: null,
                        onPressed: () async {
                          List<String> availableAnimations = snapshot.data!;
                          chosenAnimation = await showPickerDialog(
                              availableAnimations, chosenAnimation);
                          controller.playAnimation(
                              animationName: chosenAnimation);
                        },
                        child: const Icon(Icons.format_list_bulleted_outlined),
                      ),
                      const SizedBox(height: 4),
                      FloatingActionButton.small(
                        heroTag: null,
                        onPressed: () async {
                          List<String> availableTextures =
                              await controller.getAvailableTextures();
                          chosenTexture = await showPickerDialog(
                              availableTextures, chosenTexture);
                          controller.setTexture(
                              textureName: chosenTexture ?? '');
                        },
                        child: const Icon(Icons.list_alt_rounded),
                      ),
                      const SizedBox(height: 4),
                      FloatingActionButton.small(
                        heroTag: null,
                        onPressed: () {
                          controller.setCameraOrbit(20, 20, 5);
                        },
                        child: const Icon(Icons.camera_alt),
                      ),
                      const SizedBox(height: 4),
                      FloatingActionButton.small(
                        heroTag: null,
                        onPressed: () {
                          controller.resetCameraOrbit();
                        },
                        child: const Icon(Icons.cameraswitch_outlined),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton.small(
                        heroTag: null,
                        onPressed: () async {
                          List<String> availableTextures =
                              await controller.getAvailableTextures();
                          chosenTexture = await showPickerDialog(
                              availableTextures, chosenTexture);
                          controller.setTexture(
                              textureName: chosenTexture ?? '');
                        },
                        child: const Icon(Icons.list_alt_rounded),
                      ),
                      const SizedBox(height: 4),
                      FloatingActionButton.small(
                        heroTag: null,
                        onPressed: () {
                          controller.setCameraOrbit(20, 20, 5);
                        },
                        child: const Icon(Icons.camera_alt),
                      ),
                      const SizedBox(height: 4),
                      FloatingActionButton.small(
                        heroTag: null,
                        onPressed: () {
                          controller.resetCameraOrbit();
                        },
                        child: const Icon(Icons.cameraswitch_outlined),
                      ),
                    ],
                  );
          }
        },
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.grey,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Flutter3DViewer(
              controller: controller,
              src: widget.argument,
            ),
          ),
          Positioned(
            top: 24,
            left: 5,
            child: IconButton(
              iconSize: 40,
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.chevron_left),
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }

  Future<String?> showPickerDialog(
      List<String> inputList, String? chosenItem) async {
    return await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) {
        return SizedBox(
          height: 250,
          child: ListView.separated(
            itemCount: inputList.length,
            padding: const EdgeInsets.only(top: 16),
            itemBuilder: (ctx, index) {
              return InkWell(
                onTap: () {
                  Navigator.pop(context, inputList[index]);
                },
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${index + 1}'),
                      Text(inputList[index]),
                      Icon(chosenItem == inputList[index]
                          ? Icons.check_box
                          : Icons.check_box_outline_blank)
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (ctx, index) {
              return const Divider(
                color: Colors.grey,
                thickness: 0.6,
                indent: 10,
                endIndent: 10,
              );
            },
          ),
        );
      },
    );
  }
}
