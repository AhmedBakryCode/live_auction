import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../user_stats/presentation/bloc/user_stats_bloc.dart';
import '../../domain/entities/user_profile.dart';
import '../bloc/profile_bloc.dart';
import 'help_center_page.dart';
import 'transactions_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<UserStatsBloc>().add(LoadUserStats());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<ProfileBloc>()..add(LoadProfile()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الملف الشخصي'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                final state = context.read<ProfileBloc>().state;
                if (state is ProfileLoaded) {
                  _showEditProfileDialog(context, state.profile);
                }
              },
            ),
          ],
        ),
        body: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تحديث الملف الشخصي بنجاح')),
              );
              context.read<ProfileBloc>().add(LoadProfile());
            } else if (state is PasswordChanged) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تغيير كلمة المرور بنجاح')),
              );
            }
          },
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const LoadingIndicator();
            } else if (state is ProfileError) {
              return ErrorView(
                message: state.message,
                onRetry: () => context.read<ProfileBloc>().add(LoadProfile()),
              );
            } else if (state is ProfileLoaded) {
              return _buildProfileView(context, state.profile);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildProfileView(BuildContext context, UserProfile profile) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 24),
          _buildProfileHeader(context, profile),
          const SizedBox(height: 32),
          _buildStatsRow(context),
          const SizedBox(height: 32),
          _buildProfileMenu(context, profile),
          const SizedBox(height: 32),
          _buildLogoutButton(context),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserProfile profile) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _showImagePickerOptions(context, profile),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 3),
                ),
                child: profile.profileImage.isNotEmpty
                    ? CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(profile.profileImage),
                        onBackgroundImageError: (_, __) {},
                      )
                    : UserAvatar(name: profile.fullName, size: 100),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          profile.fullName,
          style: AppTextStyles.heading2.copyWith(
            color: AppColors.getPrimaryText(context),
          ),
        ),
        Text(
          profile.email,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.getSecondaryText(context),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            profile.role,
            style: AppTextStyles.caption.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return BlocBuilder<UserStatsBloc, UserStatsState>(
      builder: (context, state) {
        String auctionsWon = '٠';
        String totalBids = '٠';
        String points = '٠';

        if (state is UserStatsLoaded) {
          auctionsWon = state.stats.auctionsWon.toString();
          totalBids = state.stats.totalBids.toString();
          points = state.stats.totalSpent.toStringAsFixed(0);
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.getContainerColor(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.05),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(context, auctionsWon, 'مزاد فائز'),
              _buildVerticalDivider(context),
              _buildStatItem(context, totalBids, 'مزايدة'),
              _buildVerticalDivider(context),
              _buildStatItem(context, points, 'نقطة'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.getSecondaryText(context),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider(BuildContext context) {
    return Container(
      height: 40,
      width: 1,
      color: Theme.of(context).dividerColor.withOpacity(0.1),
    );
  }

  Widget _buildProfileMenu(BuildContext context, UserProfile profile) {
    return Column(
      children: [
        _buildMenuItem(
          context,
          Icons.person_outline,
          'المعلومات الشخصية',
          () => _showEditProfileDialog(context, profile),
        ),
        _buildMenuItem(
          context,
          Icons.phone_outlined,
          'الهاتف: ${profile.phone}',
          () {},
        ),
        _buildMenuItem(
          context,
          Icons.location_on_outlined,
          'العنوان: ${profile.address}',
          () {},
        ),
        _buildMenuItem(context, Icons.shopping_bag_outlined, 'مشترياتي', () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TransactionsPage()),
          );
        }),
        _buildMenuItem(context, Icons.favorite_border, 'المفضلة', () {}),
        _buildMenuItem(
          context,
          Icons.account_balance_wallet_outlined,
          'المحفظة',
          () => Navigator.pushNamed(context, '/wallet'),
        ),
        _buildMenuItem(
          context,
          Icons.lock_outline,
          'تغيير كلمة المرور',
          () => _showChangePasswordDialog(context),
        ),
        _buildMenuItem(
          context,
          Icons.help_outline,
          'مركز المساعدة',
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HelpCenterPage()),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.getPrimaryText(context),
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppColors.getSecondaryText(context),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: OutlinedButton(
        onPressed: () {
          context.read<AuthBloc>().add(LogoutRequested());
        },
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'تسجيل الخروج',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, UserProfile profile) {
    final firstNameController = TextEditingController(text: profile.firstName);
    final lastNameController = TextEditingController(text: profile.lastName);
    final phoneController = TextEditingController(text: profile.phone);
    final addressController = TextEditingController(text: profile.address);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تعديل الملف الشخصي'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: 'الاسم الأول'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: 'الاسم الأخير'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'العنوان'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final request = UpdateProfileRequest(
                firstName: firstNameController.text,
                lastName: lastNameController.text,
                phone: phoneController.text,
                address: addressController.text,
              );
              context.read<ProfileBloc>().add(UpdateProfile(request));
              Navigator.pop(dialogContext);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تغيير كلمة المرور'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور الحالية',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور الجديدة',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'تأكيد كلمة المرور',
                ),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (newPasswordController.text !=
                  confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('كلمة المرور الجديدة غير متطابقة'),
                  ),
                );
                return;
              }
              final request = ChangePasswordRequest(
                currentPassword: currentPasswordController.text,
                newPassword: newPasswordController.text,
                newPasswordConfirmation: confirmPasswordController.text,
              );
              context.read<ProfileBloc>().add(ChangePassword(request));
              Navigator.pop(dialogContext);
            },
            child: const Text('تغيير'),
          ),
        ],
      ),
    );
  }

  void _showImagePickerOptions(BuildContext context, UserProfile profile) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('اختيار من المعرض'),
              onTap: () async {
                Navigator.pop(context);
                await _pickImage(context, profile, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('التقاط صورة'),
              onTap: () async {
                Navigator.pop(context);
                await _pickImage(context, profile, ImageSource.camera);
              },
            ),
            if (profile.profileImage.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'حذف الصورة',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _updateProfileImage(context, profile, '');
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(
    BuildContext ctx,
    UserProfile profile,
    ImageSource source,
  ) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final imagePath = pickedFile.path;
        if (mounted) {
          await _updateProfileImage(context, profile, imagePath);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في اختيار الصورة: $e')));
      }
    }
  }

  Future<void> _updateProfileImage(
    BuildContext context,
    UserProfile profile,
    String imagePath,
  ) async {
    final request = UpdateProfileRequest(
      firstName: profile.firstName,
      lastName: profile.lastName,
      phone: profile.phone,
      address: profile.address,
      profileImage: imagePath.isNotEmpty ? imagePath : null,
    );
    context.read<ProfileBloc>().add(UpdateProfile(request));
  }
}
