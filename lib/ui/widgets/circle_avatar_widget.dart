import 'package:flutter/material.dart';

class CircleAvatarWidget extends StatelessWidget {
  const CircleAvatarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 55.0,
      backgroundColor: Theme.of(context).primaryColor,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(55),
        child: Icon(
          Icons.person_4_outlined,
          color: Theme.of(context).colorScheme.inversePrimary,
          size: 100,
        ),
      ),
    );
  }
}
