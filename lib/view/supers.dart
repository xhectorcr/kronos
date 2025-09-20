import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class FullScreenVideoPage extends StatefulWidget {
  final String videoUrl;

  const FullScreenVideoPage({Key? key, required this.videoUrl})
      : super(key: key);

  @override
  State<FullScreenVideoPage> createState() => _FullScreenVideoPageState();
}

class _FullScreenVideoPageState extends State<FullScreenVideoPage> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _setFullScreen();
  }

  void _initializeVideo() {
    // Puedes usar diferentes fuentes:
    // Para video desde internet:
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));

    // Para video desde assets:
    // _controller = VideoPlayerController.asset('assets/videos/mi_video.mp4');

    // Para video desde archivo local:
    // _controller = VideoPlayerController.file(File(widget.videoUrl));

    _controller.initialize().then((_) {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _controller.play();
      }
    }).catchError((error) {
      print('Error al inicializar el video: $error');
    });

    // Auto-ocultar controles después de 3 segundos
    _controller.addListener(() {
      if (_controller.value.isPlaying && _showControls) {
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted && _controller.value.isPlaying) {
            setState(() {
              _showControls = false;
            });
          }
        });
      }
    });
  }

  void _setFullScreen() {
    // Ocultar barra de estado y navegación
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    // Establecer orientación landscape (opcional)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _exitFullScreen() {
    // Restaurar UI del sistema
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // Restaurar orientación portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isInitialized
          ? Stack(
              children: [
                // Video que ocupa toda la pantalla
                SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: GestureDetector(
                        onTap: _toggleControls,
                        child: VideoPlayer(_controller),
                      ),
                    ),
                  ),
                ),

                // Controles de video (se muestran/ocultan)
                if (_showControls) ...[
                  // Botón de cerrar (esquina superior izquierda)
                  Positioned(
                    top: 40,
                    left: 20,
                    child: SafeArea(
                      child: IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: () {
                          _exitFullScreen();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),

                  // Controles centrales
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          iconSize: 50,
                          color: Colors.white,
                          icon: const Icon(Icons.replay_10),
                          onPressed: () {
                            final currentPosition = _controller.value.position;
                            final newPosition =
                                currentPosition - const Duration(seconds: 10);
                            _controller.seekTo(
                              newPosition >= Duration.zero
                                  ? newPosition
                                  : Duration.zero,
                            );
                          },
                        ),
                        IconButton(
                          iconSize: 70,
                          color: Colors.white,
                          icon: Icon(
                            _controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                          ),
                          onPressed: _togglePlayPause,
                        ),
                        IconButton(
                          iconSize: 50,
                          color: Colors.white,
                          icon: const Icon(Icons.forward_10),
                          onPressed: () {
                            final currentPosition = _controller.value.position;
                            final newPosition =
                                currentPosition + const Duration(seconds: 10);
                            final duration = _controller.value.duration;
                            _controller.seekTo(
                              newPosition <= duration ? newPosition : duration,
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Barra de progreso (parte inferior)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Slider de progreso
                          VideoProgressIndicator(
                            _controller,
                            allowScrubbing: true,
                            colors: const VideoProgressColors(
                              playedColor: Colors.red,
                              bufferedColor: Colors.grey,
                              backgroundColor: Colors.black26,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Tiempo actual / tiempo total
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(_controller.value.position),
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                _formatDuration(_controller.value.duration),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            )
          : const Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }

  @override
  void dispose() {
    _exitFullScreen();
    _controller.dispose();
    super.dispose();
  }
}

// Ejemplo de uso:
class VideoPlayerExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Player')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FullScreenVideoPage(
                  videoUrl:
                      '/views/videos/kronos-heroes-dead.mp4', // Cambia esto por la URL o ruta de tu video
                ),
              ),
            );
          },
          child: const Text('Ver Video en Pantalla Completa'),
        ),
      ),
    );
  }
}
