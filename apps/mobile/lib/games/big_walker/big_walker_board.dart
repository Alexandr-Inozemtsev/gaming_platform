import 'package:flutter/material.dart';

import '../../features/gameplay/big_walker/animations/big_walker_motion.dart';
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

  final int participantsCount;
  final List<int> walkerPositions;
  final int? activePathIndex;
  final int? currentPlayerIndex;

  int _routeToGridIndex(int routeIndex) {
    final row = routeIndex ~/ BigWalkerTokens.cols;
    final colInRow = routeIndex % BigWalkerTokens.cols;
    final col = row.isEven ? colInRow : (BigWalkerTokens.cols - 1 - colInRow);
    return row * BigWalkerTokens.cols + col;
  }

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
          final routeIndex = _gridToRouteIndex(gridIndex);
          final playersHere = <int>[];
          for (int i = 0; i < participantsCount; i += 1) {
            if (walkerPositions[i] == routeIndex) playersHere.add(i);
          }
          return _BigWalkerCell(
            routeIndex: routeIndex,
            playersHere: playersHere,
            isActivePath: activePathIndex == routeIndex,
            isStart: routeIndex == 0,
            isFinish: routeIndex == BigWalkerTokens.totalCells - 1,
          );
        });

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
                        child: CustomPaint(painter: BigWalkerRoutePainter(activePathIndex: activePathIndex)),
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
                      ...List<Widget>.generate(participantsCount, (playerIndex) {
                        final routePosition = walkerPositions[playerIndex].clamp(0, BigWalkerTokens.totalCells - 1);
                        final gridIndex = _routeToGridIndex(routePosition);
                        return _BigWalkerPawn(
                          key: ValueKey('pawn-$playerIndex'),
                          playerIndex: playerIndex,
                          position: gridIndex,
                          cellSize: cell,
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

  int _gridToRouteIndex(int gridIndex) {
    final row = gridIndex ~/ BigWalkerTokens.cols;
    final col = gridIndex % BigWalkerTokens.cols;
    final colInRoute = row.isEven ? col : (BigWalkerTokens.cols - 1 - col);
    return row * BigWalkerTokens.cols + colInRoute;
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
    return FutureBuilder<String>(
      future: RuntimeAssetPack.instance.resolveAssetOrFallback(assetKey),
      builder: (context, snapshot) {
        final assetPath = snapshot.data;
        if (assetPath == null || assetPath.isEmpty) return fallback;
        final image = _buildImage(assetPath);
        return image ?? fallback;
      },
    );
  }

  Widget? _buildImage(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(path, fit: fit, errorBuilder: (_, _, _) => fallback);
    }
    if (path.endsWith('.svg')) return fallback;
    return Image.asset(path, fit: fit, errorBuilder: (_, _, _) => fallback);
  }
}
