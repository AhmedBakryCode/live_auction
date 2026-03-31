import 'package:flutter/material.dart';
import 'user_card.dart';

class UsersListSection extends StatelessWidget {
  const UsersListSection({super.key});

  @override
  Widget build(BuildContext context) {
    // List of users
    final List<Map<String, dynamic>> users = [
      {
        'name': 'أحمد بكري',
        'role': 'مدير النظام',
        'status': 'نشط',
        'isVerified': true,
        'wallet': '\$12,450',
        'avatar': 'https://i.pravatar.cc/150?u=ahmed',
      },
      {
        'name': 'سارة محمد',
        'role': 'بائع معتمد',
        'status': 'قيد الانتظار',
        'isVerified': false,
        'wallet': '\$3,200',
        'avatar': 'https://i.pravatar.cc/150?u=sara',
      },
      {
        'name': 'خالد عبدالله',
        'role': 'مزايد نشط',
        'status': 'محظور',
        'isVerified': true,
        'wallet': '\$450',
        'avatar': 'https://i.pravatar.cc/150?u=khaled',
      },
       {
        'name': 'ليلى علي',
        'role': 'بائع',
        'status': 'نشط',
        'isVerified': true,
        'wallet': '\$8,900',
        'avatar': 'https://i.pravatar.cc/150?u=leila',
      },
      {
        'name': 'ياسين محمود',
        'role': 'مستخدم جديد',
        'status': 'نشط',
        'isVerified': false,
        'wallet': '\$150',
        'avatar': 'https://i.pravatar.cc/150?u=yassin',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      physics: const BouncingScrollPhysics(),
      itemCount: users.length,
      itemBuilder: (context, index) => UserCard(user: users[index]),
    );
  }
}
