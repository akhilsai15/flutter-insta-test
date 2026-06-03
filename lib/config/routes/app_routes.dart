import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instagram/core/utility/constant.dart';
import 'package:instagram/presentation/screens/web_screen_layout.dart';

/// currently, I don't use routes methods because there is a lot of run time errors.
/// I use normal Navigator because i don't know how to make Get.to without root.
class Go {
  final BuildContext context;
  Go(this.context);

  Future push({
    required Widget page,
    bool withoutRoot = true,
    bool withoutPageTransition = false,
  }) async {
    if (isThatMobile) {
      PageRoute route = withoutPageTransition
          ? MaterialPageRoute(
              builder: (context) => page, maintainState: !withoutRoot)
          : CupertinoPageRoute(
              builder: (context) => page, maintainState: !withoutRoot);
      return Navigator.of(context, rootNavigator: withoutRoot).push(route);
    } else {
      return Get.to(WebScreenLayout(body: page),
          transition: Transition.noTransition,
          duration: const Duration(milliseconds: 0));
    }
  }

  // FIND THE OLD back() METHOD AND REPLACE IT WITH THIS:
  Future<bool> back() async {
    if (isThatMobile) {
      return Navigator.maybePop(context);
    } else {
      Get.back(); // Dismisses GetX stacked layout views correctly on Web
      return true;
    }
  }
}
