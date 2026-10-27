import 'package:flutter/material.dart';

import '../parent/parent_child_progress_page.dart';

class TeacherChildProgressPage extends StatelessWidget {
  const TeacherChildProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ParentChildProgressPage(forTeacher: true);
  }
}
