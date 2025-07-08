import 'package:flutter/material.dart';
import '../theme/duolingo_theme.dart';
import '../widgets/pigeon_avatar.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  int _currentStep = 0;
  String? _selectedPersona;
  String? _selectedReligion;

  final List<String> _personas = ['Seeker', 'Practitioner', 'Curious'];
  final List<String> _religions = ['Islam', 'Christianity', 'Hinduism'];

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
        _controller.forward(from: 0);
      });
    } else {
      // TODO: Save onboarding state and navigate to home
      Navigator.pop(context);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _controller.forward(from: 0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DuolingoTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildProgressDots(),
              const SizedBox(height: 32),
              Expanded(
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildStepContent(),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    TextButton(
                      onPressed: _prevStep,
                      child: const Text('Back', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ElevatedButton(
                    onPressed: _canContinue() ? _nextStep : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DuolingoTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(_currentStep == 3 ? 'Get Started' : 'Next', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: _currentStep == index ? 18 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: _currentStep == index ? DuolingoTheme.primary : DuolingoTheme.secondary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const PigeonAvatar(size: 80),
            const SizedBox(height: 24),
            const Text('Welcome to SpiritGuide!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: DuolingoTheme.primary)),
            const SizedBox(height: 12),
            const Text('Your playful journey into world religions and spirituality starts here.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
          ],
        );
      case 1:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.psychology, color: DuolingoTheme.secondary, size: 64),
            const SizedBox(height: 24),
            const Text('Who are you?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ..._personas.map((persona) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: GestureDetector(
                onTap: () => setState(() => _selectedPersona = persona),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  decoration: BoxDecoration(
                    color: _selectedPersona == persona ? DuolingoTheme.primary : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: DuolingoTheme.primary.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(_selectedPersona == persona ? Icons.check_circle : Icons.circle_outlined, color: _selectedPersona == persona ? Colors.white : DuolingoTheme.primary),
                      const SizedBox(width: 16),
                      Text(persona, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _selectedPersona == persona ? Colors.white : DuolingoTheme.primary)),
                    ],
                  ),
                ),
              ),
            )),
          ],
        );
      case 2:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome, color: DuolingoTheme.accentPurple, size: 64),
            const SizedBox(height: 24),
            const Text('Choose a Religion', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ..._religions.map((religion) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: GestureDetector(
                onTap: () => setState(() => _selectedReligion = religion),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  decoration: BoxDecoration(
                    color: _selectedReligion == religion ? DuolingoTheme.accentPurple : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: DuolingoTheme.accentPurple.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(_selectedReligion == religion ? Icons.check_circle : Icons.circle_outlined, color: _selectedReligion == religion ? Colors.white : DuolingoTheme.accentPurple),
                      const SizedBox(width: 16),
                      Text(religion, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _selectedReligion == religion ? Colors.white : DuolingoTheme.accentPurple)),
                    ],
                  ),
                ),
              ),
            )),
          ],
        );
      case 3:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.celebration, color: DuolingoTheme.accentPink, size: 64),
            const SizedBox(height: 24),
            const Text('You’re all set!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: DuolingoTheme.accentPink)),
            const SizedBox(height: 12),
            Text('Persona: ${_selectedPersona ?? ''}\nReligion: ${_selectedReligion ?? ''}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            const Text('Let’s begin your journey!', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  bool _canContinue() {
    if (_currentStep == 1) return _selectedPersona != null;
    if (_currentStep == 2) return _selectedReligion != null;
    return true;
  }
} 