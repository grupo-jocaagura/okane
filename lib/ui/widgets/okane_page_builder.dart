import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

import '../../config.dart';
import 'projector_widget.dart';
import 'wavy_header_widget.dart';

class OkanePageBuilder extends StatelessWidget {
  const OkanePageBuilder({
    required this.page,
    this.showWavyHeader = true,
    super.key,
  });
  final Widget page;
  final bool showWavyHeader;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: appManager.loading.loadingMsgStream,
      builder: (_, __) {
        final bool isLoading = appManager.loading.loadingMsg.isNotEmpty;
        return SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: Text(appManager.pageManager.currentTitle),
              backgroundColor: Colors.transparent,
            ),
            body: Stack(
              children: <Widget>[
                if (showWavyHeader) const WavyHeaderWidget(),
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
          ),
        );
      },
    );
  }
}
