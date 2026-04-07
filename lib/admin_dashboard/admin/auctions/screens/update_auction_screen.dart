import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';
import '../models/auction_model.dart';
import '../repositories/auctions_repository.dart';

class UpdateAuctionScreen extends StatefulWidget {
  final AuctionModel auction;

  const UpdateAuctionScreen({super.key, required this.auction});

  @override
  State<UpdateAuctionScreen> createState() => _UpdateAuctionScreenState();
}

class _UpdateAuctionScreenState extends State<UpdateAuctionScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _startPriceController;

  DateTime? _startDate;
  DateTime? _endDate;
  File? _imageFile;

  bool _isLoading = false;
  final AuctionsRepository _repository = AuctionsRepository();

  @override
  void initState() {
    super.initState();
    // Pre-fill existing auction data
    _titleController = TextEditingController(text: widget.auction.title);
    _descriptionController = TextEditingController(text: widget.auction.description ?? '');
    _startPriceController = TextEditingController(text: widget.auction.startPrice.toString());

    _startDate = DateTime.tryParse(widget.auction.startTime);
    _endDate = DateTime.tryParse(widget.auction.endTime);
  }

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
      initialDate: isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2000), // Allowing past dates just in case the original date was in the past
      lastDate: DateTime(2030),
    );
    if (date != null) {
      if (!mounted) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now()),
        ),
      );
      if (time != null) {
        setState(() {
          final selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
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

  bool _hasChanges() {
    if (_titleController.text != widget.auction.title) return true;
    if (_descriptionController.text != (widget.auction.description ?? '')) return true;
    if (_startPriceController.text != widget.auction.startPrice.toString()) return true;
    if (_startDate != DateTime.tryParse(widget.auction.startTime)) return true;
    if (_endDate != DateTime.tryParse(widget.auction.endTime)) return true;
    if (_imageFile != null) return true;
    return false;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار تاريخ البدء والانتهاء')),
      );
      return;
    }

    // Validate date logic (start < end)
    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تاريخ الانتهاء يجب أن يكون بعد تاريخ البدء'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_hasChanges()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لم تقم بأي تعديلات'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Send ONLY changed fields
      final updatedTitle = _titleController.text != widget.auction.title ? _titleController.text : null;
      final updatedDesc = _descriptionController.text != (widget.auction.description ?? '') ? _descriptionController.text : null;
      final updatedPrice = _startPriceController.text != widget.auction.startPrice.toString() ? _startPriceController.text : null;
      
      final updatedStartDate = _startDate != DateTime.tryParse(widget.auction.startTime) ? _formatDateForApi(_startDate) : null;
      final updatedEndDate = _endDate != DateTime.tryParse(widget.auction.endTime) ? _formatDateForApi(_endDate) : null;

      final updatedAuction = await _repository.updateAuction(
        widget.auction.id,
        title: updatedTitle,
        description: updatedDesc,
        startPrice: updatedPrice,
        startTime: updatedStartDate,
        endTime: updatedEndDate,
        imagePath: _imageFile?.path,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تحديث المزاد بنجاح: ${updatedAuction.title}'),
          backgroundColor: Colors.green,
        ),
      );

      // Return the updated model back to previous screen to update UI instantly
      Navigator.pop(context, updatedAuction);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'إعادة المحاولة',
            textColor: Colors.white,
            onPressed: _submit,
          ),
        ),
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
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('تحديث بيانات المزاد', style: AppTextStyles.h2),
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
                    const SectionHeader(title: 'تحديث الصورة (اختياري)'),
                    _buildImagePreview(),
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
                          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                        ),
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator(color: Colors.black))
                            : const Text('حفظ التعديلات'),
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

  Widget _buildImagePreview() {
    return GestureDetector(
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
                  Text('تغيير الصورة المحددة', style: AppTextStyles.body1Bold.copyWith(color: AppColors.primary)),
                ],
              )
            : widget.auction.imageUrl != null && widget.auction.imageUrl!.isNotEmpty
                ? Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(widget.auction.imageUrl!, height: 150, fit: BoxFit.cover),
                      ),
                      const SizedBox(height: 12),
                      Text('تغيير الصورة الحالية', style: AppTextStyles.body1Bold.copyWith(color: AppColors.primary)),
                    ],
                  )
                : Column(
                    children: [
                      const Icon(Icons.add_a_photo_outlined, size: 40, color: AppColors.primary),
                      const SizedBox(height: 12),
                      Text('انقر لتحديد صورة جديدة', style: AppTextStyles.body1Bold),
                      Text('JPG, PNG بحد أقصى 5 ميجابايت', style: AppTextStyles.caption),
                    ],
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
