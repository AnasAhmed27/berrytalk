import 'dart:async';
import 'dart:math';

import 'package:berrytalks/Widgets_Component/Utils/AppImages.dart';
import 'package:berrytalks/Widgets_Component/Utils/AppThemeUtilities.dart';
import 'package:berrytalks/Widgets_Component/Utils/MediaUrlResolver.dart';
import 'package:berrytalks/screens/Chat_screen/bloc/chat_screen_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';

class AudioBubbleContent extends StatefulWidget {
  final String filePath;
  final bool isMe;
  final Color contentColor;
  final int currentMessageIndex;
  final List<dynamic> allMessagesList;
  final bool isPlaying;
  final VoidCallback onTogglePlayback;
 final VoidCallback? onPlaybackCompleted;
 final Function(int nextListIndex, String nextPath)? onRequestNextAudio;
  final Function(String playbackKey, Duration targetDuration)? onSeekRequested;

  const AudioBubbleContent({
    super.key,
    required this.filePath,
    required this.isMe,
    required this.contentColor,
    required this.currentMessageIndex,
    required this.allMessagesList,
    required this.isPlaying, 
    required this.onTogglePlayback,
    this.onPlaybackCompleted,
    this.onRequestNextAudio,
    this.onSeekRequested,
  });

  @override
  State<AudioBubbleContent> createState() => _AudioBubbleContentState();
}

class _AudioBubbleContentState extends State<AudioBubbleContent>
    with AutomaticKeepAliveClientMixin {
  static AudioPlayer? _currentlyPlayingPlayer;
  /// Bumped whenever the user pauses / switches notes — cancels in-flight chain.
  static int _playbackGeneration = 0;

  String get _playbackKey =>
      '${widget.currentMessageIndex}::${widget.filePath}';

  late AudioPlayer _audioPlayer;
  List<double> _waveformSamples = [];
  final int _totalBars = 55;

  late ValueNotifier<double> _progressFractionNotifier;
  late ValueNotifier<Duration> _displayTimeNotifier;
  static final ValueNotifier<double> _speedNotifier = ValueNotifier<double>(1.0);
  bool _isUserDragging = false;
  bool _sourceLoaded = false;
  bool _isLoadingSource = false;
  bool _autoStartScheduled = false;
  /// Natural completion may chain; pause / switch must not.
  bool _shouldAutoPlayNext = false;
  /// Prevents toggle + BlocBuilder both calling play() for the same start.
  bool _startingLocally = false;

  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<PlayerState>? _playerStateSub;

  static final Map<String, Duration> _durationCache = {};

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _progressFractionNotifier = ValueNotifier<double>(0.0);
    final cachedDuration = _durationCache[widget.filePath];
    _displayTimeNotifier = ValueNotifier<Duration>(
      cachedDuration ?? Duration.zero,
    );
    _generateDynamicWaveform();
    _attachPlayerListeners();
    _ensureSourceLoaded();
  }

  void _generateDynamicWaveform() {
    final random = Random(widget.filePath.hashCode);
    _waveformSamples = List.generate(_totalBars, (index) {
      return 6.0 + random.nextInt(20).toDouble();
    });
  }

  void _attachPlayerListeners() {
    _durationSub = _audioPlayer.durationStream.listen((duration) {
      if (duration != null && mounted) {
        _durationCache[widget.filePath] = duration;
        if (!_audioPlayer.playing && !_isUserDragging) {
          _displayTimeNotifier.value = duration;
        }
       
      }
    });

    _positionSub = _audioPlayer.positionStream.listen((position) {
      if (!mounted || _isUserDragging) return;
      final duration = _audioPlayer.duration ?? Duration.zero;
      if (duration.inMilliseconds <= 0) return;

      final fraction = position.inMilliseconds / duration.inMilliseconds;
      _progressFractionNotifier.value = fraction.clamp(0.0, 1.0);
      if (_audioPlayer.playing) {
        _displayTimeNotifier.value = position;
      }
     
    });

    _playerStateSub = _audioPlayer.playerStateStream.listen((state) async {
      if ((state.processingState == ProcessingState.ready ||
              state.processingState == ProcessingState.buffering) &&
          !_audioPlayer.playing &&
          !_isUserDragging) {
        final totalDuration = _audioPlayer.duration;
        if (totalDuration != null && mounted) {
          _displayTimeNotifier.value = totalDuration;
        }
      }

      if (state.processingState != ProcessingState.completed) return;

      final chainNext = _shouldAutoPlayNext;
      _shouldAutoPlayNext = false;
      _startingLocally = false;

    
     if (mounted && widget.onPlaybackCompleted != null) {
    widget.onPlaybackCompleted!(); 
  }

      if (_currentlyPlayingPlayer == _audioPlayer) {
        _currentlyPlayingPlayer = null;
      }

      try {
        await _audioPlayer.seek(Duration.zero);
        await _audioPlayer.pause();
      } catch (_) {}

      if (mounted) {
        _progressFractionNotifier.value = 0.0;
        _displayTimeNotifier.value = _audioPlayer.duration ?? Duration.zero;
      }

      if (chainNext) {
        await _playNextVoiceNoteIfAvailable();
      }
    });
  }

  Future<bool> _ensureSourceLoaded() async {
    if (_sourceLoaded) return true;
    if (widget.filePath.isEmpty) return false;

    while (_isLoadingSource) {
      await Future.delayed(const Duration(milliseconds: 40));
      if (_sourceLoaded) return true;
      if (!mounted) return false;
    }

    _isLoadingSource = true;
    try {
      final source =
          MediaUrlResolver.resolve(widget.filePath) ?? widget.filePath;
      if (MediaUrlResolver.isNetworkUrl(source)) {
        await _audioPlayer.setUrl(source);
      } else {
        await _audioPlayer.setFilePath(source);
      }
      _sourceLoaded = true;
      final duration = _audioPlayer.duration;
      if (duration != null && mounted && !_audioPlayer.playing) {
        _displayTimeNotifier.value = duration;
        _durationCache[widget.filePath] = duration;
      }
      return true;
    } catch (e) {
      debugPrint('Audio init error: $e');
      return false;
    } finally {
      _isLoadingSource = false;
    }
  }


 bool _isAudioMessage(dynamic message) {
    if (message == null) return false;
    String type = '';
    try {
      type = (message.messageType ?? message.type ?? '').toString().toLowerCase().trim();
    } catch (_) {
      try {
        type = (message.type ?? '').toString().toLowerCase().trim();
      } catch (_) {}
    }

    String path = '';
    try {
      path = (message.filePath ?? '').toString().toLowerCase();
    } catch (_) {}

    final pathNoQuery = path.split('?').first;
    if (type == 'audio') return true;
    if (type == 'text' || type == 'string' || type == 'image') return false;

    return pathNoQuery.contains('.ogg') ||
        pathNoQuery.contains('.m4a') ||
        pathNoQuery.contains('.mp3') ||
        pathNoQuery.contains('.wav') ||
        pathNoQuery.contains('.aac') ||
        pathNoQuery.contains('audioclip');
  }

  Future<void> _playTransitionBeep() async {
    final beep = AudioPlayer();
    try {
      await beep.setAsset(AppSounds.transitionBeep);
      final done = Completer<void>();
      late final StreamSubscription sub;
      sub = beep.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed &&
            !done.isCompleted) {
          done.complete();
        }
      });
      await beep.play();
      await done.future.timeout(
        const Duration(seconds: 1),
        onTimeout: () {},
      );
      await sub.cancel();
    } catch (e) {
      debugPrint('Transition beep error: $e');
    } finally {
      await beep.dispose();
    }
  }

  /// Chain only when the *immediate* next message is also a voice note.
  /// Text / image / anything else stops the sequence (no skipping).  
  Future<void> _playNextVoiceNoteIfAvailable() async {
    final generation = _playbackGeneration;
    final messages = widget.allMessagesList;
    if (messages.isEmpty || !mounted) return;

    final currentChrono = messages.length - 1 - widget.currentMessageIndex;
    final nextChrono = currentChrono + 1;
    if (nextChrono < 0 || nextChrono >= messages.length) return;

    final nextMessage = messages[nextChrono];
    if (!_isAudioMessage(nextMessage)) return;

    final nextPath = nextMessage.filePath?.toString() ?? '';
    if (nextPath.isEmpty) return;

    final nextListIndex = messages.length - 1 - nextChrono;

    await _playTransitionBeep();

    if (!mounted || generation != _playbackGeneration) return;

    if (widget.onRequestNextAudio != null) {
      widget.onRequestNextAudio!(nextListIndex, nextPath);
    }
  }

  void _cancelChain() {
    _shouldAutoPlayNext = false;
    _playbackGeneration++;
  }

  void _scheduleAutoStartIfNeeded(bool isPlaying) {
    if (!isPlaying ||
        _audioPlayer.playing ||
        _isUserDragging ||
        _startingLocally) {
      return;
    }
    if (_autoStartScheduled || _isLoadingSource) return;

    _autoStartScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _autoStartScheduled = false;
      if (!mounted || _startingLocally) return;

      if (!widget.isPlaying || _audioPlayer.playing) return;

      final ready = await _ensureSourceLoaded();
      if (!ready || !mounted) return;

      if (!widget.isPlaying || _audioPlayer.playing) return;

      _shouldAutoPlayNext = true;
      if (_currentlyPlayingPlayer != null &&
          _currentlyPlayingPlayer != _audioPlayer) {
        try {
          await _currentlyPlayingPlayer!.pause();
        } catch (_) {}
      }
      _currentlyPlayingPlayer = _audioPlayer;
      try {
        await _applyCurrentSpeed();
        await _audioPlayer.play();
      } catch (e) {
        debugPrint('Auto-start play error: $e');
      }
    });
  
    
  }

  @override
  void dispose() {
    _cancelChain();
    _durationSub?.cancel();
    _positionSub?.cancel();
    _playerStateSub?.cancel();
    if (_currentlyPlayingPlayer == _audioPlayer) {
      _currentlyPlayingPlayer = null;
    }
    _audioPlayer.dispose();
    _progressFractionNotifier.dispose();
    _displayTimeNotifier.dispose();
    //_speedNotifier.dispose();
    super.dispose();
  }

Future<void> _applyCurrentSpeed() async {
  try {
    await _audioPlayer.setSpeed(_speedNotifier.value);
  } catch (_) {}
}

  Future<void> _cycleSpeed() async {
  final double next = _speedNotifier.value == 1.0
      ? 1.5
      : _speedNotifier.value == 1.5
          ? 2.0
          : 1.0;
  _speedNotifier.value = next;
  try {
    await _audioPlayer.setSpeed(next);
  } catch (_) {}
}


  Future<void> _togglePlayback(bool isPlaying) async {
    widget.onTogglePlayback();
    if (!isPlaying) {
      _playbackGeneration++;
      _startingLocally = true;
      
      if (_sourceLoaded) {
        _playLocalInstance();
      } else {
        final ready = await _ensureSourceLoaded();
        if (!ready || !mounted) {
          _startingLocally = false;
          return;
        }
        _playLocalInstance();
      }
    } else {
      _cancelChain();
      if (_currentlyPlayingPlayer == _audioPlayer) {
        _currentlyPlayingPlayer = null;
      }
      try {
        await _audioPlayer.pause();
      } catch (_) {}
    }
  }

Future<void> _playLocalInstance() async {
    if (_currentlyPlayingPlayer != null &&
        _currentlyPlayingPlayer != _audioPlayer) {
      try {
        await _currentlyPlayingPlayer!.pause();
      } catch (_) {}
    }
    _currentlyPlayingPlayer = _audioPlayer;
    _shouldAutoPlayNext = true;
    try {
       await _applyCurrentSpeed();
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Play error: $e');
    } finally {
      _startingLocally = false;
    }
  }

  

  void _updateDragVisuals(Offset localPosition, double maxWidth) {
    _isUserDragging = true;
    final percentage = localPosition.dx / maxWidth;
    final fraction = percentage.clamp(0.0, 1.0);
    _progressFractionNotifier.value = fraction;

    final totalDuration = _audioPlayer.duration ?? Duration.zero;
    if (totalDuration.inMilliseconds > 0) {
      final currentMs = (totalDuration.inMilliseconds * fraction).round();
      _displayTimeNotifier.value = Duration(milliseconds: currentMs);
    }
  }


  void _executeSeek() {
    final totalDuration = _audioPlayer.duration ?? Duration.zero;
    if (totalDuration.inMilliseconds > 0) {
      final targetMs =
          (totalDuration.inMilliseconds * _progressFractionNotifier.value)
              .round();
      final targetDuration = Duration(milliseconds: targetMs);
      _audioPlayer.seek(targetDuration);
      
      if (widget.onSeekRequested != null) {
        widget.onSeekRequested!(_playbackKey, targetDuration);
      }
    }
    _isUserDragging = false;
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    final twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '$twoDigitMinutes:$twoDigitSeconds';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final Color waveActiveColor = widget.isMe
        ? Colors.white.withOpacity(0.95)
        : AppThemeUtilities.HexToColor('#2ead65');
    final Color waveInactiveColor =
        widget.isMe ? Colors.white38 : Colors.grey.shade300;

        bool isPlaying = widget.isPlaying;
        if (!isPlaying && _audioPlayer.playing && !_startingLocally) {
      _cancelChain();
      _audioPlayer.pause();
      if (_currentlyPlayingPlayer == _audioPlayer) {
        _currentlyPlayingPlayer = null;
      }
    }
        _scheduleAutoStartIfNeeded(isPlaying);
     

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => _togglePlayback(isPlaying),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.isMe
                      ? Colors.white.withOpacity(0.25)
                      : AppThemeUtilities.HexToColor('#2ead65'),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (details) => _updateDragVisuals(
                      details.localPosition,
                      constraints.maxWidth,
                    ),
                    onHorizontalDragUpdate: (details) => _updateDragVisuals(
                      details.localPosition,
                      constraints.maxWidth,
                    ),
                    onHorizontalDragEnd: (_) => _executeSeek(),
                    onTapUp: (_) => _executeSeek(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ValueListenableBuilder<double>(
                        valueListenable: _progressFractionNotifier,
                        builder: (context, progressFraction, _) {
                          final activeBarsCount =
                              (progressFraction * _totalBars).floor();
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: List.generate(_totalBars, (index) {
                              return Container(
                                width: 2.8,
                                height: _waveformSamples[index],
                                decoration: BoxDecoration(
                                  color: index <= activeBarsCount
                                      ? waveActiveColor
                                      : waveInactiveColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              );
                            }),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
                        const SizedBox(width: 1),
            ValueListenableBuilder<double>(
              valueListenable: _speedNotifier,
              builder: (context, speed, _) {
                return GestureDetector(
                  onTap: _cycleSpeed,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: widget.isMe
                          ? Colors.white.withOpacity(0.25)
                          : AppThemeUtilities.HexToColor('#2ead65')
                              .withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "${speed == speed.roundToDouble() ? speed.toInt() : speed}x",
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: widget.isMe
                            ? Colors.white
                            : AppThemeUtilities.HexToColor('#2ead65'),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
            ValueListenableBuilder<Duration>(
              valueListenable: _displayTimeNotifier,
              builder: (context, displayTime, _) {
                return Text(
                  _formatDuration(displayTime),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: widget.contentColor,
                  ),
                );
              },
            ),
          ],
        );
      }
  //   );
  // }

  @override
  bool get wantKeepAlive => true;
}
