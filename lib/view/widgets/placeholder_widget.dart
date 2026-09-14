import 'package:material_ui/material_ui.dart';
import 'package:gep/core/constants/constants.dart';
import 'package:shimmer/shimmer.dart';

class PlaceholderWidgets {
  static Widget rectanglePlaceholder({
    double width = double.infinity,
    double height = 100,
    double borderRadius = 8,
  }) {
    return Builder(
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return Shimmer.fromColors(
          baseColor:
              isDarkMode ? AppColors.darkNeutral : AppColors.lightNeutral,
          highlightColor: isDarkMode ? AppColors.darkCard : AppColors.lightCard,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
        );
      },
    );
  }

  static Widget textPlaceholder({
    double width = 200,
    double height = 16,
  }) {
    return Builder(
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return Shimmer.fromColors(
          baseColor:
              isDarkMode ? AppColors.darkNeutral : AppColors.lightNeutral,
          highlightColor: isDarkMode ? AppColors.darkCard : AppColors.lightCard,
          child: Container(
            width: width,
            height: height,
            color: isDarkMode ? AppColors.darkCard : AppColors.lightCard,
          ),
        );
      },
    );
  }

  static Widget listPlaceholder({int itemCount = 5}) {
    return ListView.builder(
      itemCount: itemCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              rectanglePlaceholder(width: 60, height: 60),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    textPlaceholder(),
                    const SizedBox(height: 8),
                    textPlaceholder(width: 100),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget gridPlaceholder({int itemCount = 6}) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: itemCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return rectanglePlaceholder(height: 120);
      },
    );
  }

  static Widget bannerPlaceholder({double height = 200}) {
    return Builder(
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return Shimmer.fromColors(
          baseColor:
              isDarkMode ? AppColors.darkNeutral : AppColors.lightNeutral,
          highlightColor: isDarkMode ? AppColors.darkCard : AppColors.lightCard,
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  // Admissions placeholder
  static Widget cardPlaceholder() {
    return ListView.builder(
      itemCount: 2, // Show 3 placeholder items
      itemBuilder: (context, index) {
        return Builder(
          builder: (context) {
            final isDarkMode = Theme.of(context).brightness == Brightness.dark;
            return Shimmer.fromColors(
              baseColor:
                  isDarkMode ? AppColors.darkNeutral : AppColors.lightNeutral,
              highlightColor:
                  isDarkMode ? AppColors.darkCard : AppColors.lightCard,
              child: Card(
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color:
                        isDarkMode ? AppColors.darkCard : AppColors.lightCard,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 200,
                          height: 24,
                          color: isDarkMode
                              ? AppColors.darkNeutral
                              : AppColors.lightNeutral,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: 150,
                          height: 16,
                          color: isDarkMode
                              ? AppColors.darkNeutral
                              : AppColors.lightNeutral,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 100,
                          height: 16,
                          color: isDarkMode
                              ? AppColors.darkNeutral
                              : AppColors.lightNeutral,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          height: 40,
                          color: isDarkMode
                              ? AppColors.darkNeutral
                              : AppColors.lightNeutral,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Widget admissionAnnouncementPlaceholder({int itemCount = 3}) {
    return ListView.separated(
      itemCount: itemCount,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemBuilder: (context, index) {
        return Builder(
          builder: (context) {
            final isDarkMode = Theme.of(context).brightness == Brightness.dark;
            return Shimmer.fromColors(
              baseColor:
                  isDarkMode ? AppColors.darkNeutral : AppColors.lightNeutral,
              highlightColor:
                  isDarkMode ? AppColors.darkCard : AppColors.lightCard,
              child: Card(
                margin: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: AppConstants.defaultPadding,
                ),
                child: ListTile(
                  title: Container(
                    width: double.infinity,
                    height: 16,
                    color:
                        isDarkMode ? AppColors.darkCard : AppColors.lightCard,
                  ),
                  subtitle: Container(
                    width: 200,
                    height: 14,
                    margin: const EdgeInsets.only(top: 8),
                    color:
                        isDarkMode ? AppColors.darkCard : AppColors.lightCard,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? AppColors.darkCard
                              : AppColors.lightCard,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? AppColors.darkCard
                              : AppColors.lightCard,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Widget studentsStatsTabPlaceholder() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildShimmerCard(height: 100),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildShimmerCard(height: 350),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: _buildShimmerText(width: 150, height: 24),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: _buildShimmerListTile(),
            ),
            childCount: 5,
          ),
        ),
      ],
    );
  }

  static Widget _buildShimmerCard({required double height}) {
    return Builder(
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return Shimmer.fromColors(
          baseColor:
              isDarkMode ? AppColors.darkNeutral : AppColors.lightNeutral,
          highlightColor: isDarkMode ? AppColors.darkCard : AppColors.lightCard,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildShimmerText(
      {required double width, required double height}) {
    return Builder(
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return Shimmer.fromColors(
          baseColor:
              isDarkMode ? AppColors.darkNeutral : AppColors.lightNeutral,
          highlightColor: isDarkMode ? AppColors.darkCard : AppColors.lightCard,
          child: Container(
            width: width,
            height: height,
            color: isDarkMode ? AppColors.darkCard : AppColors.lightCard,
          ),
        );
      },
    );
  }

  static Widget _buildShimmerListTile() {
    return Builder(
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return Shimmer.fromColors(
          baseColor:
              isDarkMode ? AppColors.darkNeutral : AppColors.lightNeutral,
          highlightColor: isDarkMode ? AppColors.darkCard : AppColors.lightCard,
          child: Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    isDarkMode ? AppColors.darkCard : AppColors.lightCard,
              ),
              title: Container(
                width: double.infinity,
                height: 16,
                color: isDarkMode ? AppColors.darkCard : AppColors.lightCard,
              ),
              subtitle: Container(
                width: 100,
                height: 14,
                color: isDarkMode ? AppColors.darkCard : AppColors.lightCard,
                margin: const EdgeInsets.only(top: 4),
              ),
              trailing: Icon(
                Icons.chevron_right,
                color: isDarkMode ? AppColors.darkCard : AppColors.lightCard,
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget editStudentScreenPlaceholder() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildShimmerTextField(),
                const SizedBox(height: AppConstants.defaultPadding),
                _buildShimmerTextField(),
                const SizedBox(height: AppConstants.defaultPadding),
                _buildShimmerTextField(),
                const SizedBox(height: AppConstants.defaultPadding),
                _buildShimmerTextField(),
                const SizedBox(height: AppConstants.defaultPadding),
                _buildShimmerTextField(),
                const SizedBox(height: AppConstants.defaultPadding),
                _buildShimmerTextField(),
                const SizedBox(height: AppConstants.defaultPadding),
                _buildShimmerTextField(),
                const SizedBox(height: AppConstants.defaultPadding),
                _buildShimmerListTile(),
                const SizedBox(height: AppConstants.defaultPadding),
                _buildShimmerDropdown(),
                const SizedBox(height: AppConstants.defaultPadding),
                _buildShimmerListTile(),
                const SizedBox(height: AppConstants.defaultPadding * 2),
                _buildShimmerButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static Widget addStudentScreenPlaceholder() {
    // This can be the same as editStudentScreenPlaceholder
    return editStudentScreenPlaceholder();
  }

  static Widget studentDetailsScreenPlaceholder() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildShimmerCard(height: 100),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildShimmerCard(height: 200),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildShimmerCard(height: 150),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildShimmerCard(height: 100),
          ),
        ),
      ],
    );
  }

  static Widget studentsListTabScreenPlaceholder() {
    return ListView.separated(
      itemCount: 10,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(top: 5),
          child: Card(
            margin: const EdgeInsets.symmetric(
              vertical: 4,
              horizontal: AppConstants.defaultPadding,
            ),
            child: _buildShimmerListTile(),
          ),
        );
      },
    );
  }

  static Widget enrolledStudentsScreenPlaceholder() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(
            vertical: 4,
            horizontal: AppConstants.defaultPadding,
          ),
          child: _buildShimmerListTile(),
        );
      },
    );
  }

  static Widget _buildShimmerTextField() {
    return Builder(
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return Shimmer.fromColors(
          baseColor:
              isDarkMode ? AppColors.darkNeutral : AppColors.lightNeutral,
          highlightColor: isDarkMode ? AppColors.darkCard : AppColors.lightCard,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildShimmerDropdown() {
    return Builder(
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return Shimmer.fromColors(
          baseColor:
              isDarkMode ? AppColors.darkNeutral : AppColors.lightNeutral,
          highlightColor: isDarkMode ? AppColors.darkCard : AppColors.lightCard,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildShimmerButton() {
    return Builder(
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return Shimmer.fromColors(
          baseColor:
              isDarkMode ? AppColors.darkNeutral : AppColors.lightNeutral,
          highlightColor: isDarkMode ? AppColors.darkCard : AppColors.lightCard,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
    );
  }
}
