import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:video_player/video_player.dart';
import 'VideoProgressIndicator_ljm.dart';

bool _hitTest = true;
bool _hitTestHold = false;
bool _fullscreen = false;
bool _rewindHitTest = false;
bool _forwardHitTest = false;
Icon _playAndPauseIcon = Icon(Icons.play_arrow_rounded);
Icon _volIcon = Icon(Icons.volume_up_rounded);

double _getVolume = 0;
double _muteVolume = 0;
double _testVolume = 0;

Timer _autoHideTimeout = Timer(Duration(milliseconds: 6000), (){
  _hitTest = false;
});

class videoPage extends StatefulWidget {
  @override
  State <StatefulWidget> createState() {
    return _videoPage();
  }
}

class _videoPage extends State<videoPage>{
  double _cntSPer = 100;
  double _cntLPer= 100;

  VideoPlayerController _controller;
  VolumeController _volController = new VolumeController();

  @override
  void initState() {
    super.initState();
    _hitTest = true;
    _hitTestHold = false;
    _fullscreen = false;

    _volController.listener((volume) {
      _hitTest = true;
      autohide.auto();
      _getVolume = volume;
      print("Testset");
      _controller.notifyListeners();
    });

    _controller = VideoPlayerController.network('https://player.vimeo.com/external/491506029.hd.mp4?s=d6e509b47a07c2843b7f3cae4137bc8fafa748be&profile_id=174');

    _controller.setLooping(false);
    _controller.setVolume(1);

    _controller.addListener(() {
      int _videoPosition = _controller.value.position.inMilliseconds;
      int _videoDuration = _controller.value.duration.inMilliseconds;

      setState(() {
        if(_videoDuration < 1){
          _playAndPauseIcon = Icon(Icons.more_horiz_rounded);
        }else if((_videoPosition < _videoDuration) && _controller.value.isPlaying){
          _playAndPauseIcon = Icon(Icons.pause_rounded);
        }else if((_videoPosition < _videoDuration) && !_controller.value.isPlaying){
          _playAndPauseIcon = Icon(Icons.play_arrow_rounded);
        }else if((_videoPosition == _videoDuration) && !_controller.value.isPlaying){
          _playAndPauseIcon = Icon(Icons.replay_rounded);
        }else if((_videoPosition == _videoDuration) && _controller.value.isPlaying){
          _controller.seekTo(Duration(milliseconds: 0));
        }

        if(_getVolume > 0.5){
          _volIcon = Icon(Icons.volume_up_rounded);
        }else if(_getVolume <= 0.5 && _getVolume > 0){
          _volIcon = Icon(Icons.volume_down_rounded);
        }else if(_getVolume == 0){
          _volIcon = Icon(Icons.volume_off_rounded);
        }else{
          _volIcon = Icon(Icons.error);
        }
      });
    });

    _controller.initialize().then((value) => {
      setState(() {
        _hitTest = true;
        autohide.auto();
        _controller.play();
      })
    });

  }

  @override
  void dispose() {
    _controller.dispose();
    _volController.removeListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _cntSPer = MediaQuery.of(context).size.shortestSide / 100;
    _cntLPer = MediaQuery.of(context).size.longestSide / 100;

    final double _statusBarHeight = MediaQuery.of(context).padding.top;

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
                  child: _ControlsOverlay(controller: _controller, volController: _volController, cntSPer: _cntSPer, cntLPer: _cntLPer, staHeight: _statusBarHeight+(3*_cntLPer),),
                ) :
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: _ControlsOverlay(controller: _controller, volController: _volController, cntSPer: _cntSPer, cntLPer: _cntLPer,),
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
  const _ControlsOverlay({Key key, this.controller, this.volController, this.cntSPer, this.cntLPer, this.staHeight = 0, this.fadeDur1 = 200, this.fadeDur2 = 10000}) : super(key: key);

  final VideoPlayerController controller;
  final VolumeController volController;
  final double cntSPer;
  final double cntLPer;
  final double staHeight;

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
              iconSize: 30*cntSPer,
              alignment: Alignment.center,
              padding: EdgeInsets.all(0),
              color: Colors.white.withOpacity(0.8),
              icon: _playAndPauseIcon,
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
          opacity: _rewindHitTest ? 1 : 0,
          duration: Duration(milliseconds: 200),
          curve: doublePingPongCurve(visibled: _rewindHitTest),
          child: GestureDetector(
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: 0.25,
                heightFactor: 1,
                child: GestureDetector(
                  child: Container(
                    child: Icon(
                      Icons.fast_rewind_rounded,
                      color: Colors.white.withOpacity(0.8),
                      size: 15*cntSPer,
                    ),
                    color: Colors.white.withOpacity(0.2),
                  ),
                  onDoubleTap: () {
                    _rewindHitTest = true;
                    controller.seekTo(Duration(seconds: (controller.value.position.inSeconds - 10)));
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
          onEnd: () {
            _rewindHitTest = false;
            controller.notifyListeners();
          },
        ),
        AnimatedOpacity(
          opacity: _forwardHitTest ? 1 : 0,
          duration: Duration(milliseconds: 200),
          curve: doublePingPongCurve(visibled: _forwardHitTest),
          child: GestureDetector(
            child: Align(
              alignment: Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: 0.25,
                heightFactor: 1,
                child: GestureDetector(
                  child: Container(
                    child: Icon(
                      Icons.fast_forward_rounded,
                      color: Colors.white.withOpacity(0.8),
                      size: 15*cntSPer,
                    ),
                    color: Colors.white.withOpacity(0.2),
                  ),
                  onDoubleTap: () {
                    _forwardHitTest = true;
                    controller.seekTo(Duration(seconds: (controller.value.position.inSeconds + 10)));
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
          onEnd: () {
            _forwardHitTest = false;
            controller.notifyListeners();
          },
        ),
        AnimatedOpacity(
          opacity: (_hitTest || !controller.value.isPlaying) ? 1 : 0,
          duration: Duration(milliseconds: fadeDur1),
          child: GestureDetector(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 4*cntLPer),
                    child: IconButton(
                      icon: Icon(Icons.fullscreen_rounded),
                      color: Colors.white.withAlpha(90),
                      iconSize: 6*cntSPer,
                      alignment: Alignment.center,
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
                ), //풀스크린
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 4*cntLPer),
                    child: IconButton(
                      color: Colors.white.withAlpha(90),
                      iconSize: 6*cntSPer,
                      alignment: Alignment.center,
                      icon: _playAndPauseIcon,
                      onPressed: () {
                        _hitTest = true;
                        autohide.auto();
                        if(controller.value.isPlaying) {
                          controller.pause();
                        }else{
                          controller.play();
                        }
                      },
                    ),
                  ),
                ), // 재생버튼
                SizedBox(
                  height: 6*cntLPer + staHeight,
                  width: 30*cntSPer,
                  child: Padding(
                    padding: EdgeInsets.only(top: staHeight,),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: EdgeInsets.zero,
                            child: IconButton(
                              color: Colors.white.withAlpha(90),
                              iconSize: 6*cntSPer,
                              alignment: Alignment.center,
                              icon: _volIcon,
                              onPressed: () {
                                if(_getVolume > 0) {
                                  _muteVolume = _getVolume;
                                  volController.muteVolume();
                                }else{
                                  if(_muteVolume == 0){_muteVolume = 0.3;}
                                  volController.setVolume(_muteVolume);
                                }
                              },
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: 14*cntSPer, top: (6*cntLPer-1.5*cntSPer)/2,),
                            child: SliderTheme(
                              data: SliderThemeData(
                                trackShape: CustomTrackShape(width: 26*cntSPer,height: 1.5*cntSPer,),
                                thumbColor: Colors.red,
                                activeTrackColor: Colors.red,
                                inactiveTrackColor: Colors.white.withOpacity(0.5),
                                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 1.5*cntSPer),
                              ),
                              child: Slider(
                                value: _getVolume*100,
                                min: 0,
                                max: 100,
                                onChanged: (value) {
                                  volController.setVolume(value/100);
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),// 볼륨
                Container(
                  alignment: Alignment.bottomCenter,
                  child: VideoProgressIndicator2(
                    controller,
                    padding: EdgeInsets.only(left: 3*cntSPer, right: 3*cntSPer, bottom: 3*cntLPer),
                    colors: VideoProgressColors(
                      bufferedColor: Colors.white.withAlpha(80),
                      playedColor: Colors.red,
                    ),
                    allowScrubbing: true,
                    height: 1*cntSPer,
                    radius: BorderRadius.all(Radius.circular(0.5*cntSPer)),
                  ),
                ), // 중앙 재생버튼
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

class doublePingPongCurve extends Curve {
  final double count;
  final bool visibled;

  doublePingPongCurve({this.count = 1, this.visibled});

  @override
  double transformInternal(double t){
    double val = tan(t*pi)+1;
    if(!visibled){ val = 0.0; }
    if(val > 1){ val=1;}
    return val;
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  const CustomTrackShape({Key key, this.width, this.height,});

  final double width;
  final double height;

  Rect getPreferredRect({
    @required RenderBox parentBox,
    Offset offset = Offset.zero,
    @required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = height;
    final double trackLeft = offset.dx;
    final double trackTop = offset.dy;
    final double trackWidth = width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}

