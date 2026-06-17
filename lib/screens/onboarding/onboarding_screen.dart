import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/user_model.dart';
import '../../providers/user_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  
  int _currentPage = 0;
  String _gender = 'Nam';
  String? _avatarPath;
  String? _coverPath;
  
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage == 0 && _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên của bạn')),
      );
      return;
    }
    
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }
  
  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _pickImage(bool isAvatar) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isAvatar) {
          _avatarPath = image.path;
        } else {
          _coverPath = image.path;
        }
      });
    }
  }

  Future<void> _finishOnboarding() async {
    final userProvider = context.read<UserProvider>();
    
    final user = UserModel(
      name: _nameController.text.trim(),
      gender: _gender,
      streak: 0,
      downloadDate: DateTime.now(),
    );
    
    await userProvider.saveUser(user);
    
    if (_avatarPath != null) {
      await userProvider.updateAvatar(_avatarPath!);
    }
    if (_coverPath != null) {
      await userProvider.updateCover(_coverPath!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button or placeholder
                  if (_currentPage > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: _prevPage,
                    ).animate().fadeIn()
                  else
                    const SizedBox(width: 48),
                    
                  // Progress indicator
                  Row(
                    children: List.generate(3, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: isActive ? 24 : 8,
                        decoration: BoxDecoration(
                          color: isActive 
                              ? (isDark ? Colors.white : Colors.black)
                              : (isDark ? Colors.white24 : Colors.black12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  
                  // Skip button or placeholder
                  if (_currentPage < 2)
                    TextButton(
                      onPressed: _nextPage,
                      child: const Text(AppStrings.onboardingSkip),
                    ).animate().fadeIn()
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),
            
            // Page Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  _buildStep1(isDark),
                  _buildStep2(isDark),
                  _buildStep3(isDark),
                ],
              ),
            ),
            
            // Bottom Action
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _currentPage == 2 ? AppStrings.onboardingFinish : AppStrings.onboardingNext,
                  ),
                ),
              ).animate(target: _currentPage == 2 ? 1 : 0)
                .scaleXY(end: 1.05, duration: 200.ms, curve: Curves.easeOut)
                .then()
                .scaleXY(end: 1.0 / 1.05, duration: 200.ms, curve: Curves.easeIn),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Xin chào! 👋',
            style: AppTextStyles.displayLarge(context),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 8),
          Text(
            AppStrings.appSlogan,
            style: AppTextStyles.bodyLarge(context).copyWith(
              fontStyle: FontStyle.italic,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 100.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 48),
          
          Text(AppStrings.onboardingName, style: AppTextStyles.labelLarge(context))
              .animate().fadeIn(duration: 400.ms, delay: 200.ms),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: AppStrings.onboardingNameHint,
              filled: true,
              fillColor: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            style: AppTextStyles.bodyLarge(context),
          ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(begin: 0.1, end: 0),
          
          const SizedBox(height: 32),
          Text(AppStrings.onboardingGender, style: AppTextStyles.labelLarge(context))
              .animate().fadeIn(duration: 400.ms, delay: 400.ms),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildGenderChip('Nam', isDark),
              const SizedBox(width: 12),
              _buildGenderChip('Nữ', isDark),
              const SizedBox(width: 12),
              _buildGenderChip('Khác', isDark),
            ],
          ).animate().fadeIn(duration: 400.ms, delay: 500.ms).slideX(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  Widget _buildGenderChip(String gender, bool isDark) {
    final isSelected = _gender == gender;
    final primary = isDark ? Colors.white : Colors.black;
    final surface = isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _gender = gender),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primary : surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected ? (isDark ? AppColors.elevatedShadowDark : AppColors.elevatedShadowLight) : [],
          ),
          alignment: Alignment.center,
          child: Text(
            gender,
            style: AppTextStyles.labelLarge(context).copyWith(
              color: isSelected 
                  ? (isDark ? Colors.black : Colors.white)
                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep2(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        children: [
          Text(
            AppStrings.onboardingStep2Title,
            style: AppTextStyles.displayMedium(context),
          ).animate().fadeIn().slideY(begin: 0.1, end: 0),
          const SizedBox(height: 16),
          Text(
            'Chọn một bức ảnh thật đẹp nhé!',
            style: AppTextStyles.bodyLarge(context),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 48),
          
          GestureDetector(
            onTap: () => _pickImage(true),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                    boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
                    image: _avatarPath != null
                        ? DecorationImage(
                            image: FileImage(File(_avatarPath!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _avatarPath == null
                      ? Icon(
                          Icons.person_rounded,
                          size: 64,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white : Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      size: 20,
                      color: isDark ? Colors.black : Colors.white,
                    ),
                  ),
                ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                 .scaleXY(begin: 1.0, end: 1.1, duration: 1000.ms),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).scaleXY(begin: 0.8, end: 1.0, curve: Curves.easeOutBack),
        ],
      ),
    );
  }

  Widget _buildStep3(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        children: [
          Text(
            AppStrings.onboardingStep3Title,
            style: AppTextStyles.displayMedium(context),
          ).animate().fadeIn().slideY(begin: 0.1, end: 0),
          const SizedBox(height: 48),
          
          GestureDetector(
            onTap: () => _pickImage(false),
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isDark ? AppColors.cardShadowDark : AppColors.cardShadowLight,
                image: _coverPath != null
                    ? DecorationImage(
                        image: FileImage(File(_coverPath!)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (_coverPath == null)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_rounded,
                          size: 48,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tải ảnh bìa lên',
                          style: AppTextStyles.labelLarge(context),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 100.ms).scaleXY(begin: 0.9, end: 1.0, curve: Curves.easeOut),
        ],
      ),
    );
  }
}
