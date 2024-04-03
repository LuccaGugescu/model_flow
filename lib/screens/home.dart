import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:models_manager/models_manager.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FileManager fm = FileManager();
  List<ModelObject> files = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fm.loadListFromFile().then(((val) => setState(() {
          files = val;
        })));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Container(
        key: const Key("add_model_button"),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color:
              Colors.black, // Change this color to the desired background color
        ),
        child: IconButton(
          color: Colors.white,
          icon: const Icon(
            Icons.add,
          ),
          onPressed: () => fm.pick3dModel(context).then((value) => setState(() {
                files = value;
              })),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: SizedBox(
                height: 146,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome to ModelFlow",
                        style: TextStyle(
                            fontSize: 26, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 5),
                      Text("Explore 3D Models"),
                      SizedBox(height: 10),
                      Divider(
                        color: Colors.grey,
                        thickness: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  crossAxisCount: 2,
                ),
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return _buildModelContainer(files[index], context);
                  },
                  childCount: files.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelContainer(ModelObject modelObject, BuildContext context) {
    final extension = modelObject.name.split(".")[1];
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 1,
          child: InkWell(
            onTap: () => Navigator.of(context)
                .pushNamed("/model_preview", arguments: modelObject.src),
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      gradient: LinearGradient(
                          colors: getBackgroundBasedOnExtension(extension))),
                  child: Center(
                    child: Text(
                      extension,
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
                Positioned(
                  right: 1,
                  top: 1,
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateColor.resolveWith(
                            (states) => Colors.red)),
                    onPressed: () => fm
                        .deleteModelObject(modelObject.name)
                        .then((value) => setState(() {
                              files = value;
                            })),
                    child: Container(
                        child: Icon(
                      Icons.delete,
                      color: Colors.white,
                    )),
                  ),
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          modelObject.name,
        )
      ],
    );
  }

  List<Color> getBackgroundBasedOnExtension(String extension) {
    switch (extension) {
      case "glb":
        return [Colors.black54, Colors.black87];
      case "gltf":
        return [Colors.red, Colors.redAccent];
      case "fbx":
        return [Colors.green, Colors.greenAccent];
      case "obj":
        return [Colors.blue, Colors.blueAccent];
      default:
        return [Colors.black54, Colors.black87];
    }
  }
}
