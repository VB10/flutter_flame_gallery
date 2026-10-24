# Promo assets

`make_promo.py` turns simulator recordings into the announcement video,
poster and website preview image (`marketing/`).

```bash
# 1. Record each game (start recording before tapping Start, play by hand):
xcrun simctl io booted recordVideo --codec=h264 raw_slice.mp4   # Ctrl+C to stop
#    raw_runner.mp4, raw_match.mp4, raw_rhythm.mp4 the same way.
# 2. Pick gallery frames:
ffmpeg -ss 12 -i raw_slice.mp4 -frames:v 1 -vf scale=720:-2 shots/fruit_slice.png
# 3. Build (Python 3 + Pillow, ffmpeg):
python3 tool/promo/make_promo.py --clips rec --shots rec/shots \
  --brand rec/brand_start.png --song apps/example/assets/audio/note_rush_demo.mp3 \
  --out marketing
```

Adjust the clip start times in `CLIPS` at the top of the script. The current
assets were recorded with automated Maestro input; a hand-played recording
looks better (more slices, Perfect hits in Note Rush).
