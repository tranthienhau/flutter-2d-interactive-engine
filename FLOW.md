# Regenerating the screenshots + demo GIF

The captured PNGs in `screenshots/` and `screenshots/demo.gif` are produced by
running the app on a simulator and driving it with `integration_test`. This is
the reproduction recipe (kept out of the README on purpose).

## Screenshots (7 key screens)

```sh
# 1. Boot a simulator that renders (open the Simulator GUI so the framebuffer
#    is live - a headless device cannot be screenshotted, but the in-engine
#    capture below still works).
open -a Simulator
xcrun simctl boot "iPhone 17 Pro"

# 2. Run the screenshot driver. integrationDriver(onScreenshot:) writes each
#    binding.takeScreenshot('NN-name') into screenshots/NN-name.png.
flutter pub get
flutter drive \
  --driver test_driver/integration_test.dart \
  --target integration_test/screenshot_test.dart \
  -d "iPhone 17 Pro"
```

`integration_test/screenshot_test.dart` clears Hive so onboarding shows
deterministically, then walks: onboarding -> home -> lesson player ->
celebration -> playground -> closet -> progress. It uses fixed
`tester.pump(Duration)` (never `pumpAndSettle`) because the celebration and
mascot screens animate forever and would otherwise hang the driver.

## Demo GIF

`binding.takeScreenshot` captures the Flutter surface directly, so it is
reliable even when the simulator framebuffer is not visible. The animated
walkthrough GIF instead needs real device frames, so it is grabbed from the
simulator framebuffer while a slower interactive drive runs:

```sh
# Terminal A - drive the interactive tour (onboarding -> ... -> progress).
flutter drive \
  --driver test_driver/integration_test.dart \
  --target integration_test/demo_flow.dart \
  -d "iPhone 17" > /tmp/drive.log 2>&1

# Terminal B - once "Connected to Flutter application" appears in the log,
# grab frames until the run ends.
UDID=$(xcrun simctl list devices | grep -m1 "iPhone 17 (" | grep -oE '[0-9A-F-]{36}')
mkdir -p /tmp/frames
i=0; until grep -q "Connected to Flutter application" /tmp/drive.log; do sleep 1; done
while ! grep -q "All tests passed" /tmp/drive.log && [ $i -lt 60 ]; do
  xcrun simctl io "$UDID" screenshot "/tmp/frames/f$(printf '%03d' $i).png"
  i=$((i+1)); sleep 0.3
done

# Assemble the GIF with a generated palette for clean colors.
ffmpeg -y -framerate 4 -i /tmp/frames/f%03d.png \
  -vf "scale=300:-1:flags=lanczos,split[s0][s1];[s0]palettegen=stats_mode=diff[p];[s1][p]paletteuse=dither=bayer" \
  -loop 0 screenshots/demo.gif
```

## Notes

- `xcrun simctl io <udid> screenshot` fails with "Timeout waiting for screen
  surfaces" if no Simulator window is rendering the device. Open `Simulator`
  first, or capture in-engine via the screenshot driver above.
- All mechanics are tap-finishable, and the lesson player has a demo "mark
  done" button, so the drive always reaches the celebration + later screens.
