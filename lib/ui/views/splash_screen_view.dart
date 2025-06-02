import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/blocs/bloc_onboarding.dart';

import '../widgets/okane_page_builder.dart';

class SplashScreenView extends StatelessWidget {
  const SplashScreenView({required this.blocOnboarding, super.key});
  final BlocOnboarding blocOnboarding;

  @override
  Widget build(BuildContext context) {
    return OkanePageBuilder(
      page: Column(
        children: <Widget>[
          const SizedBox(
            height: 280.0,
          ),
          SizedBox(
            width: 196.92,
            height: 45.0,
            child: Image.asset('assets/logo.png'),
          ),
          const SizedBox(
            height: 16.0,
          ),
          SizedBox(
            width: double.infinity,
            child: StreamBuilder<String>(
              stream: blocOnboarding.msgStream,
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                return Text(
                  blocOnboarding.msg,
                  textAlign: TextAlign.center,
                );
              },
            ),
          ),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }
}
