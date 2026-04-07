import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../users/models/user_model.dart';
import '../repositories/auth_repository.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;
  final void Function(UserModel updatedUser) onProfileUpdated;

  const EditProfileScreen({
    super.key,
    required this.user,
    required this.onProfileUpdated,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthRepository _repository = AuthRepository();

  // Controllers pre-filled with current data
  late final TextEditingController _fnameCtrl;
  late final TextEditingController _lnameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _passwordCtrl;
  late final TextEditingController _passwordConfirmCtrl;

  File? _pickedImage;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isPickingImage = false;

  @override
  void initState() {
    super.initState();
    _fnameCtrl = TextEditingController(text: widget.user.firstName ?? '');
    _lnameCtrl = TextEditingController(text: widget.user.lastName ?? '');
    _phoneCtrl = TextEditingController(text: widget.user.phone ?? '');
    _addressCtrl = TextEditingController(text: widget.user.address ?? '');
    _passwordCtrl = TextEditingController();
    _passwordConfirmCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _fnameCtrl.dispose();
    _lnameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _passwordCtrl.dispose();
    _passwordConfirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_isPickingImage) return;
    setState(() => _isPickingImage = true);
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
      );
      if (picked != null) {
        setState(() => _pickedImage = File(picked.path));
      }
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoading) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      // Only send changed fields
      final originalFname = widget.user.firstName ?? '';
      final originalLname = widget.user.lastName ?? '';
      final originalPhone = widget.user.phone ?? '';
      final originalAddress = widget.user.address ?? '';

      final updatedData = await _repository.updateProfile(
        fname: _fnameCtrl.text.trim() != originalFname ? _fnameCtrl.text.trim() : null,
        lname: _lnameCtrl.text.trim() != originalLname ? _lnameCtrl.text.trim() : null,
        phone: _phoneCtrl.text.trim() != originalPhone ? _phoneCtrl.text.trim() : null,
        address: _addressCtrl.text.trim() != originalAddress ? _addressCtrl.text.trim() : null,
        password: _passwordCtrl.text.isNotEmpty ? _passwordCtrl.text : null,
        passwordConfirmation: _passwordCtrl.text.isNotEmpty ? _passwordConfirmCtrl.text : null,
        imagePath: _pickedImage?.path,
      );

      // Update user locally from API response
      final updatedUser = UserModel.fromJson({
        ...{
          'id': widget.user.id,
          'fname': widget.user.firstName,
          'lname': widget.user.lastName,
          'email': widget.user.email,
          'phone': widget.user.phone,
          'address': widget.user.address,
          'profile_image': widget.user.profileImage,
          'role': widget.user.role,
          'email_verified_at': widget.user.emailVerifiedAt?.toIso8601String(),
          'created_at': widget.user.createdAt.toIso8601String(),
          'updated_at': widget.user.updatedAt.toIso8601String(),
        },
        ...updatedData,
      });

      widget.onProfileUpdated(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text('تم تحديث الملف الشخصي بنجاح', style: TextStyle(fontFamily: 'Cairo')),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceAll('Exception: ', '');

      // Handle 401 → redirect to login
      if (msg.contains('انتهت صلاحية الجلسة')) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(msg, style: const TextStyle(fontFamily: 'Cairo'))),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          action: SnackBarAction(
            label: 'إعادة المحاولة',
            textColor: Colors.white,
            onPressed: _submit,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('تعديل الملف الشخصي', style: AppTextStyles.h2),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: _isLoading
                ? const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    ),
                  )
                : TextButton(
                    onPressed: _submit,
                    child: Text(
                      'حفظ',
                      style: AppTextStyles.body1Bold.copyWith(color: AppColors.primary),
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Avatar Picker ──────────────────────────────────────────────
            _buildAvatarPicker(),
            const SizedBox(height: 24),

            // ── Name Section ───────────────────────────────────────────────
            _buildSection(
              title: 'الاسم',
              icon: Icons.person_rounded,
              children: [
                _buildField(
                  controller: _fnameCtrl,
                  label: 'الاسم الأول',
                  hint: 'أدخل الاسم الأول',
                  icon: Icons.badge_outlined,
                  validator: (v) => v != null && v.trim().isEmpty ? 'الاسم الأول مطلوب' : null,
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: _lnameCtrl,
                  label: 'الاسم الأخير',
                  hint: 'أدخل الاسم الأخير',
                  icon: Icons.badge_outlined,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Contact Section ────────────────────────────────────────────
            _buildSection(
              title: 'بيانات التواصل',
              icon: Icons.contact_phone_rounded,
              children: [
                _buildField(
                  controller: _phoneCtrl,
                  label: 'رقم الهاتف',
                  hint: 'أدخل رقم الهاتف',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: _addressCtrl,
                  label: 'العنوان',
                  hint: 'أدخل العنوان',
                  icon: Icons.location_on_outlined,
                  maxLines: 2,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Password Section ───────────────────────────────────────────
            _buildSection(
              title: 'تغيير كلمة المرور (اختياري)',
              icon: Icons.lock_rounded,
              children: [
                _buildPasswordField(
                  controller: _passwordCtrl,
                  label: 'كلمة المرور الجديدة',
                  hint: 'اتركه فارغاً إذا لا تريد التغيير',
                  obscure: _obscurePassword,
                  onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                  validator: (v) {
                    if (v != null && v.isNotEmpty && v.length < 8) {
                      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  controller: _passwordConfirmCtrl,
                  label: 'تأكيد كلمة المرور',
                  hint: 'أعد إدخال كلمة المرور الجديدة',
                  obscure: _obscureConfirm,
                  onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  validator: (v) {
                    if (_passwordCtrl.text.isNotEmpty && v != _passwordCtrl.text) {
                      return 'كلمتا المرور غير متطابقتين';
                    }
                    return null;
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ── Submit Button ──────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : Text(
                        'حفظ التغييرات',
                        style: AppTextStyles.body1Bold.copyWith(color: Colors.black, fontSize: 16),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ─── Avatar Picker ─────────────────────────────────────────────────────────
  Widget _buildAvatarPicker() {
    final imageUrl = widget.user.fullProfileImageUrl;
    return Center(
      child: Stack(
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2.5),
              color: AppColors.card,
            ),
            child: ClipOval(
              child: _pickedImage != null
                  ? Image.file(_pickedImage!, fit: BoxFit.cover)
                  : imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, e, s) => _avatarFallback(),
                        )
                      : _avatarFallback(),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 2),
                ),
                child: _isPickingImage
                    ? const Padding(
                        padding: EdgeInsets.all(7),
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : const Icon(Icons.camera_alt_rounded, color: Colors.black, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback() {
    final initials =
        '${widget.user.firstName?.isNotEmpty == true ? widget.user.firstName![0] : ''}${widget.user.lastName?.isNotEmpty == true ? widget.user.lastName![0] : ''}'
            .toUpperCase();
    return Container(
      color: AppColors.primary.withValues(alpha: 0.15),
      child: Center(
        child: Text(
          initials.isNotEmpty ? initials : '??',
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            fontFamily: 'Cairo',
          ),
        ),
      ),
    );
  }

  // ─── Section Card ──────────────────────────────────────────────────────────
  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Text(title, style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  // ─── Text Field ────────────────────────────────────────────────────────────
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: AppTextStyles.body1.copyWith(color: AppColors.textPrimary),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
        labelStyle: AppTextStyles.caption,
        hintStyle: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }

  // ─── Password Field ────────────────────────────────────────────────────────
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: AppTextStyles.body1.copyWith(color: AppColors.textPrimary),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.textSecondary,
            size: 20,
          ),
          onPressed: onToggle,
        ),
        labelStyle: AppTextStyles.caption,
        hintStyle: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }
}
