import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'VideoProgressIndicator_ljm.dart';

bool _hitTest = true;
bool _hitTestHold = false;



class autohide {
  Timer _autoHideTimeout = Timer(Duration(milliseconds: 6000), (){
    _hitTest = false;
  });

  autohide();

  autohide.auto(){
    print("autohide : ${_hitTest}, ${_hitTestHold}");
    _autoHideTimeout.cancel();
    if(_hitTest && !_hitTestHold) {
      _autoHideTimeout = Timer(Duration(milliseconds: 6000), () {
        _hitTest = false;
      });
    }
  }

  autohide.show(){
    _autoHideTimeout.cancel();
    _hitTest = true;
  }

  autohide.hide(){
    _autoHideTimeout.cancel();
    _hitTest = false;
  }
}

class videoPage extends StatefulWidget {
  @override
  State <StatefulWidget> createState() {
    return _videoPage();
  }
}

class _videoPage extends State<videoPage>{
  double _contextHeightPercent = 100;
  double _contextWidthPercent = 100;

  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network('https://player.vimeo.com/external/491506029.hd.mp4?s=d6e509b47a07c2843b7f3cae4137bc8fafa748be&profile_id=174');

    _controller.addListener(() {
      setState(() {  });
    });
    _controller.setLooping(false);
    _controller.initialize().then((_) => setState(() {}));
    _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _contextHeightPercent = MediaQuery.of(context).size.height / 100;
    _contextWidthPercent = MediaQuery.of(context).size.width / 100;

    return Scaffold(
      appBar: AppBar(
        title: Text("VideoPlayer"),
      ),

      body: Center(
        child: AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              FittedBox(
                fit: BoxFit.fill,
                child: SizedBox(
                  width: _controller.value.isInitialized ? _controller.value.size.width : 100,
                  height: _controller.value.isInitialized ? _controller.value.size.height : 100,
                  child: VideoPlayer(_controller),
                ),
              ),
              _ControlsOverlay(controller: _controller, cntHPer: _contextHeightPercent, cntWPer: _contextWidthPercent),
            ],
          )
        ),
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({Key key, this.controller, this.cntHPer, this.cntWPer}) : super(key: key);

  static const _examplePlaybackRates = [
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];

  final VideoPlayerController controller;
  final double cntHPer;
  final double cntWPer;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedOpacity( // 블랙스크린
          opacity: !controller.value.isPlaying ? 1 : 0,
          duration: Duration(milliseconds: 200),
        ),
        AnimatedOpacity(
          opacity: !controller.value.isPlaying ? 1 : 0,
          duration: Duration(milliseconds: 200),
          child: GestureDetector(
            child: Container(
              color: Colors.black.withOpacity(0.8),
              child: Center(
                child: IconButton(
                  iconSize: 30*cntWPer,
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(0),
                  icon: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  onPressed: () {
                    controller.value.isPlaying ? controller.pause() : controller.play();
                  },
                ),
              ),
            ),
            onTapDown: (details) {
              _hitTest = _hitTestHold = true;
              autohide.auto();
            },
            onTapUp: (details) {
              _hitTestHold = false;
              autohide.auto();
            },
            onTapCancel: () {
              _hitTestHold = false;
              autohide.auto();
            },
          ),
        ),
        AnimatedOpacity(
          opacity: (_hitTest || !controller.value.isPlaying) ? 1 : 0,
          duration: Duration(milliseconds: 500),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  child: PopupMenuButton<double>(
                    initialValue: controller.value.playbackSpeed,
                    tooltip: 'Playback speed',
                    onSelected: (speed) {
                      controller.setPlaybackSpeed(speed);
                    },
                    itemBuilder: (context) {
                      return [
                        for (final speed in _examplePlaybackRates)
                          PopupMenuItem(
                            value: speed,
                            child: Text('${speed}x'),
                          )
                      ];
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        // Using less vertical padding as the text is also longer
                        // horizontally, so it feels like it would need more spacing
                        // horizontally (matching the aspect ratio of the video).
                        vertical: 2*cntWPer,
                        horizontal: 2*cntWPer,
                      ),
                      child: Text('${controller.value.playbackSpeed}x'),
                    ),
                  ),
                  onLongPress: (){

                  },
                  onTapDown: (details) {
                    _hitTest = _hitTestHold = true;
                    autohide.auto();
                  },
                  onTapUp: (details) {
                    _hitTestHold = false;
                    autohide.auto();
                  },
                  onTapCancel: () {
                    _hitTestHold = false;
                    autohide.auto();
                  },
                ),
              ),
              Container(
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  child: VideoProgressIndicator2(
                    controller,
                    padding: EdgeInsets.only(left: 3*cntWPer, right: 3*cntWPer, bottom: 2.2*cntWPer),
                    colors: VideoProgressColors(
                      bufferedColor: Colors.white.withAlpha(80),
                      playedColor: Colors.red,
                    ),
                    allowScrubbing: true,
                    height: 2*cntWPer,
                    radius: BorderRadius.all(Radius.circular(1*cntWPer)),
                  ),
                  onTapDown: (details) {
                    _hitTest = _hitTestHold = true;
                    autohide.auto();
                  },
                  onTapUp: (details) {
                    _hitTestHold = false;
                    autohide.auto();
                  },
                  onTapCancel: () {
                    _hitTestHold = false;
                    autohide.auto();
                  },
                ),
              ),
            ],
          ),
        ),


      ],
    );
  }
}