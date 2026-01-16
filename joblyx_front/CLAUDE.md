# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build and Development Commands

```bash
# Install dependencies
flutter pub get

# Run the app (debug mode)
flutter run

# Build for release
flutter build apk        # Android
flutter build ios        # iOS

# Run tests
flutter test
flutter test test/path/to/specific_test.dart  # Single test file

# Analyze code for issues
flutter analyze

# Format code
dart format .
```

## Environment Setup

The app requires a `.env` file in the project root with:
- `SUPABASE_URL` - Supabase project URL
- `SUPABASE_ANON_KEY` - Supabase anonymous key

## Architecture Overview

### State Management
Uses **Riverpod** for state management. Providers are in `lib/providers/`:
- `supabase_provider.dart` - Exposes SupabaseClient instance
- `auth_state_provider.dart` - Streams authentication state changes
- `auth_service_provider.dart` - Provides AuthService instance
- `user_provider.dart` - Streams current user profile from `profiles` table
- `storage_service_provider.dart` - Provides StorageService instance

### Routing
Uses **go_router** with `StatefulShellRoute` for bottom navigation tabs. Configuration in `lib/routers/`:
- `routes.dart` - Route path constants (`AppRoutes` class)
- `app_router.dart` - Router configuration with nested tab routes

The dashboard (`lib/screens/dashboard.dart`) wraps the four main tabs: Home, Analysis, CV, and Profile.

### Backend
**Supabase** is used for:
- Authentication (email/password with OTP verification)
- Database (`profiles` table for user data)
- Storage (`avatar` bucket for profile pictures)

### Localization
Custom JSON-based i18n system in `lib/services/app_localizations.dart`:
- Translation files: `assets/i18n/en.json`, `assets/i18n/fr.json`
- Access translations via `AppLocalizations.of(context).t('key.path')`
- Supports nested keys (e.g., `nav.home`)

### Responsive Design
Uses **flutter_screenutil** initialized with design size 360x690. Use `.w`, `.h`, `.r`, `.sp` extensions for responsive dimensions.

## Project Structure

```
lib/
├── main.dart           # App entry point, Supabase init, theme config
├── models/             # Data models (UserModel)
├── providers/          # Riverpod providers
├── routers/            # go_router configuration
├── screens/            # Full-page screens
│   └── menu/           # Dashboard tab screens (home, analysis, cv, profil)
├── services/           # Business logic (auth, storage, localization)
└── widgets/            # Reusable UI components
    ├── profil/         # Profile-related widgets
    └── settings/       # Settings screen widgets
```
