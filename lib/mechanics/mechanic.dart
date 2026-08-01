import 'package:flutter/material.dart';

import '../core/audio/audio_controller.dart';

/// Called when a mechanic is solved. [stars] is 1..3.
typedef MechanicSolved = void Function(int stars);

/// Shared context handed to every mechanic so it can play SFX / voice without
/// knowing how audio is wired. Keeps mechanics decoupled and junior-friendly.
class MechanicContext {
  const MechanicContext({required this.audio, required this.onSolved});
  final AudioController audio;
  final MechanicSolved onSolved;
}

/// Base class for the seven reusable interaction templates. A lesson author
/// subclasses nothing - they just instantiate one of these with content.
abstract class MechanicWidget extends StatefulWidget {
  const MechanicWidget({super.key, required this.ctx});
  final MechanicContext ctx;
}
