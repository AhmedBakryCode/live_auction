import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../dashboard/widgets/sidebar_widget.dart';
import '../repositories/auctions_repository.dart';

class CreateAuctionScreen extends StatefulWidget {
  const CreateAuctionScreen({super.key});

  @override
  State<CreateAuctionScreen> createState() => _CreateAuctionScreenState();
}

class _CreateAuctionScreenState extends State<CreateAuctionScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startPriceController = TextEditingController();
  
  DateTime? _startDate;
  DateTime? _endDate;
  File? _imageFile;
  
  bool _isLoading = false;
  final AuctionsRepository _repository = AuctionsRepository();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _startPriceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, 
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickDateTime(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      if (!mounted) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          final selectedDateTime = DateTime(
            date.year, date.month, date.day, time.hour, time.minute,
          );
          if (isStart) {
            _startDate = selectedDateTime;
          } else {
            _endDate = selectedDateTime;
          }
        });
      }
    }
  }
  
  String _formatDateForApi(DateTime? date) {
    if (date == null) return '';
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
  }

  String _formatDateForUI(DateTime? date) {
    if (date == null) return '';
    return DateFormat('yyyy/MM/dd hh:mm a').format(date);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار تاريخ البدء والانتهاء')),
      );
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تاريخ الانتهاء يجب أن يكون بعد تاريخ البدء')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final auction = await _repository.createAuction(
        title: _titleController.text,
        description: _descriptionController.text,
        startPrice: _startPriceController.text,
        startTime: _formatDateForApi(_startDate),
        endTime: _formatDateForApi(_endDate),
        imagePath: _imageFile?.path,
      );
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم إنشاء المزاد بنجاح: ${auction.title}'), backgroundColor: Colors.green),
      );
      
      // Clear form after success
      _titleController.clear();
      _descriptionController.clear();
      _startPriceController.clear();
      setState(() {
        _startDate = null;
        _endDate = null;
        _imageFile = null;
      });
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const Drawer(width: 300, child: SidebarWidget()),
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text('إنشاء مزاد جديد', style: AppTextStyles.h2),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'بيانات المنتج'),
                    _buildField(
                      label: 'اسم المنتج',
                      hint: 'مثال: ساعة رولكس أصلية',
                      controller: _titleController,
                      validator: (value) => value == null || value.trim().isEmpty ? 'حقل مطلوب' : null,
                    ),
                    const SizedBox(height: 20),
                    _buildField(
                      label: 'الوصف التفصيلي',
                      hint: 'أدخل تفاصيل حالة المنتج...',
                      controller: _descriptionController,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 20),
                    _buildField(
                      label: 'السعر المبدئي',
                      hint: '\$ 0.00',
                      controller: _startPriceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                         if (value == null || value.trim().isEmpty) return 'حقل مطلوب';
                         if (double.tryParse(value) == null) return 'يجب أن يكون رقماً صالحاً';
                         return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _pickDateTime(true),
                            child: _buildReadOnlyField(
                              label: 'تاريخ البدء',
                              text: _startDate != null ? _formatDateForUI(_startDate) : 'اختر تاريخ',
                              icon: Icons.calendar_today_rounded,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                           child: GestureDetector(
                            onTap: () => _pickDateTime(false),
                            child: _buildReadOnlyField(
                              label: 'تاريخ الانتهاء',
                              text: _endDate != null ? _formatDateForUI(_endDate) : 'اختر تاريخ',
                              icon: Icons.calendar_today_rounded,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const SectionHeader(title: 'الصورة الرئيسية'),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        decoration: BoxDecoration(
                          color: AppColors.background.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                        ),
                        child: _imageFile != null
                            ? Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(_imageFile!, height: 150, fit: BoxFit.cover),
                                  ),
                                  const SizedBox(height: 12),
                                  Text('تغيير الصورة', style: AppTextStyles.body1Bold.copyWith(color: AppColors.primary)),
                                ],
                              )
                            : Column(
                                children: [
                                  const Icon(Icons.add_a_photo_outlined, size: 40, color: AppColors.primary),
                                  const SizedBox(height: 12),
                                  Text('انقر أو اسحب الصورة هنا', style: AppTextStyles.body1Bold),
                                  Text('JPG, PNG بحد أقصى 5 ميجابايت', style: AppTextStyles.caption),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.black,
                          textStyle: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator(color: Colors.black))
                            : const Text('بدء المزاد الآن'),
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

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.body1Bold.copyWith(fontSize: 13)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: AppTextStyles.body1,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.body2.copyWith(color: AppColors.textSecondary.withValues(alpha: 0.5)),
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red, width: 1)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red, width: 1)),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String text,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.body1Bold.copyWith(fontSize: 13)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
             color: AppColors.background,
             borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
               Icon(icon, size: 18, color: AppColors.primary),
               const SizedBox(width: 12),
               Expanded(
                 child: Text(text, style: AppTextStyles.body1, maxLines: 1, overflow: TextOverflow.ellipsis),
               ),
            ],
          ),
        ),
      ],
    );
  }
}
