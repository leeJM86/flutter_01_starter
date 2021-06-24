import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class _VideoScrubber2 extends StatefulWidget {
  _VideoScrubber2({
    this.child,
    this.controller,
  });

  final Widget child;
  final VideoPlayerController controller;

  @override
  _VideoScrubberState2 createState() => _VideoScrubberState2();
}

class _VideoScrubberState2 extends State<_VideoScrubber2> {
  bool _controllerWasPlaying = false;

  VideoPlayerController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    void seekToRelativePosition(Offset globalPosition) {
      final RenderBox box = context.findRenderObject() as RenderBox;
      final Offset tapPos = box.globalToLocal(globalPosition);
      final double relative = tapPos.dx / box.size.width;
      final Duration position = controller.value.duration * relative;
      controller.seekTo(position);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: widget.child,
      onHorizontalDragStart: (DragStartDetails details) {
        if (!controller.value.isInitialized) {
          return;
        }
        _controllerWasPlaying = controller.value.isPlaying;
        if (_controllerWasPlaying) {
          controller.pause();
        }
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        if (!controller.value.isInitialized) {
          return;
        }
        seekToRelativePosition(details.globalPosition);
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        if (_controllerWasPlaying) {
          controller.play();
        }
      },
      onTapDown: (TapDownDetails details) {
        if (!controller.value.isInitialized) {
          return;
        }
        seekToRelativePosition(details.globalPosition);
      },
    );
  }
}

class VideoProgressIndicator2 extends StatefulWidget {
  /// Construct an instance that displays the play/buffering status of the video
  /// controlled by [controller].
  ///
  /// Defaults will be used for everything except [controller] if they're not
  /// provided. [allowScrubbing] defaults to false, and [padding] will default
  /// to `top: 5.0`.
  VideoProgressIndicator2(
      this.controller, {
        this.colors = const VideoProgressColors(),
        this.allowScrubbing,
        this.padding = const EdgeInsets.only(top: 5.0),
        this.height = 4.0,
        this.radius = const BorderRadius.all(Radius.circular(2.0)),
      });

  /// The [VideoPlayerController] that actually associates a video with this
  /// widget.
  final VideoPlayerController controller;

  /// The default colors used throughout the indicator.
  ///
  /// See [VideoProgressColors] for default values.
  final VideoProgressColors colors;

  /// When true, the widget will detect touch input and try to seek the video
  /// accordingly. The widget ignores such input when false.
  ///
  /// Defaults to false.
  final bool allowScrubbing;

  /// This allows for visual padding around the progress indicator that can
  /// still detect gestures via [allowScrubbing].
  ///
  /// Defaults to `top: 5.0`.
  final EdgeInsets padding;

  final double height;
  final BorderRadius radius;

  @override
  _VideoProgressIndicatorState2 createState() => _VideoProgressIndicatorState2();
}

class _VideoProgressIndicatorState2 extends State<VideoProgressIndicator2> {
  _VideoProgressIndicatorState2() {
    listener = () {
      if (!mounted) {
        return;
      }
      setState(() {});
    };
  }

  VoidCallback listener;

  VideoPlayerController get controller => widget.controller;

  VideoProgressColors get colors => widget.colors;

  @override
  void initState() {
    super.initState();
    controller.addListener(listener);
  }

  @override
  void deactivate() {
    controller.removeListener(listener);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    Widget progressIndicator;
    if (controller.value.isInitialized) {
      final int duration = controller.value.duration.inMilliseconds;
      final int position = controller.value.position.inMilliseconds;

      int maxBuffering = 0;
      for (DurationRange range in controller.value.buffered) {
        final int end = range.end.inMilliseconds;
        if (end > maxBuffering) {
          maxBuffering = end;
        }
      }

      progressIndicator = Stack(
        fit: StackFit.passthrough,
        children: <Widget>[
          ClipRRect(
            borderRadius: widget.radius,
            child: LinearProgressIndicator(
              value: maxBuffering / duration,
              valueColor: AlwaysStoppedAnimation<Color>(colors.bufferedColor),
              backgroundColor: colors.backgroundColor,
              minHeight: widget.height,
            ),
          ),
          ClipRRect(
            borderRadius: widget.radius,
            child: LinearProgressIndicator(
              value: position / duration,
              valueColor: AlwaysStoppedAnimation<Color>(colors.playedColor),
              backgroundColor: Colors.transparent,
              minHeight: widget.height,
            ),
          ),


        ],
      );
    } else {
      progressIndicator = ClipRRect(
        borderRadius: widget.radius,
        child: LinearProgressIndicator(
          value: null,
          valueColor: AlwaysStoppedAnimation<Color>(colors.playedColor),
          backgroundColor: colors.backgroundColor,
          minHeight: widget.height,
        ),
      );
    }
    final Widget paddedProgressIndicator = Padding(
      padding: widget.padding,
      child: progressIndicator,
    );
    if (widget.allowScrubbing) {
      return _VideoScrubber2(
        child: paddedProgressIndicator,
        controller: controller,
      );

    } else {
      return paddedProgressIndicator;
    }
  }
}