---
name: gep-flutter
description: Project conventions and architecture for the GEP (Gramora English Planet) Flutter app. Use when editing any Dart file under lib/, adding screens, widgets, cubits, routes, or theming in this repository.
---

# GEP (Gramora English Planet) Flutter App

## Overview

Flutter app for an English learning institute. User-facing dashboard plus an
admin panel for content management (notes, courses, banners, admissions,
enrolled students, updates).

## Stack

- **State management:** flutter_bloc (Cubits in `lib/cubits/<feature>/`)
- **Routing:** go_router via `lib/router/app_router.dart` (route table),
  `lib/router/app_routes.dart` (name/path constants),
  `lib/router/app_navigation.dart` (`AppNavigation` helpers)
- **Backend:** Firebase Auth, Firebase Analytics, Supabase
- **UI kit:** `material_ui` package
- **Charts:** fl_chart · **Animations:** flutter_animate · **Lottie:** lottie

## Critical Conventions

1. **Never import `flutter/material.dart`.** Always use
   `import 'package:material_ui/material_ui.dart';` — the whole codebase was
   migrated to it.
2. **Never hardcode routes.** Use `AppRoutes.kXxxRoute` constants with
   `AppNavigation.push / pushReplacement / goAndClearStack`.
3. **Theming:** read `Theme.of(context).colorScheme` instead of hardcoded
   colors. Brand colors/gradients/lottie paths live in
   `lib/core/constants/constants.dart` (`AppColors`, `AppGradients`,
   `AppLotties`). Themes are defined in `lib/core/themes/themes.dart`.
4. **`UpgradeAlert` (upgrader package) must live INSIDE the Navigator tree**
   (e.g., wrapping a screen's Scaffold). Placing it above `MaterialApp` causes
   a `No MaterialLocalizations found` crash; placing it in
   `MaterialApp.router`'s `builder` causes a `Navigator` crash.
5. **Auth flow:** `AuthCubit` wraps the app; `MyApp` in `lib/gep_app.dart`
   builds `MaterialApp.router` inside `AppWrapper` (which handles in-app
   review only).

## Directory Layout

```
lib/
  main.dart                  # bootstrap (Firebase, Supabase, env)
  gep_app.dart               # MyApp -> MaterialApp.router
  core/constants/            # AppColors, AppGradients, AppLotties, AppIcons
  core/themes/               # AppThemes.lightTheme / darkTheme
  cubits/<feature>/          # one cubit per feature / screen
  models/                    # data models + PaginatedResult<T>
  router/                    # AppRouter (go_router), AppRoutes, AppNavigation
  services/                  # auth, analytics, supabase services
  view/
    screens/user/            # user-facing screens (dashboard, notes, ...)
    screens/admin/           # admin panel screens
    widgets/                 # shared widgets (AppDrawer, BannerSlider, PaginatedWidget)
```

## Theme Toggle

`ThemeCubit` + `BlocBuilder<ThemeCubit, ThemeState>` toggles light/dark.
Dark mode uses true black scaffold; test new UI in both modes.

## Analysis & Run

The project requires Dart SDK ^3.10.0 (Flutter 3.38+). The default `flutter`
on PATH (3.35) is too old — use the Puro environment:

```bash
~/.puro/envs/3.47.0/flutter/bin/flutter analyze
~/.puro/envs/3.47.0/flutter/bin/flutter run
```

## Style

- Keep code short, minimal, and easy to read; no comments unless requested.
- Private widgets (`_Foo`) inside the same file for screen-local components.
- Staggered entrance animations via `flutter_animate` (see
  `dashboard_screen.dart` for the pattern).

## Modern UI Patterns (Minimal Code)

Every new screen should follow the **dashboard_screen.dart** style: clean,
modern, and expressed in as little code as possible.

### 1. Use `AppScaffold` for Every Screen

Never use raw `Scaffold`. `AppScaffold` (`lib/view/widgets/app_scaffold.dart`)
handles system UI overlays, dark/light backgrounds, and safe-area logic
automatically.

```dart
return AppScaffold(
  title: 'Screen Title',                 // builds centered AppBar
  actions: [IconButton(...)],
  drawer: AppDrawer(isAdminLoggedIn: true),
  backgroundColor: theme.scaffoldBackgroundColor,
  safeAreaBottom: false,                // use false when body is CustomScrollView
  body: ...,
);
```

### 2. Use `AppDrawer` for Drawers

`AppDrawer` is the single source of truth for navigation drawers. It already
supports both user and admin dashboards.

```dart
// User dashboard
AppDrawer(isAdminLoggedIn: _isAdminLoggedIn)

// Admin dashboard
AppDrawer(isAdminLoggedIn: true, isAdminDashboard: true)
```

### 3. Layout with `CustomScrollView` + Slivers

Avoid nested `Column` + `ListView`. Use slivers for everything — headers,
grids, lists, and spacers. This keeps scroll physics unified and code flat.

```dart
body: CustomScrollView(
  physics: const BouncingScrollPhysics(
    parent: AlwaysScrollableScrollPhysics(),
  ),
  slivers: [
    SliverToBoxAdapter(child: _HeaderCard()),
    const SliverToBoxAdapter(
      child: _SectionHeader(icon: Icons.bolt_rounded, title: 'QUICK ACTIONS'),
    ),
    SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      sliver: SliverGrid(...),
    ),
    const SliverToBoxAdapter(child: SizedBox(height: 32)),
  ],
),
```

### 4. Card Styling (Modern Glass / Bordered Cards)

All content blocks should be rounded cards with subtle borders. No heavy
shadows, no default `Card` widget unless necessary.

```dart
Container(
  margin: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: isDark ? AppColors.darkCard : AppColors.lightCard,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
    ),
  ),
  child: ...,
)
```

**Constants to use:**
- Border radius: `24` for large cards, `20` for medium, `16` for small chips.
- Padding: `AppConstants.defaultPadding` (16).
- Neutral backgrounds: `AppColors.darkNeutral` / `AppColors.lightNeutral` for
  icon containers and chips.

### 5. Entrance Animations (Staggered)

Animate every list/grid item with `flutter_animate`. Use delays based on
index for a staggered effect.

```dart
GestureDetector(
  onTap: () => AppNavigation.push(context, route),
  child: Container(...),
)
.animate()
.fadeIn(delay: (index * 60).ms)
.slideX(begin: index.isEven ? -0.05 : 0.05, end: 0);
```

For grid tiles:
```dart
.animate()
.fadeIn(delay: (80 + index * 40).ms)
.slideY(begin: 0.1, end: 0);
```

### 6. Header Pattern

The header is a card containing:
- A **drawer opener** icon (rounded neutral container).
- Greeting label (`labelSmall`, uppercase, letter-spacing).
- User name (`titleLarge`, bold).
- **Theme toggle** icon button.
- **Avatar** (circle with border).

Use `_greeting()` helper for time-based greetings.

### 7. Section Headers

Small uppercase labels with an icon, used between sliver blocks.

```dart
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        children: [
          Icon(icon, size: 16,
            color: isDark ? AppColors.darkBodyTextSecondary : AppColors.primary),
          const SizedBox(width: 8),
          Text(title,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: isDark
                  ? AppColors.darkBodyTextSecondary
                  : AppColors.lightBodyTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
```

### 8. Keep It Minimal

- Define data as `static const List<_Service> _services = [...]` and map over
  it in `build` rather than writing repetitive widgets.
- Private widgets (`_Foo`) inside the same file; only extract to `view/widgets/`
  when reused across screens.
- Use loops / `for (...)` collection-`for` inside `Row`/`Column` instead of
  copy-paste.
- Prefer `GestureDetector` with `Container` decoration over `Card` + `InkWell`
  unless ripple is required.

## Summary Checklist for New Screens

- [ ] `AppScaffold` with `title` (or `titleWidget`) and `body`.
- [ ] `CustomScrollView` + slivers for scrollable content.
- [ ] Rounded `Container` cards with `BoxDecoration` (radius 24, border).
- [ ] `flutter_animate` staggered entrances.
- [ ] `AppConstants.defaultPadding` for spacing.
- [ ] Theme-aware colors (`AppColors.darkXxx` / `AppColors.lightXxx`).
- [ ] `AppDrawer` if the screen has a drawer.
- [ ] No raw `Scaffold`, no `flutter/material.dart`, no hardcoded routes.

---

## Pagination & State Management Architecture

### 9. One Cubit Per Screen (No StreamBuilder in UI)

**Never** use `StreamBuilder` directly in a screen for list data. Every list
screen gets its own dedicated Cubit registered at the app level in
`main.dart`. This ensures state survives hot reload, pull-to-refresh, and
navigation.

```dart
// main.dart
BlocProvider(create: (context) => UserNotesCubit(NotesService())),
```

The cubit holds:
- `items` — current page of data
- `currentPage` — zero-based page index
- `hasMore` — cursor pagination flag
- `isLoading` / `isRefreshing` — distinct loading states
- `searchQuery` — optional debounced filter

### 10. Cursor Pagination via Supabase

All list endpoints use **cursor pagination** (no `COUNT` queries):

```dart
Future<PaginatedResult<T>> getItemsPaginated({
  required int page,
  required int pageSize,
  String? searchQuery,
}) async {
  final from = page * pageSize;
  final to = from + pageSize;        // fetch one extra row

  var query = _supabase.from(_table).select();
  if (searchQuery != null && searchQuery.isNotEmpty) {
    query = query.ilike('title', '%$searchQuery%');
  }

  final data = await query
      .order('created_at', ascending: false)
      .range(from, to);

  final hasMore = data.length > pageSize;
  final items = data.take(pageSize).map(...).toList();

  return PaginatedResult(items: items, hasMore: hasMore);
}
```

- `PaginatedResult<T>` lives in `lib/models/paginated_result.dart`
- Page size defaults: **15** for notes/categories, **10** for everything else

### 11. Search with Debounce

Every paginated list includes a search bar. Queries are debounced (400 ms)
and reset to page 0:

```dart
void setSearchQuery(String query) {
  _debounceTimer?.cancel();
  _debounceTimer = Timer(const Duration(milliseconds: 400), () {
    emit(state.copyWith(searchQuery: query.trim(), currentPage: 0));
    fetchPage(0);
  });
}
```

Search uses Supabase `.ilike()` for case-insensitive partial matching.

### 12. `PaginatedWidget` for Navigation

Use `lib/view/widgets/paginated_widget.dart` at the bottom of every
paginated list. It provides:
- **Previous / Next** chevrons (disabled at bounds)
- **Numbered page buttons** with ellipsis for gaps
- **Refresh** spinner
- **Range indicator** (e.g. "1–15 of 47")

```dart
SliverToBoxAdapter(
  child: PaginatedWidget(
    isLoading: state.isLoading || state.isRefreshing,
    hasPrevious: state.currentPage > 0,
    hasNext: state.hasMore,
    onPrevious: () => context.read<MyCubit>().previousPage(),
    onNext: () => context.read<MyCubit>().nextPage(),
    onPageSelected: (page) => context.read<MyCubit>().goToPage(page),
    onRefresh: () => context.read<MyCubit>().refresh(),
    currentPage: state.currentPage,
    pageSize: 10,
  ),
)
```

### 13. Cubit Naming Conventions

- Admin mutating cubits: `NotesCategoriesCubit`, `BannersCubit`, `AdmissionsCubit`,
  `UpdatesAdminCubit`, `EnrolledStudentsAdminCubit`, `CoursesCubit`
- User read-only cubits: `UserNotesCubit`, `UserAdmissionsCubit`,
  `UserCoursesCubit`, `UserUpdatesCubit`, `UserStudentsCubit`
- Shared: `NotesCategoriesCubit` (used by both admin and user)

### 14. Silent Refresh Pattern

`fetchPage(page, silent: true)` keeps the existing list visible while
refreshing in the background. Use this for:
- Pull-to-refresh gestures
- After add/delete mutations
- Periodic background refresh

```dart
Future<void> refresh() => fetchPage(state.currentPage, silent: true);
```
