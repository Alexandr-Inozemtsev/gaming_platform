# Big Walker golden baselines

This folder stores Big Walker golden baselines in text-safe form for PR systems that reject binary diffs.

- Canonical required list is in `big_walker_baselines.manifest.json`.
- Source files are committed as `big_walker_<state>.png.base64`.
- Generate PNG files before running golden tests:
  - `python test/golden/goldens/materialize_big_walker_goldens.py`
- CI runs materialization before golden tests, then treats missing/mismatched PNG files as blocking failures.
- Expected generated PNG files:
  - `big_walker_idle.png`
  - `big_walker_roll.png`
  - `big_walker_next_turn.png`
  - `big_walker_pause.png`
  - `big_walker_victory.png`
