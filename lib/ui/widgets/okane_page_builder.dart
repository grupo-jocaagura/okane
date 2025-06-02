import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/ui/pages/loading_page.dart';
import 'package:jocaaguraarchetype/ui/widgets/my_snack_bar_widget.dart';

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
          appBar: appManager.responsive.showAppbar
              ? AppBar(title: Text(appManager.navigator.title))
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
                child: MySnackBarWidget(
                  toastStream: appManager.blocUserNotifications.toastStream,
                  width: appManager.responsive.size.width,
                  gutterWidth: appManager.responsive.gutterWidth,
                  marginWidth: appManager.responsive.marginWidth,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
