import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Big Walker baseline manifest lists required 5 states', () {
    final manifestFile = File('test/golden/goldens/big_walker_baselines.manifest.json');
    expect(manifestFile.existsSync(), isTrue, reason: 'Missing baseline manifest file.');

    final manifest = jsonDecode(manifestFile.readAsStringSync()) as Map<String, dynamic>;
    final requiredStates = (manifest['required_states'] as List<dynamic>)
        .cast<Map<String, dynamic>>();

    const expected = <String, String>{
      'idle': 'big_walker_idle.png',
      'roll': 'big_walker_roll.png',
      'next_turn': 'big_walker_next_turn.png',
      'pause': 'big_walker_pause.png',
      'victory': 'big_walker_victory.png',
    };

    expect(requiredStates.length, expected.length);

    final actual = {
      for (final state in requiredStates)
        state['state'] as String: state['file'] as String,
    };

    expect(actual, expected);

    for (final fileName in expected.values) {

      final encodedBaselineFile = File('test/golden/goldens/$fileName.base64');
      expect(
        encodedBaselineFile.existsSync(),
        isTrue,
        reason: 'Missing committed encoded baseline: ${encodedBaselineFile.path}',
      );

      final baselineFile = File('test/golden/goldens/$fileName');
      expect(
        baselineFile.existsSync(),
        isTrue,
        reason: 'Missing committed baseline PNG: ${baselineFile.path}',
      );
    }
  });
}
