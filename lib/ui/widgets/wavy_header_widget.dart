import 'dart:math' as math;

import 'package:flutter/material.dart';

class WavyHeaderWidget extends StatelessWidget {
  const WavyHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none, // permite que se vea lo que se salga
        children: <Widget>[
          Positioned(
            // ajusta estas coordenadas a tu gusto
            top: -375,
            right: -70,
            child: Transform.rotate(
              angle: math.pi / 2.5,
              child: Container(
                width: 600,
                height: 600,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
