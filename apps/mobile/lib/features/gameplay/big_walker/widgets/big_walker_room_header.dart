import 'package:flutter/material.dart';

import '../../../../theme/tokens.dart';

class BigWalkerRoomHeader extends StatelessWidget {
  const BigWalkerRoomHeader({
    super.key,
    required this.title,
    required this.participantsCount,
    required this.onParticipantsCountChanged,
  });

  final String title;
  final int participantsCount;
  final ValueChanged<int> onParticipantsCountChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: AppTypography.h2.copyWith(color: AppColors.campaignHeader)),
        const Spacer(),
        SizedBox(
          width: 220,
          child: Slider(
            value: participantsCount.toDouble(),
            min: 2,
            max: 6,
            divisions: 4,
            label: '$participantsCount',
            onChanged: (value) => onParticipantsCountChanged(value.round()),
          ),
        ),
      ],
    );
  }
}
