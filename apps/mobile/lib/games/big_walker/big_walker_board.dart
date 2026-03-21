import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../../theme/game/big_walker_tokens.dart';

part '../../features/gameplay/big_walker/widgets/big_walker_board_background.dart';
part '../../features/gameplay/big_walker/widgets/big_walker_cell.dart';
part '../../features/gameplay/big_walker/widgets/big_walker_pawn.dart';

class BigWalkerBoard extends StatelessWidget {
  const BigWalkerBoard({
    super.key,
    required this.participantsCount,
    required this.walkerPositions,
  });

  final int participantsCount;
  final List<int> walkerPositions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellW = constraints.maxWidth / BigWalkerTokens.cols;
        final cellH = constraints.maxHeight / BigWalkerTokens.rows;
        final cell = cellW < cellH ? cellW : cellH;
        final boardW = cell * BigWalkerTokens.cols;
        final boardH = cell * BigWalkerTokens.rows;

        final cells = List<Widget>.generate(BigWalkerTokens.totalCells, (index) {
          final playersHere = <int>[];
          for (int i = 0; i < participantsCount; i += 1) {
            if (walkerPositions[i] == index) playersHere.add(i);
          }
          return _BigWalkerCell(index: index, playersHere: playersHere);
        });

        return Center(
          child: SizedBox(
            width: boardW,
            height: boardH,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(BigWalkerTokens.boardRadius),
              child: Stack(
                children: [
                  const Positioned.fill(child: _BigWalkerBoardBackground()),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(BigWalkerTokens.boardRadius),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          BigWalkerTokens.boardGradientStart,
                          BigWalkerTokens.boardGradientMid,
                          BigWalkerTokens.boardGradientEnd,
                        ],
                      ),
                    ),
                    child: GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: BigWalkerTokens.cols,
                      children: cells,
                    ),
                  ),
                  ...List<Widget>.generate(participantsCount, (playerIndex) {
                    final position = walkerPositions[playerIndex].clamp(0, BigWalkerTokens.totalCells - 1);
                    return _BigWalkerPawn(
                      key: ValueKey('pawn-$playerIndex'),
                      playerIndex: playerIndex,
                      position: position,
                      cellSize: cell,
                    );
                  }),
                  IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(BigWalkerTokens.boardRadius),
                        border: Border.all(color: BigWalkerTokens.boardBorder, width: BigWalkerTokens.boardBorderWidth),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
