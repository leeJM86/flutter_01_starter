class FullScreenController {
  bool fullscreenEnalbed = false;

  FullScreenController();

  FullScreenController.fullscreen(){
    fullscreenEnalbed = true;
  }

  FullScreenController.exitFullscreen(){
    fullscreenEnalbed = false;
  }
}