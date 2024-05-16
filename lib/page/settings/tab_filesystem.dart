import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jos_ui/controller/filesystem_controller.dart';
import 'package:jos_ui/dialog/filesystem_dialog.dart';
import 'package:jos_ui/model/filesystem.dart';
import 'package:jos_ui/widget/bar_chart.dart';
import 'package:jos_ui/widget/char_button.dart';

class TabFilesystem extends StatefulWidget {
  const TabFilesystem({super.key});

  @override
  State<TabFilesystem> createState() => _TabFilesystemState();
}

class _TabFilesystemState extends State<TabFilesystem> {
  final _filesystemController = Get.put(FilesystemController());

  @override
  void initState() {
    _filesystemController.fetchPartitions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Obx(
        () => Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: filesystemWidgets(),
        ),
      ),
    );
  }

  List<Widget> filesystemWidgets() {
    var list = <Widget>[];
    var filesystems = _filesystemController.partitions;
    for (var fs in filesystems) {
      int used = fs.free != null ? fs.total - (fs.free as int) : 0;
      list.add(
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            children: [
              Expanded(
                child: BarChart(
                  total: fs.total,
                  current: fs.type == 'LVM2_member' ? fs.total : used,
                  text: getPartitionText(fs),
                  warn: fs.type == 'LVM2_member' ? Colors.grey : Colors.red,
                  textStyle: TextStyle(fontSize: 12),
                  onClick: canUsePartition(fs) ? null : () => fetchTreeAndDisplay(fs),
                  disabled: canUsePartition(fs),
                ),
              ),
              SizedBox(width: 8),
              CharButton(
                width: 70,
                height: 30,
                char: getButtonName(fs),
                textStyle: getButtonTextStyle(fs),
                onPressed: fs.type == 'LVM2_member' || fs.type.isEmpty || fs.mountPoint == '/' ? null : () => actionButton(fs),
              ),
            ],
          ),
        ),
      );
    }

    return list;
  }

  bool canUsePartition(HDDPartition fs) => fs.type == 'swap' || fs.mountPoint!.isEmpty || fs.type == 'LVM2_member' || fs.type.isEmpty;

  void actionButton(HDDPartition partition) {
    if (partition.type == 'swap') {
      partition.total == 0 ? _filesystemController.swapOn(partition) : _filesystemController.swapOff(partition);
    } else if (partition.mountPoint == null || partition.mountPoint!.isEmpty) {
      _filesystemController.clear();
      _filesystemController.partitionEditingController.text = partition.partition;
      _filesystemController.filesystemTypeEditingController.text = partition.type;
      displayMountFilesystemModal();
    } else {
      _filesystemController.umount(partition);
    }
  }

  String getPartitionText(HDDPartition fs) {
    if (fs.type == 'LVM2_member') {
      return '${fs.partition} -> [ LVM ]   ';
    } else if (fs.type == 'swap') {
      return '${fs.partition} -> [ SWAP ]   ';
    } else {
      return '${fs.partition} -> [ ${fs.mountPoint ?? ''} ]   ';
    }
  }

  TextStyle getButtonTextStyle(HDDPartition partition) {
    if (partition.type == 'swap') {
      return TextStyle(
        fontSize: 11,
        color: Colors.black,
        fontWeight: partition.total != 0 ? FontWeight.normal : FontWeight.bold,
      );
    } else {
      return TextStyle(
        fontSize: 11,
        color: Colors.black,
        fontWeight: (partition.mountPoint == null || partition.mountPoint!.isEmpty) ? FontWeight.bold : FontWeight.normal,
      );
    }
  }

  String getButtonName(HDDPartition fs) {
    if (fs.type == 'swap') {
      return fs.total == 0 ? 'swap on' : 'swap off';
    } else if (fs.type == 'LVM2_member' || fs.type.isEmpty || fs.mountPoint == '/') {
      return ' - ';
    } else {
      return (fs.mountPoint == null || fs.mountPoint!.isEmpty) ? 'Mount' : 'Disconnect';
    }
  }

  fetchTreeAndDisplay(HDDPartition partition) {
    _filesystemController.fetchFilesystemTree(partition.mountPoint!).then((value) => displayFilesystemTree(true,false));
  }
}
