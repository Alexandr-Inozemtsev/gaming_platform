import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

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
    const int cols = 8;
    const int rows = 5;
    const int total = cols * rows;

    final cells = List<Widget>.generate(total, (index) {
      final playersHere = <int>[];
      for (int i = 0; i < participantsCount; i += 1) {
        if (walkerPositions[i] == index) playersHere.add(i);
      }

      final isSpecial = index % 7 == 0;
      final baseColor = isSpecial
          ? const Color(0xFF2E4F80)
          : (index.isEven ? const Color(0xFF1E365A) : const Color(0xFF24406A));

      return Container(
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: playersHere.isNotEmpty ? AppColors.primaryFig : AppColors.strokeSoft),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.16), blurRadius: 4, offset: const Offset(0, 1)),
          ],
        ),
        child: Stack(
          children: [
            Positioned(left: 5, top: 3, child: Text('${index + 1}', style: AppTypography.caption.copyWith(color: Colors.white70))),
            if (isSpecial)
              const Center(
                child: Icon(Icons.auto_awesome_rounded, size: 14, color: Color(0xFFFFD166)),
              ),
            if (playersHere.isNotEmpty)
              Center(
                child: Wrap(
                  spacing: 2,
                  children: playersHere
                      .map((id) => CircleAvatar(
                            radius: 7,
                            backgroundColor: Color.lerp(AppColors.primaryFig, AppColors.accentSecondary, id / 6) ?? AppColors.primaryFig,
                            child: Text('${id + 1}', style: const TextStyle(fontSize: 8, color: Colors.black)),
                          ))
                      .toList(),
                ),
              ),
          ],
        ),
      );
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellW = constraints.maxWidth / cols;
        final cellH = constraints.maxHeight / rows;
        final cell = cellW < cellH ? cellW : cellH;
        final boardW = cell * cols;
        final boardH = cell * rows;

        return Center(
          child: Container(
            width: boardW,
            height: boardH,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F2748), Color(0xFF173961), Color(0xFF0F2748)],
              ),
              border: Border.all(color: const Color(0xFF6EE7FF).withOpacity(0.7), width: 2),
            ),
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: cols,
              children: cells,
            ),
          ),
        );
      },
    );
  }
}
