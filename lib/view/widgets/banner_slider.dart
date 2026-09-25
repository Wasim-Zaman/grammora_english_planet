import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/core/constants/constants.dart';
import 'package:gep/cubits/banner/banner_cubit.dart';
import 'package:gep/cubits/banner/banner_state.dart';
import 'package:gep/view/widgets/cached_image_widget.dart';
import 'package:gep/view/widgets/placeholder_widget.dart';
import 'package:material_ui/material_ui.dart';

class BannerSlider extends StatelessWidget {
  const BannerSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;

    return BlocBuilder<BannerCubit, BannerState>(
      builder: (context, state) {
        if (state is BannerLoading) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
            ),
            child: AspectRatio(
              aspectRatio: 2.5,
              child: PlaceholderWidgets.rectanglePlaceholder(
                borderRadius: 16,
              ),
            ),
          );
        }

        if (state is BannerLoaded) {
          if (state.banners.isEmpty) return const SizedBox.shrink();

          return Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
            ),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.transparent
                      : AppColors.primary.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(19),
              child: AspectRatio(
                aspectRatio: 2.5,
                child: CarouselSlider(
                  options: CarouselOptions(
                    viewportFraction: 1.0,
                    autoPlay: state.banners.length > 1,
                    autoPlayInterval: const Duration(seconds: 4),
                    autoPlayAnimationDuration: const Duration(milliseconds: 700),
                    autoPlayCurve: Curves.easeInOut,
                    enlargeCenterPage: false,
                    scrollPhysics: const ClampingScrollPhysics(),
                  ),
                  items: state.banners.map((banner) {
                    return CachedImageWidget(
                      imageUrl: banner.imageUrl,
                      fit: BoxFit.cover,
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
