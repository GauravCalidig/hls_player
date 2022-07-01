import 'package:flutter/material.dart';

import '../animted_play_pause.dart';

class SidePlayButton extends StatelessWidget {
  const SidePlayButton({
    Key? key,
    required this.backgroundColor,
    this.iconColor,
    required this.show,
    required this.isPlaying,
    required this.isFinished,
    this.onPressed,
  }) : super(key: key);

  final Color backgroundColor;
  final Color? iconColor;
  final bool show;
  final bool isPlaying;
  final bool isFinished;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton(
        iconSize: 32,
        icon: isFinished
            ? Icon(Icons.replay, color: iconColor)
            : AnimatedPlayPause(
                color: iconColor,
                playing: isPlaying,
              ),
        onPressed: onPressed,
      ),
    );
  }
}
