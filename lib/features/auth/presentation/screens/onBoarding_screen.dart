import 'package:flutter/material.dart';
import 'package:spotter/features/auth/presentation/widgets/step_container.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController pageController = PageController();
  int currIndex = 0;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('SETUP FLOW'),
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.only(left: 5),
          child: Image.asset('./lib/core/assets/images/logo.png'),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'step ${currIndex + 1} out of 6',
                  style: text.titleSmall,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 10,
                child: Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,

                    itemCount: 6,
                    itemBuilder: (context, index) => SizedBox(
                      width: constraints.maxWidth / 6,
                      child: StepContainer(isActive: index <= currIndex),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView(
                  controller: pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (value) {
                    currIndex = value;
                    setState(() {});
                  },
                  children: const [
                    Text('1'),
                    Text('2'),
                    Text('3'),
                    Text('4'),
                    Text('5'),
                    Text('6'),
                  ],
                ),
              ),
              const Spacer(),
              Expanded(
                child: Row(
                  children: [
                    if (currIndex > 0)
                      FilledButton.icon(
                        onPressed: () {
                          pageController.previousPage(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                          );
                        },
                        label: const Text('Back'),
                        icon: const Icon(Icons.arrow_back),
                        iconAlignment: IconAlignment.start,
                        style: FilledButton.styleFrom(
                          backgroundColor: cs.secondaryContainer,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    const Spacer(),
                    if (currIndex < 5)
                      SizedBox(
                        width: constraints.maxWidth * 0.7,
                        child: FilledButton.icon(
                          onPressed: () {
                            pageController.nextPage(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeIn,
                            );
                          },
                          label: const Text('Continue'),
                          icon: const Icon(Icons.arrow_forward),
                          iconAlignment: IconAlignment.end,
                        ),
                      ),

                    if (currIndex == 5)
                      SizedBox(
                        width: constraints.maxWidth * 0.7,
                        child: FilledButton.icon(
                          onPressed: () {},
                          label: const Text('Finish'),
                          icon: const Icon(Icons.arrow_forward),
                          iconAlignment: IconAlignment.end,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
