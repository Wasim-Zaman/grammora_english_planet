import 'package:material_ui/material_ui.dart';
import 'package:gep/view/screens/admin/dashboard/enrolled_students/students_list_tab_screen.dart';
import 'package:gep/view/screens/admin/dashboard/enrolled_students/students_states_tab.dart';
import 'package:gep/view/widgets/app_scaffold.dart';

class EnrollStudentsManagementScreen extends StatelessWidget {
  const EnrollStudentsManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: AppScaffold(
        title: 'Enrolled Students',
        bottom: const TabBar(
          tabs: [
            Tab(text: 'Students List'),
            Tab(text: 'Statistics'),
          ],
        ),
        body: const TabBarView(
          children: [
            StudentsListTab(),
            StudentsStatsTab(),
          ],
        ),
      ),
    );
  }
}
