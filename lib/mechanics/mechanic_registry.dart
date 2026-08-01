import 'package:flutter/widgets.dart';

import '../data/models.dart';
import 'analog_slider.dart';
import 'drag_target.dart';
import 'mask_reveal.dart';
import 'mechanic.dart';
import 'path_tracing.dart';
import 'physics_spawn.dart';
import 'state_toggle.dart';
import 'tap_hold.dart';

/// Maps a [MechanicType] to its reusable widget. This is the one place a
/// junior developer touches to wire a new lesson to a template - add content
/// to mock_data, and the registry builds the right mechanic automatically.
Widget buildMechanic(MechanicType type, MechanicContext ctx) {
  switch (type) {
    case MechanicType.stateToggle:
      return StateToggleMechanic(ctx: ctx);
    case MechanicType.dragTarget:
      return DragTargetMechanic(ctx: ctx);
    case MechanicType.analogSlider:
      return AnalogSliderMechanic(ctx: ctx);
    case MechanicType.maskReveal:
      return MaskRevealMechanic(ctx: ctx);
    case MechanicType.pathTracing:
      return PathTracingMechanic(ctx: ctx);
    case MechanicType.tapHold:
      return TapHoldMechanic(ctx: ctx);
    case MechanicType.physicsSpawn:
      return PhysicsSpawnMechanic(ctx: ctx);
  }
}
