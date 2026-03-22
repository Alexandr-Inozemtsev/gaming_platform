class BigWalkerPathPresetNode {
  const BigWalkerPathPresetNode({
    required this.routeIndex,
    required this.gridRow,
    required this.gridCol,
    required this.u,
    required this.v,
  });

  final int routeIndex;
  final int gridRow;
  final int gridCol;
  final double u;
  final double v;
}

const List<BigWalkerPathPresetNode> bigWalkerStandardPathPreset = <BigWalkerPathPresetNode>[
  BigWalkerPathPresetNode(routeIndex: 0, gridRow: 0, gridCol: 0, u: 0.08, v: 0.10),
  BigWalkerPathPresetNode(routeIndex: 1, gridRow: 0, gridCol: 1, u: 0.19, v: 0.12),
  BigWalkerPathPresetNode(routeIndex: 2, gridRow: 0, gridCol: 2, u: 0.30, v: 0.11),
  BigWalkerPathPresetNode(routeIndex: 3, gridRow: 0, gridCol: 3, u: 0.41, v: 0.09),
  BigWalkerPathPresetNode(routeIndex: 4, gridRow: 0, gridCol: 4, u: 0.52, v: 0.11),
  BigWalkerPathPresetNode(routeIndex: 5, gridRow: 0, gridCol: 5, u: 0.63, v: 0.09),
  BigWalkerPathPresetNode(routeIndex: 6, gridRow: 0, gridCol: 6, u: 0.75, v: 0.11),
  BigWalkerPathPresetNode(routeIndex: 7, gridRow: 0, gridCol: 7, u: 0.88, v: 0.13),
  BigWalkerPathPresetNode(routeIndex: 8, gridRow: 1, gridCol: 7, u: 0.89, v: 0.28),
  BigWalkerPathPresetNode(routeIndex: 9, gridRow: 1, gridCol: 6, u: 0.76, v: 0.30),
  BigWalkerPathPresetNode(routeIndex: 10, gridRow: 1, gridCol: 5, u: 0.64, v: 0.27),
  BigWalkerPathPresetNode(routeIndex: 11, gridRow: 1, gridCol: 4, u: 0.53, v: 0.29),
  BigWalkerPathPresetNode(routeIndex: 12, gridRow: 1, gridCol: 3, u: 0.42, v: 0.27),
  BigWalkerPathPresetNode(routeIndex: 13, gridRow: 1, gridCol: 2, u: 0.31, v: 0.30),
  BigWalkerPathPresetNode(routeIndex: 14, gridRow: 1, gridCol: 1, u: 0.20, v: 0.28),
  BigWalkerPathPresetNode(routeIndex: 15, gridRow: 1, gridCol: 0, u: 0.09, v: 0.31),
  BigWalkerPathPresetNode(routeIndex: 16, gridRow: 2, gridCol: 0, u: 0.10, v: 0.47),
  BigWalkerPathPresetNode(routeIndex: 17, gridRow: 2, gridCol: 1, u: 0.21, v: 0.49),
  BigWalkerPathPresetNode(routeIndex: 18, gridRow: 2, gridCol: 2, u: 0.32, v: 0.46),
  BigWalkerPathPresetNode(routeIndex: 19, gridRow: 2, gridCol: 3, u: 0.43, v: 0.48),
  BigWalkerPathPresetNode(routeIndex: 20, gridRow: 2, gridCol: 4, u: 0.54, v: 0.47),
  BigWalkerPathPresetNode(routeIndex: 21, gridRow: 2, gridCol: 5, u: 0.65, v: 0.49),
  BigWalkerPathPresetNode(routeIndex: 22, gridRow: 2, gridCol: 6, u: 0.77, v: 0.46),
  BigWalkerPathPresetNode(routeIndex: 23, gridRow: 2, gridCol: 7, u: 0.89, v: 0.49),
  BigWalkerPathPresetNode(routeIndex: 24, gridRow: 3, gridCol: 7, u: 0.88, v: 0.64),
  BigWalkerPathPresetNode(routeIndex: 25, gridRow: 3, gridCol: 6, u: 0.76, v: 0.66),
  BigWalkerPathPresetNode(routeIndex: 26, gridRow: 3, gridCol: 5, u: 0.65, v: 0.63),
  BigWalkerPathPresetNode(routeIndex: 27, gridRow: 3, gridCol: 4, u: 0.54, v: 0.65),
  BigWalkerPathPresetNode(routeIndex: 28, gridRow: 3, gridCol: 3, u: 0.43, v: 0.63),
  BigWalkerPathPresetNode(routeIndex: 29, gridRow: 3, gridCol: 2, u: 0.32, v: 0.66),
  BigWalkerPathPresetNode(routeIndex: 30, gridRow: 3, gridCol: 1, u: 0.21, v: 0.64),
  BigWalkerPathPresetNode(routeIndex: 31, gridRow: 3, gridCol: 0, u: 0.10, v: 0.67),
  BigWalkerPathPresetNode(routeIndex: 32, gridRow: 4, gridCol: 0, u: 0.12, v: 0.83),
  BigWalkerPathPresetNode(routeIndex: 33, gridRow: 4, gridCol: 1, u: 0.23, v: 0.85),
  BigWalkerPathPresetNode(routeIndex: 34, gridRow: 4, gridCol: 2, u: 0.34, v: 0.82),
  BigWalkerPathPresetNode(routeIndex: 35, gridRow: 4, gridCol: 3, u: 0.45, v: 0.84),
  BigWalkerPathPresetNode(routeIndex: 36, gridRow: 4, gridCol: 4, u: 0.57, v: 0.82),
  BigWalkerPathPresetNode(routeIndex: 37, gridRow: 4, gridCol: 5, u: 0.68, v: 0.84),
  BigWalkerPathPresetNode(routeIndex: 38, gridRow: 4, gridCol: 6, u: 0.79, v: 0.82),
  BigWalkerPathPresetNode(routeIndex: 39, gridRow: 4, gridCol: 7, u: 0.90, v: 0.85),
];
