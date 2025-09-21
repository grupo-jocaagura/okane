import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import '../../config.dart';
import 'projector_widget.dart';

class OkanePageBuilder extends StatelessWidget {
  const OkanePageBuilder({required this.page, super.key});
  final Widget page;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: appManager.loading.loadingMsgStream,
      builder: (_, __) {
        final bool isLoading = appManager.loading.loadingMsg.isNotEmpty;
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: appManager.responsive.showAppbar
              ? AppBar(title: Text(appManager.pageManager.currentTitle))
              : null,
          body: Stack(
            children: <Widget>[
              if (isLoading)
                LoadingPage(msg: appManager.loading.loadingMsg)
              else
                ProjectorWidget(child: page),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: MySnackBarWidget.fromStringStream(
                  responsive: context.appManager.responsive,
                  toastStream: context.appManager.notifications.textStream,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
