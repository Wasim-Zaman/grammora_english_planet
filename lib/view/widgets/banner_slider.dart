import 'package:carousel_slider/carousel_slider.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gep/cubits/banner/banner_cubit.dart';
import 'package:gep/cubits/banner/banner_state.dart';
import 'package:gep/view/widgets/cached_image_widget.dart';

class BannerSlider extends StatelessWidget {
  const BannerSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<BannerCubit, BannerState>(
      builder: (context, state) {
        // if (state is BannerLoading) {
        //   return PlaceholderWidgets.bannerPlaceholder();
        // }

        if (state is BannerLoaded) {
          if (state.banners.isEmpty) return const SizedBox.shrink();

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: theme.dividerColor,
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AspectRatio(
                aspectRatio: 2,
                child: CarouselSlider(
                  options: CarouselOptions(
                    viewportFraction: 1.0,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 4),
                    autoPlayAnimationDuration:
                        const Duration(milliseconds: 800),
                    autoPlayCurve: Curves.easeInOut,
                    enlargeCenterPage: false,
                    scrollPhysics: const ClampingScrollPhysics(),
                  ),
                  items: state.banners.map((banner) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedImageWidget(
                              imageUrl: banner.imageUrl,
                            ),
                            // Optional: Add a subtle gradient overlay
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    isDark
                                        ? Colors.black.withValues(alpha: 0.3)
                                        : Colors.black.withValues(alpha: 0.1),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        }

        return const SizedBox();
      },
    );
  }
}
