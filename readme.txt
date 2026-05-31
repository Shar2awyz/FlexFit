================================================================================
                       F L E X F I T  ( F L E X L O G )
                 Premium Social Fitness & Workout Tracker
================================================================================

Welcome to FlexFit (FlexLog), a state-of-the-art social fitness tracking application
built using Flutter and Dart. Designed for lifters and fitness enthusiasts who want 
the professional tracking capabilities of premium apps like Hevy or Strong, combined 
with a rich, real-time social networking system for sharing progress, posts, and 
temporary stories.

This README.txt contains an exhaustive breakdown of the application features, tech 
stack, project structure, database architecture, and a slide-by-slide outline to 
serve as the perfect foundation for a presentation or project pitch.

---
TABLE OF CONTENTS:
1. App Vision & Presentation Highlights
2. Core Features Breakdown
3. The Tech Stack (Core, Backend, State Management, Libraries)
4. Database Schema & Storage Architecture (Supabase)
5. Project Directory Structure
6. Presentation Slide-by-Slide Outline
---


================================================================================
1. APP VISION & PRESENTATION HIGHLIGHTS
================================================================================
FlexFit is designed with "Rich Aesthetics" and high-performance engineering in mind:
*   Visual Excellence: Fully responsive, premium HSL/tailored dark & light modes. 
    Uses glassmorphic cards, smooth micro-animations, and fluid Lottie loaders.
*   The "Hevy" Active Tracking Experience: Features a live workout session tracker 
    complete with elapsed-time counters, previous-set comparisons, volume/set 
    computations, and a drag-and-drop exercise reordering tool.
*   Hybrid State Management: Utilizes Flutter BLoC/Cubit for highly reactive, 
    real-time states (Active Workout timer/tracker and Social Feed operations) 
    and Provider (MVVM) for global preferences (Theme toggle) and layout data loading.
*   Offline & Cloud Synchronization: Uses local Shared Preferences caching for 
    lightning-fast launch times and seamless cloud synchronization using the Supabase
    backend database and object storage buckets.


================================================================================
2. CORE FEATURES BREAKDOWN
================================================================================

[A] AUTHENTICATION & SESSION MANAGEMENT
*   Secure Email & Password authentication via Supabase Auth.
*   Single-Sign-On (SSO): Google Sign-In OAuth integration, automatically ingesting 
    avatar profiles.
*   Forget Password Flow: Fully functional recovery email trigger listening to 
    auth-state deep links to land users directly onto the Reset Password page.
*   Local Persistent Caching: Seamless auto-login checks (via Shared Preferences).
*   Lottie Splash Screen: Premium athletic animated loader that checks credentials 
    before routing to the Dashboard or Login page.

[B] INTERACTIVE DASHBOARD (HOMEPAGE)
*   Dynamic Greetings: Greeting header personalized with user's profile photo.
*   Fitness Analytics Panel: Summarizes active statistics:
    - Total completed workouts count.
    - Accumulated workout duration in minutes.
    - Active energy estimation indicator (e.g. 1200 kcal).
*   Split Progress Meter: Visual gauge displaying program split progress.
*   Workout History Log: Scrollable calendar feed tracking past workouts with 
    detailed metadata summaries.
*   Quick Logout: Action bar button to securely end the session.

[C] PROGRAM MANAGER & WORKOUT SPLITS
*   Create Custom Program Splits: Build tailored schedules (e.g., Push/Pull/Legs, 
    Upper/Lower, Arnold Split).
*   Day Management: Add custom training days to splits with dynamic name editors 
    and list swipe-to-delete modifiers.
*   Routine Builder: Search and append exercises from the master library into split days.
*   Featured Templates: Carousel displaying premium, visual pre-made workout splits 
    loaded with professional cover photography.

[D] ACTIVE WORKOUT TRACKER (THE CORE EXPERIENCE)
*   Active Workout Session: Begins a training day, initiating a live elapsed-timer 
    and computing total sets and volume (weight × reps) on the fly.
*   Historic Comparison: Lists the previous session's logged weights and reps directly 
    beneath the current sets (matching premium trackers).
*   Set Logging: Add set inputs dynamically. Completed sets can be dismissed/removed 
    using swipe-to-delete interactions.
*   Mid-Workout Customization: Add, delete, or replace exercises on the fly.
*   Drag-to-Reorder: Intuitive drag-and-drop handle to reorder exercises during the 
    workout, updates the session index in real-time.
*   Smart Split Syncing: Upon finishing, the app computes total elapsed time, logs 
    the session, and prompts the user whether to save the structural changes (added 
    exercises, customized default set counts, or new order indexes) permanently 
    back to their program templates, or save it as a one-off session.

[E] EXERCISE LIBRARY
*   Muscle Group Grid: Structured index of key muscle groups (Chest, Back, Shoulders, 
    Legs, Arms, Core) decorated with custom vector assets.
*   Exercise Directory: Under each muscle group, lists exercises with equipment details
    and target labels.
*   Instructional Tutorials: Tapping any exercise opens an external video demonstration 
    web link using `url_launcher`.

[F] SOCIAL FEED & NETWORK
*   Interactive Social Feed: Scrollable feed showing workout logs and custom text/media 
    posts uploaded by friends. Supports infinite scrolling pagination.
*   Social Actions: Real-time liking, commenting, and reposting/sharing.
*   Temporary Stories: Temporary photo updates (similar to Instagram Stories). Users 
    can tap to view, add their own via image pickers, and view stories grouped by user.
*   User Directory & Search: Search for users globally, view other users' profiles, 
    and inspect their workout counts, sets, and public post history.
*   Friend Request Portal: Send friend requests, accept/reject incoming requests, and 
    add friends directly via search-by-email.
*   Notification Badge System: Real-time badge indicators overlaid on the navigation 
    bar alerting the user to new social engagements (likes, comments, or requests).

[G] USER PROFILE & SETTINGS
*   Custom Avatars: Edit profile pictures using the device camera or gallery, 
    automatically uploaded to Supabase Storage.
*   Weight Metrics Unit Converter: Change unit settings between KG and LBS with 
    automatic, real-time decimal weight conversions across the entire application.
*   Lifting PR Goals: Select specific lifts to follow, record personal records (PRs), 
    and set target goals.
*   Lifting Progress Indicators: Renders a progress bar comparing the best lift to 
    the goal, turning gold/amber once 100% is reached.
*   System Preferences: Preferences hub featuring dark/light mode toggle with 
    instantaneous theme rebuilds.
*   Profile Metadata Form: Validation form to update name, weight, username, email, 
    and gender attributes.


================================================================================
3. THE TECH STACK
================================================================================

*   Core Framework: Flutter & Dart (SDK ^3.11.3)
    - Leverages Material 3 design tokens.
    - Responsive layouts adapted for different mobile screens via MediaQuery.

*   Backend (BaaS): Supabase
    - Auth Service: Manages authentication, email sessions, password recovery, 
      and Google OAuth.
    - PostgreSQL Database: Relational structures ensuring data integrity for 
      complex user-routine-social mappings.
    - Object Storage: Hosts user-generated media (profile avatars and post photos).

*   State Management: Hybrid Architecture
    1. Flutter BLoC / Cubit Pattern (via flutter_bloc):
       - WorkoutBeginCubit: Manages live active workout parameters, live elapsed times, 
         reorder logs, and set adjustments.
       - Social Cubits: Distinct cubits representing SocialFeed, CreatePost, Comments, 
         FriendProfile, FriendRequests, and SearchUsers. Ensures clean, reactive 
         boundaries for social APIs.
    2. Provider & ChangeNotifiers (via provider):
       - ThemeService: Global listener to toggle light/dark configurations.
       - DashboardViewModel, StartWorkoutViewModel, ProfileViewModel, etc. 
         (MVVM pattern for standard views).

*   Key Native Plugins & Libraries:
    - lottie: Render vector animations for Splash and loader overlays.
    - image_picker: Interact with iOS and Android camera/gallery files.
    - url_launcher: Direct deep-links to external Youtube/tutorial URLs.
    - shared_preferences: Access device-level persistent disk caches.


================================================================================
4. DATABASE SCHEMA & STORAGE ARCHITECTURE
================================================================================
FlexFit operates on a relational database hosted on Supabase:

Tables:
1.  Users: Maps user auth records to metadata (id [UUID, primary key], username, 
    fullname, Gender, email, image_url, weight_kg, created_at).
2.  exercises: Master database of exercises (id, name, muscle_group, video_url, 
    equipment, photo_url).
3.  workout_splits: User split templates (id, user_id [FK], name, photo_url, created_at).
4.  split_days: Days inside a split (id, split_id [FK], name, day_index, created_at).
5.  split_exercises: Exercises linked to split days (id, split_day_id [FK], 
    exercise_id [FK], order_index, sets_count).
6.  workouts: Logged user workout sessions (id, user_id [FK], name, duration_seconds, 
    created_at).
7.  workout_exercises: Exercises completed in a specific logged workout (id, 
    workout_id [FK], exercise_id [FK], order_index).
8.  sets: Performance sets completed for a logged exercise (id, workout_exercise_id [FK], 
    reps, weight, number, target_reps, completed_status).
9.  tracked_exercises: Exercises users choose to track on their profile (id, 
    user_id [FK], exercise_id [FK], goal_weight_kg, created_at).
10. friendships: Social graph mapping (id, sender_id [FK], receiver_id [FK], 
    status ['pending', 'accepted'], created_at).
11. posts: User social posts (id, user_id [FK], content, image_url, workout_id [FK], 
    created_at).
12. post_likes: Users who liked a post (id, post_id [FK], user_id [FK]).
13. post_comments: Comments on posts (id, post_id [FK], user_id [FK], content, created_at).
14. post_reposts: Reposts (id, post_id [FK], user_id [FK], created_at).
15. saved_posts: Bookmarked posts (id, post_id [FK], user_id [FK]).
16. stories: Temporary updates (id, user_id [FK], image_url, created_at).
17. story_views: Tracks story view status (id, story_id [FK], user_id [FK], created_at).

Storage Buckets:
*   UserImages: Stores user profile photos.
*   UserPosts: Stores pictures and media uploaded in custom posts.


================================================================================
5. PROJECT DIRECTORY STRUCTURE
================================================================================
Below is a map of the file layout inside the `lib` folder:

lib/
├── Pages/
│   ├── AddExercise/         # Searching, choosing, and adding exercises to custom splits
│   │   ├── Components/      # Search bar, category chips, list items UI
│   │   ├── model/           # ExerciseListItem model
│   │   ├── view/            # AddExercisePage, FinishPage UI
│   │   └── viewmodel/       # AddExerciseViewModel
│   │
│   ├── Components/          # Global shared UI elements
│   │   ├── DashboardPageComponents/ # Sub-widgets for dashboard panels and history cards
│   │   ├── LogInComponents/ # Textfields, Google SSO button
│   │   ├── CustomBottomNavBar.dart # Global navigation bar with social notifications
│   │   ├── app_route.dart   # Page route transition utilities
│   │   └── errorsnackbar.dart # Global snackbar warnings
│   │
│   ├── Dashboard/           # Dashboard Page displaying statistics and summaries
│   │   ├── model/           # Detail and history models
│   │   ├── View/            # Dashboard page layout
│   │   └── ViewModel/       # DashboardViewModel (MVVM)
│   │
│   ├── ExerciseDetails/     # Details about exercises inside a muscle group
│   │   ├── model/           # ExerciseDetailModel
│   │   ├── view/            # ExerciseDetailsPage, ExerciseComponent UI
│   │   └── viewmodel/       # ExerciseDetailsViewModel
│   │
│   ├── ExerciseHistory/     # PR logs, history timelines of a specific lift
│   │   ├── model/           # ExerciseSetRecord model
│   │   ├── view/            # ExerciseHistoryPage
│   │   └── viewmodel/       # ExerciseHistoryViewModel
│   │
│   ├── Exercises_Components/# Base templates for muscle items
│   │
│   ├── Exercises.dart       # Main muscle group grid catalog
│   │
│   ├── ForgotPassword/      # Password recovery and reset portals
│   │   ├── view/            # ForgotPasswordPage, ResetPasswordPage
│   │   └── viewmodel/       # ForgotPasswordViewModel
│   │
│   ├── Login/               # Email credentials input & SSO gateway
│   │   ├── model/           # LoginRequest model
│   │   ├── View/            # LoginScreen UI
│   │   └── ViewModel/       # LoginViewModel
│   │
│   ├── premadeworkout/      # Visual catalogs of template split routines
│   │   ├── Components/      # Cards, titles, headers
│   │   ├── model/           # PremadeSplitModel
│   │   ├── view/            # PremadeWorkoutPage UI
│   │   └── viewmodel/       # PremadeWorkoutViewModel
│   │
│   ├── Profile/             # Profile avatars, weight stats, goals tracker, settings page
│   │   ├── model/           # UserProfileModel, TrackedExerciseModel
│   │   ├── view/            # ProfilePage, SettingsPage
│   │   └── viewmodel/       # ProfileViewModel
│   │
│   ├── SignUp/              # Account registration forms
│   │   ├── model/           # SignUpRequest model
│   │   ├── view/            # SignUpPage
│   │   └── viewmodel/       # SignUpViewModel
│   │
│   ├── Social/              # Social feed, comments, stories, friend directories
│   │   ├── model/           # post, comment, story, friendship models
│   │   ├── view/            # SocialFeedPage, CommentsPage, CreatePostPage, FriendProfilePage, etc.
│   │   ├── viewmodel/       # Social Cubits (social_feed_cubit, comments_cubit, search_users_cubit)
│   │   ├── widgets/         # post_card, story_circle, user_tile widgets
│   │   └── SocialNotificationService.dart # Live badge indicators
│   │
│   ├── Splash/              # High-end splash view with custom Lottie layouts
│   │   └── SplashScreen.dart
│   │
│   ├── StartWorkout/        # Main workout selection hub (custom splits, templates, my routines)
│   │   ├── model/           # SplitSummaryModel
│   │   ├── view/            # StartWorkoutPage, RoutineCard
│   │   └── viewmodel/       # StartWorkoutViewModel
│   │
│   ├── WorkoutBegin/        # The active workout tracking panel (elapsed-timer, sets tracker)
│   │   ├── model/           # SetModel, ExerciseWithSets models
│   │   ├── view/            # WorkoutBegin UI (ExerciseCard, SetRow, WorkoutHeader)
│   │   └── viewmodel/       # WorkoutBeginCubit (BLoC/Cubit)
│   │
│   ├── WorkoutDetail/       # Log details breakdown for previous logs
│   │   ├── view/            # workout_detail_page
│   │   └── viewmodel/       # WorkoutDetailViewModel
│   │
│   ├── WorkoutRoutine/      # Specific day schedules listing exercises and sets
│   │   ├── model/           # SplitDay, ExerciseModel models
│   │   ├── view/            # WorkoutRoutine page, ModifyDayPage
│   │   └── viewmodel/       # WorkoutViewModel
│   │
│   └── WorkoutSplit/        # Dynamic builder wizard to construct splits from scratch
│       ├── view/            # WorkoutSplitPage UI
│       └── viewmodel/       # WorkoutSplitViewModel
│
├── services/
│   ├── services.dart        # Supabase API connector (signups, logins, media uploads)
│   ├── sharedpref.dart      # Device-level Shared Preferences caching helper
│   └── theme_service.dart   # Light/dark mode ChangeNotifier provider
│
├── theme/
│   └── app_colors.dart      # Color schemes, shadows, and text tokens for themes
│
└── main.dart                # Supabase initialization, provider setup, and routes navigator


================================================================================
6. PRESENTATION SLIDE-BY-SLIDE OUTLINE
================================================================================
You can use this outline to construct a slide deck (PowerPoint, Google Slides, or Canva):

SLIDE 1: Title Slide (The Hook)
*   Title: FlexFit: Elevating the Workout Tracking Experience
*   Subtitle: A Beautiful, Modern Social Workout Companion Built with Flutter & Supabase
*   Visuals: Mockup of the app logo and key dashboard screenshots (dark mode).
*   Speaker Note: "Introduce the app. Highlight that FlexFit resolves two main problems:
    it replaces basic trackers with a premium logging experience, and brings lifters 
    together through real-time workout sharing and network building."

SLIDE 2: Problem Statement
*   Points:
    - Existing trackers look basic and feel clinical (lack aesthetic polish).
    - Hard to modify routines mid-workout; lack of historical data for immediate reference.
    - Lack of community: Lifters track workouts in isolation, missing social reinforcement.
*   Speaker Note: "Discuss how current apps are either too complicated or completely 
    isolated. FlexFit builds a bridge between hardcore metrics and community engagement."

SLIDE 3: The FlexFit Solution (High-Level Overview)
*   Points:
    - Premium Visual Design: Curated theme tokens with a responsive dark & light interface.
    - Pro-Level Logging: Timer-driven active workouts with volume tracking and history logs.
    - Social Network integration: Posts, liking, commenting, and temporary stories.
*   Speaker Note: "Introduce the three main pillars of our app: Rich Aesthetics, 
    Advanced Active tracking, and Real-time Social interaction."

SLIDE 4: Feature Spotlight: Active Workout Tracker
*   Points:
    - Active Workout Session: Multi-set entry with live elapsed workout timer.
    - Previous Session Reference: View weight and reps histories directly in the active row.
    - Dynamic Manipulations: Drag-and-drop to reorder exercises, swipe-to-delete sets.
    - Smart Synchronization: Prompts whether to update Split Templates permanently 
      on workout completion.
*   Speaker Note: "Explain the active workout logging panel. This is our core differentiator, 
    giving users instant context of their progression relative to their previous workouts."

SLIDE 5: Feature Spotlight: Social Networking Ecosystem
*   Points:
    - Infinite-Scroll Social Feed: View friends' workout logs and text/media posts.
    - Disappearing Stories: Visual updates grouped by user with gallery uploading.
    - Social Connections: Find and request friends via search or direct email.
    - Dynamic Notifications: Tab bar badges alerting users of likes, comments, and requests.
*   Speaker Note: "Present the social system. It turns working out into a shared journey. 
    Users stay accountable by viewing stories and workout logs from friends."

SLIDE 6: Feature Spotlight: Profile Personalization & Goals
*   Points:
    - Goal Progress Meters: Visual progress bars mapping lift PRs vs target goals.
    - Weight Conversion Engine: Real-time, instant unit conversions (KG <-> LBS).
    - Settings & Preferences: Real-time global dark/light theme switching.
*   Speaker Note: "Detail the profiles. It acts as an analytics hub, highlighting lifting 
    PRs and personal goals with animated progress bars."

SLIDE 7: Under the Hood: Technical Architecture
*   Points:
    - UI: Flutter & Material 3, Lottie, custom responsive UI components.
    - Backend: Supabase Auth, PostgreSQL Database, and Object Storage.
    - State Management:
      * BLoC / Cubit: Highly reactive, fast-changing states (Social & Workout Sessions).
      * Provider: Global layout configurations (Theme Mode) and data repository loading.
*   Speaker Note: "Explain our architecture. The hybrid state management combines BLoC 
    for fast updates and Provider for static views, creating a responsive user experience."

SLIDE 8: Supabase Database Integration
*   Points:
    - Relational schema optimized for social graphs (Users <-> Friendships).
    - Multi-table relationships mapping training programs (Splits -> Days -> Exercises -> Sets).
    - Storage buckets separating avatar images from user posts.
*   Speaker Note: "Discuss how we leverage Supabase to handle Auth, database operations, 
    and binary file uploads without needing a heavy separate custom backend."

SLIDE 9: Project Milestones & Future Roadmap
*   Points:
    - Phase 1: Core Logging & Routine Customizer (Completed).
    - Phase 2: Supabase Integration & Multi-User Social Feed (Completed).
    - Phase 3: Wearable Integration (Apple Watch/WearOS) & Advanced Progress Charts (Roadmap).
*   Speaker Note: "Conclude by highlighting where the app stands today and our upcoming 
    goals, showing a clear vision for growth."

SLIDE 10: Q&A
*   Heading: Thank You! / Questions?
*   Visuals: Interactive app logo with active developer contact info.
================================================================================
