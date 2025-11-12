import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:laporin/constants/colors.dart';
import 'package:laporin/constants/text_styles.dart';
import 'package:laporin/models/onboarding_model.dart';
import 'package:laporin/providers/onboarding_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Consumer<OnboardingProvider>(
          builder: (context, onboardingProvider, child) {
            return Column(
              children: [
                // Skip Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: () async {
                        await onboardingProvider.completeOnboarding();
                        if (context.mounted) {
                          context.go('/login');
                        }
                      },
                      child: Text(
                        'Lewati',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // PageView
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      onboardingProvider.setCurrentPage(
                        index,
                        onboardingData.length,
                      );
                    },
                    itemCount: onboardingData.length,
                    itemBuilder: (context, index) {
                      return _OnboardingPage(
                        data: onboardingData[index],
                      );
                    },
                  ),
                ),

                // Page Indicator
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: onboardingData.length,
                    effect: WormEffect(
                      dotColor: AppColors.greyLight,
                      activeDotColor: AppColors.primary,
                      dotHeight: 12,
                      dotWidth: 12,
                      spacing: 16,
                    ),
                  ),
                ),

                // Next/Get Started Button
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (onboardingProvider.isLastPage) {
                          await onboardingProvider.completeOnboarding();
                          if (context.mounted) {
                            context.go('/login');
                          }
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        onboardingProvider.isLastPage
                            ? 'Mulai'
                            : 'Lanjut',
                        style: AppTextStyles.button,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingModel data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image/Icon Placeholder
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                data.image,
                style: const TextStyle(fontSize: 120),
              ),
            ),
          ),
          const SizedBox(height: 48),
          
          // Title
          Text(
            data.title,
            style: AppTextStyles.h2.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // Description
          Text(
            data.description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
