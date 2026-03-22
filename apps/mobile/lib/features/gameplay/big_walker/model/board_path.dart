import 'dart:ui';

import '../../../../theme/game/big_walker_tokens.dart';

enum BigWalkerTileStyle { normal, bonus, risk }

class BigWalkerPathNode {
  const BigWalkerPathNode({
    required this.routeIndex,
    required this.gridRow,
    required this.gridCol,
    this.tileStyle = BigWalkerTileStyle.normal,
    this.isStart = false,
    this.isFinish = false,
  });

  final int routeIndex;
  final int gridRow;
  final int gridCol;
  final BigWalkerTileStyle tileStyle;
  final bool isStart;
  final bool isFinish;

  Offset toBoardOffset({required double cellWidth, required double cellHeight}) {
    return Offset((gridCol + 0.5) * cellWidth, (gridRow + 0.5) * cellHeight);
  }
}

class BigWalkerPathSegment {
  const BigWalkerPathSegment({required this.fromRouteIndex, required this.toRouteIndex});

  final int fromRouteIndex;
  final int toRouteIndex;
}

class BigWalkerBoardPath {
  const BigWalkerBoardPath._({required this.nodes, required this.segments});

  factory BigWalkerBoardPath.standard() {
    final nodes = <BigWalkerPathNode>[];

    for (int routeIndex = 0; routeIndex < BigWalkerTokens.totalCells; routeIndex += 1) {
      final row = routeIndex ~/ BigWalkerTokens.cols;
      final colInRow = routeIndex % BigWalkerTokens.cols;
      final col = row.isEven ? colInRow : (BigWalkerTokens.cols - 1 - colInRow);

      final isStart = routeIndex == 0;
      final isFinish = routeIndex == BigWalkerTokens.totalCells - 1;

      nodes.add(
        BigWalkerPathNode(
          routeIndex: routeIndex,
          gridRow: row,
          gridCol: col,
          isStart: isStart,
          isFinish: isFinish,
          tileStyle: _resolveTileStyle(routeIndex: routeIndex, isStart: isStart, isFinish: isFinish),
        ),
      );
    }

    final segments = <BigWalkerPathSegment>[
      for (int i = 0; i < nodes.length - 1; i += 1)
        BigWalkerPathSegment(fromRouteIndex: nodes[i].routeIndex, toRouteIndex: nodes[i + 1].routeIndex),
    ];

    return BigWalkerBoardPath._(nodes: nodes, segments: segments);
  }

  final List<BigWalkerPathNode> nodes;
  final List<BigWalkerPathSegment> segments;

  int get maxRouteIndex => nodes.length - 1;

  BigWalkerPathNode nodeForRouteIndex(int routeIndex) {
    final normalized = routeIndex.clamp(0, maxRouteIndex);
    return nodes[normalized];
  }

  BigWalkerPathNode? nodeAtGrid(int gridRow, int gridCol) {
    for (final node in nodes) {
      if (node.gridRow == gridRow && node.gridCol == gridCol) {
        return node;
      }
    }
    return null;
  }

  static BigWalkerTileStyle _resolveTileStyle({required int routeIndex, required bool isStart, required bool isFinish}) {
    if (isStart || isFinish) return BigWalkerTileStyle.normal;
    if (routeIndex % 11 == 0) return BigWalkerTileStyle.risk;
    if (routeIndex % 7 == 0) return BigWalkerTileStyle.bonus;
    return BigWalkerTileStyle.normal;
  }
}
