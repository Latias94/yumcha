import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../../../../../shared/infrastructure/services/media/media_storage_service.dart';
import '../../../../../../shared/presentation/design_system/design_constants.dart';

/// 音频播放组件
///
/// 支持多种音频来源：
/// - 网络音频（URL）
/// - 本地文件
/// - Base64数据
/// - 缓存音频
class AudioPlayerWidget extends StatefulWidget {
  const AudioPlayerWidget({
    super.key,
    required this.mediaMetadata,
    this.showWaveform = false,
    this.autoPlay = false,
    this.showDuration = true,
    this.showSpeed = false,
    this.compact = false,
  });

  /// 媒体元数据
  final MediaMetadata mediaMetadata;

  /// 是否显示波形（暂未实现）
  final bool showWaveform;

  /// 是否自动播放
  final bool autoPlay;

  /// 是否显示时长
  final bool showDuration;

  /// 是否显示播放速度控制
  final bool showSpeed;

  /// 是否使用紧凑布局
  final bool compact;

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool _isLoading = false;
  String? _errorMessage;
  String? _tempFilePath;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _loadAudio();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _cleanupTempFile();
    super.dispose();
  }

  Future<void> _loadAudio() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _prepareAudioSource();

      if (widget.autoPlay && mounted) {
        await _audioPlayer.play();
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _prepareAudioSource() async {
    final metadata = widget.mediaMetadata;

    switch (metadata.strategy) {
      case MediaStorageStrategy.networkUrl:
        if (metadata.networkUrl != null) {
          await _audioPlayer.setUrl(metadata.networkUrl!);
        }
        break;

      case MediaStorageStrategy.database:
      case MediaStorageStrategy.localFile:
      case MediaStorageStrategy.cache:
        // 从存储服务获取音频数据
        final mediaService = MediaStorageService();
        await mediaService.initialize();

        final audioData = await mediaService.retrieveMedia(metadata);
        if (audioData != null) {
          // 创建临时文件
          _tempFilePath = await _createTempFile(audioData, metadata.fileName);
          await _audioPlayer.setFilePath(_tempFilePath!);
        } else {
          throw Exception('无法获取音频数据');
        }
        break;
    }
  }

  Future<String> _createTempFile(Uint8List data, String fileName) async {
    final tempDir = await getTemporaryDirectory();
    final extension = path.extension(fileName);
    final tempFileName =
        'audio_${DateTime.now().millisecondsSinceEpoch}$extension';
    final tempFile = File(path.join(tempDir.path, tempFileName));

    await tempFile.writeAsBytes(data);
    return tempFile.path;
  }

  Future<void> _cleanupTempFile() async {
    if (_tempFilePath != null) {
      try {
        final file = File(_tempFilePath!);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        // 忽略清理错误
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return _buildLoadingWidget(theme);
    }

    if (_errorMessage != null) {
      return _buildErrorWidget(theme);
    }

    return widget.compact
        ? _buildCompactPlayer(theme)
        : _buildFullPlayer(theme);
  }

  Widget _buildLoadingWidget(ThemeData theme) {
    return Container(
      padding: DesignConstants.paddingM,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: DesignConstants.radiusM,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary.withValues(alpha: 0.7),
              ),
            ),
          ),
          SizedBox(width: DesignConstants.spaceS),
          Text(
            '加载音频...',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(ThemeData theme) {
    return Container(
      padding: DesignConstants.paddingM,
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.1),
        borderRadius: DesignConstants.radiusM,
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
          width: DesignConstants.borderWidthThin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: theme.colorScheme.error.withValues(alpha: 0.7),
            size: 20,
          ),
          SizedBox(width: DesignConstants.spaceS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '音频加载失败',
                  style: TextStyle(
                    color: theme.colorScheme.error.withValues(alpha: 0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_errorMessage != null) ...[
                  SizedBox(height: DesignConstants.spaceXS / 2),
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: theme.colorScheme.onErrorContainer
                          .withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactPlayer(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignConstants.spaceM,
        vertical: DesignConstants.spaceS,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
        borderRadius: DesignConstants.radiusM,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: DesignConstants.borderWidthThin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPlayButton(theme, size: 32),
          SizedBox(width: DesignConstants.spaceS),
          Icon(
            Icons.audiotrack_rounded,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            size: 16,
          ),
          SizedBox(width: DesignConstants.spaceXS),
          Text(
            widget.mediaMetadata.fileName,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (widget.showDuration) ...[
            SizedBox(width: DesignConstants.spaceS),
            _buildDurationText(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildFullPlayer(ThemeData theme) {
    return Container(
      padding: DesignConstants.paddingL,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
        borderRadius: DesignConstants.radiusL,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: DesignConstants.borderWidthThin,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 音频信息
          Row(
            children: [
              Icon(
                Icons.audiotrack_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: DesignConstants.spaceS),
              Expanded(
                child: Text(
                  widget.mediaMetadata.fileName,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.showDuration) _buildDurationText(theme),
            ],
          ),

          SizedBox(height: DesignConstants.spaceM),

          // 播放控制
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPlayButton(theme, size: 48),
              if (widget.showSpeed) ...[
                SizedBox(width: DesignConstants.spaceL),
                _buildSpeedButton(theme),
              ],
            ],
          ),

          SizedBox(height: DesignConstants.spaceM),

          // 进度条
          _buildProgressBar(theme),
        ],
      ),
    );
  }

  Widget _buildPlayButton(ThemeData theme, {double size = 48}) {
    return StreamBuilder<PlayerState>(
      stream: _audioPlayer.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing;

        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          return SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor:
                  AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
          );
        }

        return IconButton(
          onPressed: () {
            if (playing == true) {
              _audioPlayer.pause();
            } else {
              _audioPlayer.play();
            }
          },
          icon: Icon(
            playing == true ? Icons.pause_rounded : Icons.play_arrow_rounded,
            size: size * 0.6,
          ),
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            fixedSize: Size(size, size),
          ),
        );
      },
    );
  }

  Widget _buildSpeedButton(ThemeData theme) {
    return StreamBuilder<double>(
      stream: _audioPlayer.speedStream,
      builder: (context, snapshot) {
        final speed = snapshot.data ?? 1.0;
        return PopupMenuButton<double>(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: DesignConstants.spaceS,
              vertical: DesignConstants.spaceXS,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.5),
              ),
              borderRadius: DesignConstants.radiusS,
            ),
            child: Text(
              '${speed}x',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          onSelected: (newSpeed) {
            _audioPlayer.setSpeed(newSpeed);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 0.5, child: Text('0.5x')),
            const PopupMenuItem(value: 0.75, child: Text('0.75x')),
            const PopupMenuItem(value: 1.0, child: Text('1.0x')),
            const PopupMenuItem(value: 1.25, child: Text('1.25x')),
            const PopupMenuItem(value: 1.5, child: Text('1.5x')),
            const PopupMenuItem(value: 2.0, child: Text('2.0x')),
          ],
        );
      },
    );
  }

  Widget _buildDurationText(ThemeData theme) {
    return StreamBuilder<Duration?>(
      stream: _audioPlayer.durationStream,
      builder: (context, snapshot) {
        final duration = snapshot.data;
        if (duration == null) return const SizedBox.shrink();

        return Text(
          _formatDuration(duration),
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(ThemeData theme) {
    return StreamBuilder<Duration?>(
      stream: _audioPlayer.positionStream,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final duration = _audioPlayer.duration ?? Duration.zero;

        return Column(
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                trackHeight: 3,
              ),
              child: Slider(
                value: duration.inMilliseconds > 0
                    ? position.inMilliseconds / duration.inMilliseconds
                    : 0.0,
                onChanged: (value) {
                  final newPosition = Duration(
                    milliseconds: (value * duration.inMilliseconds).round(),
                  );
                  _audioPlayer.seek(newPosition);
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(position),
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
                Text(
                  _formatDuration(duration),
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
