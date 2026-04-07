import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/user_model.dart';
import '../providers/users_provider.dart';

class AdminEditUserScreen extends StatefulWidget {
  final UserModel user;

  const AdminEditUserScreen({super.key, required this.user});

  @override
  State<AdminEditUserScreen> createState() => _AdminEditUserScreenState();
}

class _AdminEditUserScreenState extends State<AdminEditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _fnameCtrl;
  late final TextEditingController _lnameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _passwordCtrl;
  late final TextEditingController _passwordConfirmCtrl;

  File? _pickedImage;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isPickingImage = false;

  @override
  void initState() {
    super.initState();
    _fnameCtrl = TextEditingController(text: widget.user.firstName ?? '');
    _lnameCtrl = TextEditingController(text: widget.user.lastName ?? '');
    _emailCtrl = TextEditingController(text: widget.user.email);
    _phoneCtrl = TextEditingController(text: widget.user.phone ?? '');
    _addressCtrl = TextEditingController(text: widget.user.address ?? '');
    _passwordCtrl = TextEditingController();
    _passwordConfirmCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _fnameCtrl.dispose();
    _lnameCtrl.dispose();
    _emailCtrl.dispose();
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

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<UsersProvider>();
    if (provider.isLoading) return;

    FocusScope.of(context).unfocus();

    // Check what actually changed
    final fnameChanged = _fnameCtrl.text.trim() != (widget.user.firstName ?? '');
    final lnameChanged = _lnameCtrl.text.trim() != (widget.user.lastName ?? '');
    final emailChanged = _emailCtrl.text.trim() != widget.user.email;
    final phoneChanged = _phoneCtrl.text.trim() != (widget.user.phone ?? '');
    final addressChanged = _addressCtrl.text.trim() != (widget.user.address ?? '');
    final pwdChanged = _passwordCtrl.text.isNotEmpty;
    final imgChanged = _pickedImage != null;

    if (!fnameChanged && !lnameChanged && !emailChanged && !phoneChanged && !addressChanged && !pwdChanged && !imgChanged) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('لم تقم بإجراء أي تغييرات', style: TextStyle(fontFamily: 'Cairo')),
          backgroundColor: AppColors.textSecondary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Capture context before async gap
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final success = await provider.updateUser(
      widget.user.id,
      fname: fnameChanged ? _fnameCtrl.text.trim() : null,
      lname: lnameChanged ? _lnameCtrl.text.trim() : null,
      email: emailChanged ? _emailCtrl.text.trim() : null,
      password: pwdChanged ? _passwordCtrl.text : null,
      passwordConfirmation: pwdChanged ? _passwordConfirmCtrl.text : null,
      phone: phoneChanged ? _phoneCtrl.text.trim() : null,
      address: addressChanged ? _addressCtrl.text.trim() : null,
      imagePath: _pickedImage?.path,
    );

    if (!mounted) return;

    if (success) {
      messenger.showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text('تم تحديث بيانات المستخدم بنجاح', style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      navigator.pop();
    } else {
      final msg = provider.errorMessage ?? 'فشل التحديث';
      
      if (msg.contains('انتهت صلاحية الجلسة')) {
        navigator.pushNamedAndRemoveUntil('/login', (r) => false);
        return;
      }

      messenger.showSnackBar(
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
            label: 'محاولة أخرى',
            textColor: Colors.white,
            onPressed: _submit,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<UsersProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('تعديل المستخدم', style: AppTextStyles.h2),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: isLoading
                ? const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    ),
                  )
                : TextButton(
                    onPressed: _submit,
                    child: Text('حفظ', style: AppTextStyles.body1Bold.copyWith(color: AppColors.primary)),
                  ),
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          children: [
            _buildAvatarPicker(),
            const SizedBox(height: 24),

            _buildSection(
              title: 'البيانات الأساسية',
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
                  validator: (v) => v != null && v.trim().isEmpty ? 'الاسم الأخير مطلوب' : null,
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildSection(
              title: 'بيانات التواصل',
              icon: Icons.contact_mail_rounded,
              children: [
                _buildField(
                  controller: _emailCtrl,
                  label: 'البريد الإلكتروني',
                  hint: 'example@domain.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'البريد الإلكتروني مطلوب';
                    if (!_isValidEmail(v.trim())) return 'صيغة البريد الإلكتروني غير صحيحة';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
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

            _buildSection(
              title: 'تغيير كلمة المرور',
              icon: Icons.lock_rounded,
              children: [
                _buildPasswordField(
                  controller: _passwordCtrl,
                  label: 'كلمة المرور الجديدة',
                  hint: 'للتغيير فقط (اختياري)',
                  obscure: _obscurePassword,
                  onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                  validator: (v) {
                    if (v != null && v.isNotEmpty && v.length < 8) {
                      return 'كلمة المرور يجب أن لا تقل عن 8 أحرف';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  controller: _passwordConfirmCtrl,
                  label: 'تأكيد كلمة المرور',
                  hint: 'أعد إدخال كلمة المرور',
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

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 24, height: 24,
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                      )
                    : Text('حفظ التعديلات', style: AppTextStyles.body1Bold.copyWith(color: Colors.black, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ─── UI Helpers ────────────────────────────────────────────────────────────

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
                          errorBuilder: (_, err, stack) => _avatarFallback(),
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
    final initials = '${widget.user.firstName?.isNotEmpty == true ? widget.user.firstName![0] : ''}${widget.user.lastName?.isNotEmpty == true ? widget.user.lastName![0] : ''}'.toUpperCase();
    return Container(
      color: AppColors.primary.withValues(alpha: 0.15),
      child: Center(
        child: Text(
          initials.isNotEmpty ? initials : '??',
          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.primary, fontFamily: 'Cairo'),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required IconData icon, required List<Widget> children}) {
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.error)),
      ),
    );
  }

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
          icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textSecondary, size: 20),
          onPressed: onToggle,
        ),
        labelStyle: AppTextStyles.caption,
        hintStyle: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.error)),
      ),
    );
  }
}
