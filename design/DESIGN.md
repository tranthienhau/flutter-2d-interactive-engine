# Bloom Play - Design System

Preschool 2D interactive learning app. Bright, playful, rounded, big touch targets, one friendly character mascot. Light theme only. Everything reads joyful and safe for little kids.

## Frame + safe areas
- Mobile frame 393x852 (iPhone 16/17). Also must scale to tablet, so keep generous margins.
- Respect safe areas: top ~59px, bottom ~34px. No tappable content under the status bar or home indicator.

## Color (use these EXACT hexes - do NOT use generic violet #6366F1 or flat grey #6B7280)
- Background (tinted near-white): `#F6F4FD`
- Surface (cards/sheets): `#FFFFFF`
- Surface alt (grouped rows): `#EFEBFB`
- Accent (primary brand, friendly violet): `#6B4EFF`
- Accent tint (fills/badges/selected): `#E7E1FF`
- Accent pressed: `#5A3FE0`
- Support (secondary/charts/illustration, warm amber): `#FFB020`
- Text primary (near-ink, violet-tinted): `#1A1530`
- Text secondary: `#5B5473`
- Text tertiary (hint): `#938CAD`
- Border (hairline): `#E6E1F2`
- Success `#16A34A`, Warning `#D97706`, Danger `#DC2626`

Neutrals are tinted cool toward the violet accent. Never pure grey.

## Typography
- Font family: **Baloo 2** across ALL text (rounded, friendly, kid-appropriate). Single family only.
- Display: 32 / 700 / -0.02em - screen titles, hero numbers
- Title: 20 / 600 - section headers, card titles
- Body: 16 / 400 - default text
- Label: 14 / 500 - buttons, tabs, chips
- Caption: 13 / 500 - metadata

## Radius, spacing, elevation
- Radius: card 20, control 14, input 12, pill 999. Very rounded, no sharp corners.
- Spacing: 8pt scale (4,8,12,16,24,32); screen edge padding 20px; generous vertical rhythm.
- Elevation: soft only - card = 0 1px 2px rgba(0,0,0,.04) + 0 8px 24px rgba(0,0,0,.06). No hard/black shadows.

## Icons
- ONE rounded outline icon set (Phosphor / Lucide style), 24px, playful and friendly. Do not mix outline + filled.

## Gradient + focal rules
- Soft accent->support gradient (violet #6B4EFF -> amber #FFB020) on hero surfaces: onboarding, lesson-complete celebration, and primary featured/CTA cards. Keep the tab bar flat white.
- One bold focal element per screen: a big hero card, mascot, award number, or progress ring that owns the visual weight. Everything else quiet and supporting.

## Controls (one spec, reused everywhere)
- Primary button: big rounded pill (radius 999), accent violet `#6B4EFF` fill, white bold label, soft shadow, min height 56pt.
- Secondary button: accent-tint `#E7E1FF` fill with violet `#6B4EFF` text, pill shape.
- Card: 20px radius, white surface, soft shadow.
- Chip: pill, category tags in amber `#FFB020` tint with dark text.
- Input: 12px radius, border `#E6E1F2`, focus = accent violet ring.
- All tap targets >=56pt (little fingers).

## Shared components (reuse verbatim on every screen)
- **Bottom tab bar** (flat white, soft top hairline): EXACTLY 4 tabs in THIS order: Home, Play, Closet, Progress.
  - Icons (rounded outline): Home = house, Play = shapes/grid, Closet = shirt/hanger, Progress = star-chart.
  - Active tab: accent violet `#6B4EFF` icon + label, with a soft `#E7E1FF` pill highlight behind the active icon.
  - Inactive tabs: muted violet-grey `#938CAD`.
  - Do NOT rename, reorder, add, or remove tabs. Screens marked nav:none render NO tab bar.
- **Top playful bar** (core screens only): round mascot avatar chip on the left; child name + gold star count on the right. Hidden on fullscreen lesson/celebration/settings screens.

## Mood
Joyful, warm, safe, rounded, generous. Realistic kid-app mock content (lesson names, star counts, costume names), never lorem ipsum. AAA-quality polish.
