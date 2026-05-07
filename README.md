# Notes App

A Flutter notes application with Supabase backend featuring authentication, secure CRUD operations, offline handling, and search functionality.

## Tech Stack

- **Flutter** - Cross-platform UI framework
- **Supabase** - Backend (Authentication + PostgreSQL database)
- **connectivity_plus** - Offline detection

## Features

### Authentication
- Email & password sign up
- Email & password login
- Logout
- Persistent session across app restarts

### Notes Management
- Create notes with title and content
- Edit existing notes
- Delete notes with confirmation dialog
- View all notes sorted by last updated
- Pull-to-refresh notes list

### Security
- Row Level Security (RLS) on Supabase
- Users can only access their own notes
- All database queries filtered by `user_id`

### Additional Features
- **Offline Handling** - Shows banner when offline, graceful error states
- **Search Notes** - Client-side search by title

## Prerequisites

- Flutter SDK (3.x+)
- Android build tools (for APK)

## Quick Start

This project comes pre-configured with a Supabase project. To run it:

```bash
flutter pub get
flutter run
```

Or build the APK:

```bash
flutter build apk --debug
```

The APK will be at `build/app/outputs/flutter-apk/app-debug.apk`.

## Manual Setup (if using a different Supabase project)

### 1. Supabase Project Setup

1. Create a Supabase project at https://supabase.com
2. Go to **Project Settings > API** and copy:
   - `Project URL` (e.g., `https://xxxxx.supabase.co`)
   - `anon public key`
3. Go to **SQL Editor** in the Supabase dashboard
4. Run the SQL script from `supabase_setup.sql` to create the `notes` table with RLS policies

### 2. Configure the App

Open `lib/config/supabase_config.dart` and update the values:

```dart
static const String supabaseUrl = 'https://your-project.supabase.co';
static const String supabaseAnonKey = 'your-anon-key-here';
```

## Database Schema

### `notes` table

| Column       | Type                | Description                    |
|-------------|---------------------|--------------------------------|
| id          | BIGINT (PK, Identity)| Auto-generated unique ID      |
| title       | TEXT (NOT NULL)     | Note title                     |
| content     | TEXT (NOT NULL)     | Note content                   |
| created_at  | TIMESTAMPTZ         | Creation timestamp             |
| updated_at  | TIMESTAMPTZ         | Last update timestamp          |
| user_id     | UUID (FK to auth.users)| Owner of the note            |

### Row Level Security Policies

| Policy | Action | Rule |
|--------|--------|------|
| Users can view their own notes | SELECT | `auth.uid() = user_id` |
| Users can create their own notes | INSERT | `auth.uid() = user_id` |
| Users can update their own notes | UPDATE | `auth.uid() = user_id` |
| Users can delete their own notes | DELETE | `auth.uid() = user_id` |

## Authentication Approach

Supabase Auth with email/password. Sessions are persisted automatically using Supabase's built-in token storage (SharedPreferences on Android). On app launch, `Supabase.instance.client.auth.currentUser` is checked to restore the session.

## Project Structure

```
lib/
  main.dart                     - App entry point, Supabase initialization
  app.dart                      - MaterialApp with auth-based routing
  config/
    supabase_config.dart        - Supabase URL and anon key
  models/
    note.dart                   - Note data model
  services/
    auth_service.dart           - Authentication operations
    note_service.dart           - Notes CRUD operations
    connectivity_service.dart   - Network connectivity monitoring
  screens/
    auth/
      login_screen.dart         - Login screen
      signup_screen.dart        - Sign up screen
    notes/
      note_list_screen.dart     - Notes list with search
      note_edit_screen.dart     - Create/edit note
  widgets/
    offline_banner.dart         - Offline state indicator
```

## Assumptions & Trade-offs

- **Supabase anon key** is safe to include in the client app when RLS policies are properly configured
- **Offline detection** uses connectivity_plus; the app shows an offline banner but requires internet for data operations
- **Search** is client-side for simplicity (all notes are fetched, then filtered by title)
- Supabase's email confirmation is disabled by default; if enabled, users need to confirm their email before signing in
