import 'package:flutter/material.dart';

import '../models/team_member.dart';
import '../theme/app_theme.dart';

/// Circle with the member's initials. A null member (deleted/unassigned)
/// shows a neutral person icon instead.
class MemberAvatar extends StatelessWidget {
  final TeamMember? member;
  final double radius;
  const MemberAvatar({super.key, required this.member, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    final m = member;
    if (m == null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.mist,
        child: Icon(Icons.person_off_outlined,
            size: radius, color: AppColors.navy),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.blue,
      child: Text(
        m.initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.7,
        ),
      ),
    );
  }
}