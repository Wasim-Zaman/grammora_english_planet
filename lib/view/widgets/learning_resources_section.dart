import 'package:material_ui/material_ui.dart';
import 'package:lottie/lottie.dart';
import 'package:gep/router/app_navigation.dart';

class LearningResourcesSection extends StatelessWidget {
  final List<Map<String, dynamic>> resources;

  const LearningResourcesSection({
    super.key,
    required this.resources,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Learning Resources',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: resources.length,
            itemBuilder: (context, index) {
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(
                      alpha: isDark ? 0.3 : 0.6,
                    ),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => AppNavigation.push(
                      context,
                      resources[index]['routeName'],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: resources[index]['gradient'],
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Lottie.asset(
                              resources[index]['lottieUrl'],
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            resources[index]['title'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
