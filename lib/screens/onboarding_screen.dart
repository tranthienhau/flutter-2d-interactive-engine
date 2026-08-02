import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/persistence/local_store.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Onboarding - pick a buddy. Matches design/01-onboarding-pick-character.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _buddies = [
    (id: 'bramble', name: 'Bramble', color: Color(0xFFF08A3C)),
    (id: 'pip', name: 'Pip', color: Color(0xFF127C71)),
    (id: 'momo', name: 'Momo', color: Color(0xFF9A6A4B)),
  ];
  int _selected = 0;

  Future<void> _start() async {
    final store = ref.read(localStoreProvider);
    await store.setBuddy(_buddies[_selected].id);
    await store.setChildName(_buddies[_selected].name);
    await store.setOnboarded();
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.42,
            width: double.infinity,
            decoration: const BoxDecoration(gradient: kHeroGradient),
            child: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Pick your buddy!',
                    textAlign: TextAlign.center,
                    style: AppText.display.copyWith(
                        color: Colors.white, fontSize: 34),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < _buddies.length; i++)
                GestureDetector(
                  onTap: () => setState(() => _selected = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selected == i
                            ? AppColors.accent
                            : Colors.transparent,
                        width: 4,
                      ),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: _selected == i ? 46 : 40,
                          backgroundColor:
                              _buddies[i].color.withValues(alpha: 0.18),
                          child: Icon(Icons.pets,
                              size: 44, color: _buddies[i].color),
                        ),
                        const SizedBox(height: 8),
                        Text(_buddies[i].name, style: AppText.label),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const Spacer(),
          Text('You can change this later.', style: AppText.caption),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
            child: SizedBox(
              width: double.infinity,
              child: PillButton(label: 'Start Playing', onTap: _start),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small helper used by the router to decide the first screen.
bool hasOnboarded(LocalStore store) => store.onboarded;
