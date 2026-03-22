import 'dart:ui';

import '../../../../theme/game/big_walker_tokens.dart';
import 'path_presets.dart';

enum BigWalkerTileStyle { normal, bonus, risk }

class BigWalkerPathNode {
  const BigWalkerPathNode({
    required this.routeIndex,
    required this.gridRow,
    required this.gridCol,
    required this.u,
    required this.v,
    this.tileStyle = BigWalkerTileStyle.normal,
    this.isStart = false,
    this.isFinish = false,
  });

  final int routeIndex;
  final int gridRow;
  final int gridCol;
  final double u;
  final double v;
  final BigWalkerTileStyle tileStyle;
  final bool isStart;
  final bool isFinish;

  Offset toBoardOffset({required double boardWidth, required double boardHeight}) {
    return Offset(u * boardWidth, v * boardHeight);
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
    if (bigWalkerStandardPathPreset.length != BigWalkerTokens.totalCells) {
      throw StateError(
        'Big Walker path preset must provide exactly ${BigWalkerTokens.totalCells} nodes; '
        'got ${bigWalkerStandardPathPreset.length}.',
      );
    }

    final nodes = <BigWalkerPathNode>[
      for (final presetNode in bigWalkerStandardPathPreset)
        BigWalkerPathNode(
          routeIndex: presetNode.routeIndex,
          gridRow: presetNode.gridRow,
          gridCol: presetNode.gridCol,
          u: presetNode.u,
          v: presetNode.v,
          isStart: presetNode.routeIndex == 0,
          isFinish: presetNode.routeIndex == BigWalkerTokens.totalCells - 1,
          tileStyle: _resolveTileStyle(
            routeIndex: presetNode.routeIndex,
            isStart: presetNode.routeIndex == 0,
            isFinish: presetNode.routeIndex == BigWalkerTokens.totalCells - 1,
          ),
        ),
    ]..sort((left, right) => left.routeIndex.compareTo(right.routeIndex));

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
