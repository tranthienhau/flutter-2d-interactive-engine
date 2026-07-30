import 'package:flutter/material.dart';

/// The seven reusable interaction primitives the engine ships with.
/// Every lesson is authored by picking one of these and feeding it config.
enum MechanicType {
  stateToggle,
  dragTarget,
  analogSlider,
  maskReveal,
  pathTracing,
  tapHold,
  physicsSpawn,
}

extension MechanicMeta on MechanicType {
  String get title {
    switch (this) {
      case MechanicType.stateToggle:
        return 'State Toggle';
      case MechanicType.dragTarget:
        return 'Drag & Target';
      case MechanicType.analogSlider:
        return 'Analog Slider';
      case MechanicType.maskReveal:
        return 'Mask Reveal';
      case MechanicType.pathTracing:
        return 'Path Tracing';
      case MechanicType.tapHold:
        return 'Tap & Hold';
      case MechanicType.physicsSpawn:
        return 'Physics Spawn';
    }
  }

  String get blurb {
    switch (this) {
      case MechanicType.stateToggle:
        return 'Day / night switch';
      case MechanicType.dragTarget:
        return 'Shape into slot';
      case MechanicType.analogSlider:
        return 'Fill the cup';
      case MechanicType.maskReveal:
        return 'Scratch to reveal';
      case MechanicType.pathTracing:
        return 'Trace the letter A';
      case MechanicType.tapHold:
        return 'Grow the flower';
      case MechanicType.physicsSpawn:
        return 'Pop the bubbles';
    }
  }

  IconData get icon {
    switch (this) {
      case MechanicType.stateToggle:
        return Icons.wb_sunny_outlined;
      case MechanicType.dragTarget:
        return Icons.category_outlined;
      case MechanicType.analogSlider:
        return Icons.local_drink_outlined;
      case MechanicType.maskReveal:
        return Icons.auto_fix_high_outlined;
      case MechanicType.pathTracing:
        return Icons.gesture_outlined;
      case MechanicType.tapHold:
        return Icons.local_florist_outlined;
      case MechanicType.physicsSpawn:
        return Icons.bubble_chart_outlined;
    }
  }
}

/// A single authored lesson: a mechanic + a skill tag + a display icon.
class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.mechanic,
    required this.skill,
    required this.icon,
    required this.instruction,
  });

  final String id;
  final String title;
  final MechanicType mechanic;
  final String skill;
  final IconData icon;
  final String instruction;
}

/// A costume skin the child can unlock and equip on the mascot. In production
/// each maps to a Rive artboard skin; here it maps to a painted overlay.
class Costume {
  const Costume({
    required this.id,
    required this.name,
    required this.category,
    required this.starCost,
    required this.color,
  });

  final String id;
  final String name;
  final String category; // Hats | Capes | Shoes | Pets
  final int starCost; // stars required to unlock
  final Color color;
}
