import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../features/gameplay/big_walker/animations/big_walker_motion.dart';
import '../../features/gameplay/big_walker/model/board_path.dart';
import '../../features/gameplay/big_walker/painters/big_walker_route_painter.dart';
import '../../shared/assets/runtime_asset_pack.dart';
import '../../theme/game/big_walker_tokens.dart';

part '../../features/gameplay/big_walker/widgets/big_walker_board_background.dart';
part '../../features/gameplay/big_walker/widgets/big_walker_cell.dart';
part '../../features/gameplay/big_walker/widgets/big_walker_pawn.dart';

class BigWalkerBoard extends StatelessWidget {
  const BigWalkerBoard({
    super.key,
    required this.participantsCount,
    required this.walkerPositions,
    this.activePathIndex,
    this.currentPlayerIndex,
  });

  static final BigWalkerBoardPath boardPath = BigWalkerBoardPath.standard();

  final int participantsCount;
  final List<int> walkerPositions;
  final int? activePathIndex;
  final int? currentPlayerIndex;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellW = constraints.maxWidth / BigWalkerTokens.cols;
        final cellH = constraints.maxHeight / BigWalkerTokens.rows;
        final cell = cellW < cellH ? cellW : cellH;
        final boardW = cell * BigWalkerTokens.cols;
        final boardH = cell * BigWalkerTokens.rows;

        final cells = List<Widget>.generate(BigWalkerTokens.totalCells, (gridIndex) {
          final row = gridIndex ~/ BigWalkerTokens.cols;
          final col = gridIndex % BigWalkerTokens.cols;
          final pathNode = boardPath.nodeAtGrid(row, col);
          if (pathNode == null) return const SizedBox.shrink();

          final playersHere = <int>[];
          for (int i = 0; i < participantsCount; i += 1) {
            final playerNode = boardPath.nodeForRouteIndex(walkerPositions[i]);
            if (playerNode.routeIndex == pathNode.routeIndex) playersHere.add(i);
          }

          return _BigWalkerCell(
            routeIndex: pathNode.routeIndex,
            playersHere: playersHere,
            isActivePath: activePathIndex == pathNode.routeIndex,
            tileStyle: pathNode.tileStyle,
          );
        });

        final startNode = boardPath.nodes.firstWhere((node) => node.isStart);
        final finishNode = boardPath.nodes.firstWhere((node) => node.isFinish);

        return Center(
          child: SizedBox(
            width: boardW,
            height: boardH,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(BigWalkerTokens.boardRadius + 14),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [BigWalkerTokens.boardWoodTop, BigWalkerTokens.boardWoodBottom],
                ),
                boxShadow: BigWalkerTokens.boardShadow,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(BigWalkerTokens.boardRadius),
                  child: Stack(
                    children: [
                      const Positioned.fill(child: _BoardSurfaceLayer()),
                      Positioned.fill(
                        child: CustomPaint(
                          painter: BigWalkerRoutePainter(path: boardPath, activePathIndex: activePathIndex),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(BigWalkerTokens.boardRadius),
                          gradient: BigWalkerTokens.boardInnerGradient,
                        ),
                        child: GridView.count(
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: BigWalkerTokens.cols,
                          children: cells,
                        ),
                      ),
                      _BigWalkerPathMarker(node: startNode, label: 'START', glowColor: BigWalkerTokens.boardStart, cellSize: cell),
                      _BigWalkerPathMarker(node: finishNode, label: 'FINISH', glowColor: BigWalkerTokens.boardFinish, cellSize: cell),
                      ...List<Widget>.generate(participantsCount, (playerIndex) {
                        final routePosition = boardPath.nodeForRouteIndex(walkerPositions[playerIndex]).routeIndex;
                        return _BigWalkerPawn(
                          key: ValueKey('pawn-$playerIndex'),
                          playerIndex: playerIndex,
                          routeIndex: routePosition,
                          boardWidth: boardW,
                          boardHeight: boardH,
                          path: boardPath,
                          active: currentPlayerIndex == playerIndex,
                        );
                      }),
                      IgnorePointer(
                        child: _BoardDecorativeOverlays(
                          borderRadius: BigWalkerTokens.boardRadius,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BigWalkerPathMarker extends StatelessWidget {
  const _BigWalkerPathMarker({
    required this.node,
    required this.label,
    required this.glowColor,
    required this.cellSize,
  });

  final BigWalkerPathNode node;
  final String label;
  final Color glowColor;
  final double cellSize;

  @override
  Widget build(BuildContext context) {
    final boardWidth = cellSize * BigWalkerTokens.cols;
    final boardHeight = cellSize * BigWalkerTokens.rows;
    final center = node.toBoardOffset(boardWidth: boardWidth, boardHeight: boardHeight);

    return Positioned(
      left: center.dx - (cellSize * 0.32),
      top: center.dy - (cellSize * 0.16),
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: Colors.black.withOpacity(0.45),
            border: Border.all(color: glowColor.withOpacity(0.85)),
            boxShadow: [
              BoxShadow(color: glowColor.withOpacity(0.5), blurRadius: 12),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            child: Text(
              label,
              style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ),
    );
  }
}

class _BoardSurfaceLayer extends StatelessWidget {
  const _BoardSurfaceLayer();

  @override
  Widget build(BuildContext context) {
    return _ResolvedBoardAssetLayer(
      assetKey: BigWalkerTokens.gameplayBoardSurfaceTravelGridKey,
      fallback: const _BigWalkerBoardBackground(),
    );
  }
}

class _BoardDecorativeOverlays extends StatelessWidget {
  const _BoardDecorativeOverlays({required this.borderRadius});

  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: BigWalkerTokens.boardBorder, width: 2),
        boxShadow: [
          BoxShadow(
            color: BigWalkerTokens.accentCyan.withOpacity(0.24),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

class _ResolvedBoardAssetLayer extends StatelessWidget {
  const _ResolvedBoardAssetLayer({
    required this.assetKey,
    required this.fallback,
    this.fit = BoxFit.cover,
  });

  final String assetKey;
  final Widget fallback;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: RuntimeAssetPack.instance.resolveAsset(assetKey),
      builder: (context, snapshot) {
        final assetPath = snapshot.data;
        if (assetPath == null || assetPath.isEmpty) {
          assert(() {
            debugPrint('[BigWalkerBoard] Missing runtime asset key="$assetKey". Using controlled fallback widget.');
            return true;
          }());
          return fallback;
        }
        final image = _buildImage(assetPath);
        if (image == null) {
          assert(() {
            debugPrint(
              '[BigWalkerBoard] Runtime asset key="$assetKey" resolved as non-raster marker "$assetPath". '
              'Using controlled fallback widget.',
            );
            return true;
          }());
          return fallback;
        }
        return image;
      },
    );
  }

  Widget? _buildImage(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(path, fit: fit, errorBuilder: (context, error, stackTrace) => fallback);
    }
    if (path.endsWith('.svg') || path.contains('#')) return null;
    return Image.asset(path, fit: fit, errorBuilder: (context, error, stackTrace) => fallback);
  }
}
