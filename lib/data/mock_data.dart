import 'package:flutter/material.dart';

import 'models.dart';

/// The 10-class pilot, one lesson per node on the home map. Each lesson is a
/// thin config over one of the seven reusable mechanics.
const kLessons = <Lesson>[
  Lesson(
    id: 'l01',
    title: 'Day and Night',
    mechanic: MechanicType.stateToggle,
    skill: 'Colors',
    icon: Icons.wb_sunny_outlined,
    instruction: 'Tap to switch day and night!',
  ),
  Lesson(
    id: 'l02',
    title: 'Shape Homes',
    mechanic: MechanicType.dragTarget,
    skill: 'Shapes',
    icon: Icons.category_outlined,
    instruction: 'Drag each shape to its home!',
  ),
  Lesson(
    id: 'l03',
    title: 'Fill the Cup',
    mechanic: MechanicType.analogSlider,
    skill: 'Counting',
    icon: Icons.local_drink_outlined,
    instruction: 'Slide to fill the cup halfway!',
  ),
  Lesson(
    id: 'l04',
    title: 'Peek a Boo',
    mechanic: MechanicType.maskReveal,
    skill: 'Colors',
    icon: Icons.auto_fix_high_outlined,
    instruction: 'Scratch to reveal the animal!',
  ),
  Lesson(
    id: 'l05',
    title: 'Count the Stars',
    mechanic: MechanicType.physicsSpawn,
    skill: 'Counting',
    icon: Icons.star_outline,
    instruction: 'Pop 5 stars to count them!',
  ),
  Lesson(
    id: 'l06',
    title: 'Trace the A',
    mechanic: MechanicType.pathTracing,
    skill: 'Letters',
    icon: Icons.gesture_outlined,
    instruction: 'Trace the letter A!',
  ),
  Lesson(
    id: 'l07',
    title: 'Grow a Flower',
    mechanic: MechanicType.tapHold,
    skill: 'Nature',
    icon: Icons.local_florist_outlined,
    instruction: 'Hold to grow the flower tall!',
  ),
  Lesson(
    id: 'l08',
    title: 'Bubble Pop',
    mechanic: MechanicType.physicsSpawn,
    skill: 'Counting',
    icon: Icons.bubble_chart_outlined,
    instruction: 'Pop all the bubbles!',
  ),
  Lesson(
    id: 'l09',
    title: 'Sort the Blocks',
    mechanic: MechanicType.dragTarget,
    skill: 'Shapes',
    icon: Icons.widgets_outlined,
    instruction: 'Drag the blocks to match!',
  ),
  Lesson(
    id: 'l10',
    title: 'Trace the B',
    mechanic: MechanicType.pathTracing,
    skill: 'Letters',
    icon: Icons.draw_outlined,
    instruction: 'Trace the letter B!',
  ),
];

/// Costumes the child can earn. `starCost` gates the unlock.
const kCostumes = <Costume>[
  Costume(id: 'c_hat_wizard', name: 'Wizard Hat', category: 'Hats', starCost: 0, color: Color(0xFF6B4EFF)),
  Costume(id: 'c_hat_party', name: 'Party Hat', category: 'Hats', starCost: 3, color: Color(0xFFFF6FA5)),
  Costume(id: 'c_hat_crown', name: 'Gold Crown', category: 'Hats', starCost: 8, color: Color(0xFFFFB020)),
  Costume(id: 'c_cape_hero', name: 'Hero Cape', category: 'Capes', starCost: 5, color: Color(0xFFDC2626)),
  Costume(id: 'c_cape_star', name: 'Star Cape', category: 'Capes', starCost: 10, color: Color(0xFF3D5AFE)),
  Costume(id: 'c_shoe_boot', name: 'Rain Boots', category: 'Shoes', starCost: 4, color: Color(0xFF16A34A)),
  Costume(id: 'c_shoe_sneaker', name: 'Sneakers', category: 'Shoes', starCost: 6, color: Color(0xFF0EA5C4)),
  Costume(id: 'c_pet_owl', name: 'Owl Pal', category: 'Pets', starCost: 7, color: Color(0xFF815600)),
  Costume(id: 'c_pet_bunny', name: 'Bunny Pal', category: 'Pets', starCost: 12, color: Color(0xFFF5477E)),
];

const kCostumeCategories = <String>['Hats', 'Capes', 'Shoes', 'Pets'];
