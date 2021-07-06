import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'VideoProgressIndicator_ljm.dart';

bool _hitTest = true;
bool _hitTestHold = false;
bool _fullscreen = false;

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
    _hitTest = true;
    _hitTestHold = false;
    _fullscreen = false;

    _controller = VideoPlayerController.network('https://player.vimeo.com/external/491506029.hd.mp4?s=d6e509b47a07c2843b7f3cae4137bc8fafa748be&profile_id=174');

    _controller.addListener(() {
      setState(() {
      });
    });
    _controller.setLooping(false);
    _controller.initialize().then((value) => {
      setState(() {
        _hitTest = true;
        autohide.auto();
      })
    });
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
      appBar: !_fullscreen ? AppBar(
        title: Text("VideoPlayer"),
      ) : null,

      body: FractionallySizedBox(
        widthFactor: 1,
        heightFactor: 1,
        child: Container(
          color: Colors.black,
          child: Stack(
            children: [
              Center(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: FittedBox( // 동영상
                    fit: BoxFit.fill,
                    child: SizedBox(
                      width: _controller.value.isInitialized ? _controller.value.size.width : 100,
                      height: _controller.value.isInitialized ? _controller.value.size.height : 100,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                ),
              ),
              Center(
                child: _fullscreen ?
                Container(
                  child: _ControlsOverlay(controller: _controller, cntHPer: _contextHeightPercent, cntWPer: _contextWidthPercent),
                ) :
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: _ControlsOverlay(controller: _controller, cntHPer: _contextHeightPercent, cntWPer: _contextWidthPercent),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({Key key, this.controller, this.cntHPer, this.cntWPer, this.fadeDur1 = 200, this.fadeDur2 = 5000}) : super(key: key);

  final VideoPlayerController controller;
  final double cntHPer;
  final double cntWPer;

  final int fadeDur1;
  final int fadeDur2;

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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedOpacity( // 블랙스크린
          opacity: !controller.value.isPlaying ? 1 : 0,
          duration: Duration(milliseconds: fadeDur1),
          child: GestureDetector(
            child: Container(
              color: Colors.black.withOpacity(0.8),
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
        AnimatedOpacity( // 중앙 재생버튼
          opacity: !controller.value.isPlaying ? 1 : 0,
          duration: Duration(milliseconds: fadeDur1),
          child: Center(
            child: IconButton(
              iconSize: 30*cntWPer,
              alignment: Alignment.center,
              padding: EdgeInsets.all(0),
              icon: Icon(
                controller.value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white.withOpacity(0.8),
              ),
              onPressed: () {
                if(controller.value.isPlaying) {
                  controller.pause();
                }else{
                  controller.play();
                }
              },
            ),
          ),
        ),
        AnimatedOpacity(
          opacity: (_hitTest || !controller.value.isPlaying) ? 1 : 0,
          duration: Duration(milliseconds: fadeDur1),
          child: GestureDetector(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: PopupMenuButton<double>(
                    initialValue: controller.value.playbackSpeed,
                    tooltip: 'Playback speed',
                    onSelected: (speed) {
                      _hitTest = true;
                      autohide.auto();
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
                        vertical: 2*cntWPer,
                        horizontal: 2*cntWPer,
                      ),
                      child: Text('${controller.value.playbackSpeed}x'),
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  child: VideoProgressIndicator2(
                    controller,
                    padding: EdgeInsets.only(left: 3*cntWPer, right: 3*cntWPer, bottom: 4*cntWPer),
                    colors: VideoProgressColors(
                      bufferedColor: Colors.white.withAlpha(80),
                      playedColor: Colors.red,
                    ),
                    allowScrubbing: true,
                    height: 1*cntWPer,
                    radius: BorderRadius.all(Radius.circular(0.5*cntWPer)),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    icon: Icon(Icons.fullscreen_rounded),
                    color: Colors.white.withAlpha(80),
                    iconSize: 6*cntWPer,
                    padding: EdgeInsets.only(left: 3*cntWPer, right: 3*cntWPer, bottom: 8*cntWPer),
                    onPressed: () {
                      if(_fullscreen){
                        _fullscreen = false;
                      }else{
                        _fullscreen = true;
                      }
                      _hitTest = true;
                      autohide.auto();
                      controller.notifyListeners();
                    },
                  ),
                ),
              ],
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
    );
  }
}

class autohide {
  autohide();

  Timer _autoHideTimeout = Timer(Duration(milliseconds: 6000), (){
    _hitTest = false;
  });

  autohide.auto([int _duration = 6000]){
    _autoHideTimeout?.cancel();
    if(_hitTest && !_hitTestHold) {
      _autoHideTimeout = Timer(Duration(milliseconds: _duration), () {
        _hitTest = false;
      });
    }
  }

  autohide.show(){
    _autoHideTimeout?.cancel();
    _hitTest = true;
  }

  autohide.hide(){
    _autoHideTimeout?.cancel();
    _hitTest = false;
  }
}