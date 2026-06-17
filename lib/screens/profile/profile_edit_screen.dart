import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/user_model.dart';
import '../../providers/user_provider.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  String? _avatarPath;
  String? _coverPath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final userProvider = context.read<UserProvider>();
    if (userProvider.user != null) {
      _nameController.text = userProvider.user!.name;
    }
    _avatarPath = userProvider.getAvatarFullPath();
    _coverPath = userProvider.getCoverFullPath();
  }

  Future<void> _pickAvatar() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _avatarPath = image.path);
    }
  }

  Future<void> _pickCover() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _coverPath = image.path);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    final provider = context.read<UserProvider>();
    final currentUser = provider.user;
    if (currentUser == null) return;
    
    // Save info
    final updatedUser = currentUser.copyWith(name: _nameController.text.trim());
    await provider.updateUser(updatedUser);
    
    // Save images if they are different from existing full paths
    if (_avatarPath != null && _avatarPath != provider.getAvatarFullPath()) {
      await provider.updateAvatar(_avatarPath!);
    }
    if (_coverPath != null && _coverPath != provider.getCoverFullPath()) {
      await provider.updateCover(_coverPath!);
    }
    
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(title: const Text('Sửa thông tin')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ảnh bìa', style: AppTextStyles.headlineSmall(context)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickCover,
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                    image: _coverPath != null
                        ? DecorationImage(image: FileImage(File(_coverPath!)), fit: BoxFit.cover)
                        : null,
                  ),
                  child: _coverPath == null 
                      ? const Center(child: Icon(Icons.add_photo_alternate_rounded, size: 40))
                      : null,
                ),
              ),
              const SizedBox(height: 24),
              
              Text('Ảnh đại diện', style: AppTextStyles.headlineSmall(context)),
              const SizedBox(height: 8),
              Center(
                child: GestureDetector(
                  onTap: _pickAvatar,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.info, width: 3),
                          color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                          image: _avatarPath != null
                              ? DecorationImage(image: FileImage(File(_avatarPath!)), fit: BoxFit.cover)
                              : null,
                        ),
                        child: _avatarPath == null ? const Icon(Icons.person, size: 60) : null,
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.info,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              Text('Tên của bạn', style: AppTextStyles.headlineSmall(context)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Nhập tên...',
                  filled: true,
                  fillColor: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Vui lòng nhập tên' : null,
              ),
              const SizedBox(height: 48),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Lưu thay đổi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
