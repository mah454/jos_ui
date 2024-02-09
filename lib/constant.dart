import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Colors
const componentBackgroundColor = Color.fromRGBO(247, 247, 247, 1);
const dashboardMosaicBackgroundColor = Color.fromRGBO(80, 100, 80, 0.5);
final navigatorKey = GlobalKey<NavigatorState>();
final globalKey = GlobalKey();

Widget getModalHeader(String title) {
  return Container(
    width: double.infinity,
    height: 46,
    color: Colors.green,
    child: Padding(
      padding: const EdgeInsets.all(14.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
          IconButton(onPressed: () => Get.back(), padding: EdgeInsets.zero, splashRadius: 10, icon: Icon(Icons.close, size: 22, color: Colors.white))
        ],
      ),
    ),
  );
}
