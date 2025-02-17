import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jos_ui/component/card_content.dart';
import 'package:jos_ui/component/directory_path.dart';
import 'package:jos_ui/component/file_view.dart';
import 'package:jos_ui/constant.dart';
import 'package:jos_ui/controller/filesystem_controller.dart';
import 'package:jos_ui/model/filesystem_tree.dart';

class DirectoryTreePage extends StatefulWidget {
  const DirectoryTreePage({super.key});

  @override
  State<DirectoryTreePage> createState() => _DirectoryTreePageState();
}

class _DirectoryTreePageState extends State<DirectoryTreePage> {
  final _filesystemController = Get.put(FilesystemController());

  @override
  void initState() {
    if (_filesystemController.filesystemTree.value == null) WidgetsBinding.instance.addPostFrameCallback((_) => Get.offAllNamed(Routes.filesystem.path));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CardContent(
      child: Expanded(
        child: SizedBox(
          width: double.infinity,
          child: Obx(
            () => Column(
              spacing: 4,
              children: [
                if (hasDirectoryPath())
                  DirectoryPath(
                    path: _filesystemController.directoryPath.value,
                    onClick: (e) => enterFolder(e),
                  ),
                SizedBox(height: 2),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(border: Border.all(color: Colors.black12, width: 1)),
                    child: GridView.builder(
                      padding: EdgeInsets.all(8),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 150, // Maximum width of each item
                        mainAxisSpacing: 8, // Spacing between rows
                        crossAxisSpacing: 8,
                        childAspectRatio: 1, // Aspect ratio of items (width/height)
                      ),
                      itemCount: _filesystemController.filesystemTree.value!.childs!.length, // Add this line
                      itemBuilder: (BuildContext context, int index) {
                        var child = _filesystemController.filesystemTree.value!.childs![index];
                        return FileView(
                          filesystemTree: child,
                          onDoubleClick: child.isFile ? null : () => enterFolder(child.fullPath),
                          onSelect: () => selectItem(child),
                          onDeselect: () => deselectItem(child),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool hasDirectoryPath() => _filesystemController.directoryPath.isNotEmpty;

  void selectItem(FilesystemTree fst) => _filesystemController.selectedItems.add(fst.fullPath);

  void deselectItem(FilesystemTree fst) => _filesystemController.selectedItems.remove(fst.fullPath);

  bool isSelected(FilesystemTree fst) => _filesystemController.selectedItems.contains(fst.fullPath);

  void enterFolder(String fullPath) {
    _filesystemController.directoryPath.value = fullPath;
    _filesystemController.fetchFilesystemTree(fullPath);
    _filesystemController.selectedItems.clear();
  }

  @override
  void dispose() {
    _filesystemController.clear();
    super.dispose();
  }
}
