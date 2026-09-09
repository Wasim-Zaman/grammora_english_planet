import 'package:flutter/services.dart';
import 'package:gep/core/constants/constants.dart';
import 'package:material_ui/material_ui.dart';

class AppScaffold extends StatelessWidget {
  final Key? scaffoldKey;
  final String? title;
  final Widget? titleWidget;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final bool resizeToAvoidBottomInset;
  final Color? backgroundColor;
  final Widget? drawer;
  final PreferredSizeWidget? bottom;
  final bool safeAreaBottom;

  const AppScaffold({
    super.key,
    this.scaffoldKey,
    this.title,
    this.titleWidget,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.resizeToAvoidBottomInset = true,
    this.backgroundColor,
    this.drawer,
    this.bottom,
    this.safeAreaBottom = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultBg = isDark
        ? AppColors.darkScaffoldBackground
        : AppColors.lightScaffoldBackground;

    final systemUiOverlay = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: backgroundColor ?? defaultBg,
      systemNavigationBarIconBrightness: isDark
          ? Brightness.light
          : Brightness.dark,
    );

    final hasAppBar =
        title != null ||
        titleWidget != null ||
        leading != null ||
        actions != null ||
        bottom != null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemUiOverlay,
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: backgroundColor ?? defaultBg,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        drawerEdgeDragWidth: 0,
        drawer: drawer,
        appBar: hasAppBar
            ? AppBar(
                title:
                    titleWidget ??
                    (title != null
                        ? Text(
                            title!,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          )
                        : null),
                centerTitle: true,
                elevation: 0,
                scrolledUnderElevation: 0.5,
                backgroundColor: backgroundColor ?? defaultBg,
                automaticallyImplyLeading: automaticallyImplyLeading,
                leading: leading,
                actions: actions,
                bottom: bottom,
              )
            : null,
        body: SafeArea(top: !hasAppBar, bottom: safeAreaBottom, child: body),
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavigationBar,
      ),
    );
  }
}
