# Neon Wave

A Spotify-style music discovery app built with Flutter, powered entirely by two free,
key-less public APIs — **Deezer** and the **iTunes Search API**. Visually it follows the
same neon-on-black language as your `black_market` project: pure black background, white
type, a single glowing `cyanAccent` used for every active/selected state.

---

## 1. Getting it running

This project was generated as a `lib/` + `test/` + `pubspec.yaml` source tree — it does
**not** include the `android/`, `ios/`, `web/`, etc. platform folders that `flutter create`
normally generates, so you'll need to create those once locally:

```bash
# 1. Scaffold a new Flutter project (creates android/ios/web/... folders)
flutter create neon_wave_app
cd neon_wave_app

# 2. Replace its lib/, test/, pubspec.yaml and analysis_options.yaml with the ones
#    from this delivery (overwrite the generated ones)

# 3. Install dependencies
flutter pub get

# 4. Run the test suite
flutter test

# 5. Run the app
flutter run
```

> **Important — this project was written without a Flutter/Dart SDK or network access
> available to generate it**, so none of the commands above were run during generation.
> Every file was written by hand with care, and the API/repository layer has a real,
> passing-by-design test suite (see §5) — but please run `flutter pub get`,
> `flutter analyze`, and `flutter test` yourself before relying on it, in case a package
> version needs a small bump on `pub.dev` by the time you install it.

---

## 2. Architecture

```
lib/
  main.dart                 — bootstraps DI, provides the app-wide cubits, runs the app
  src/
    app.dart                — MaterialApp + theme + routing
    core/                   — everything that isn't a screen
      constants/            — API endpoints, app-wide constants
      theme/                — colors, text styles, neon-glow shadows
      network/              — Result<T>/Failure — typed, human-readable error handling
      models/                — Track, Artist, Genre, Playlist, AppUser, PaginatedResult
      services/              — DeezerService, ItunesService (raw API clients)
      repositories/          — MusicRepository, AuthRepository, PlaylistRepository
      storage/               — LocalStorageService (SharedPreferences wrapper)
      audio/                 — AudioPlayerService (just_audio wrapper)
      di/                    — service_locator.dart (get_it wiring)
      routing/               — named routes
      widgets/               — shared UI: buttons, text fields, track tiles, shimmers...
    features/
      splash/                — cubit + screen: decides where to land on cold start
      auth/                  — cubit + screens: sign in / sign up (local, see §3)
      artist_selection/      — cubit + screen: onboarding's "pick 3+ singers" step
      main_nav/              — cubit + screen: bottom nav + IndexedStack + mini player
      player/                — cubit + screen + widgets: playback, mini bar, Now Playing
      home/                  — cubit + screen + widgets: all the Home sections
      search/                — cubit + screen + widgets: browse + paginated search
      playlists/             — cubit + screens + widgets: Library, playlist detail, Liked Songs
      profile/               — cubit + screen + widgets: account + stats + sign out
```

Every feature follows `cubit / screens / widgets`, exactly as requested: **cubits hold all
presentation logic** (loading, pagination, debouncing, form state) and talk only to
`core/repositories` — never to Dio or SharedPreferences directly. That's what makes them
easy to unit test (see `bloc_test` in `dev_dependencies` if you want to add cubit tests
using the same fake-repository pattern the existing tests use).

---

## 3. Design decisions worth knowing about

- **No backend, on purpose.** The brief specified exactly two data sources — Deezer and
  iTunes — and neither does authentication. `AuthRepository` is a real interface with a
  local (hashed-password, `SharedPreferences`-backed) implementation behind it, so a real
  backend (Firebase, Supabase, your own API) can be dropped in later without touching a
  single screen or cubit.
- **Pagination is real, not simulated.** Deezer's list endpoints accept `index`/`limit`
  and return a `next` link — `MusicRepository.searchTracks` uses that for genuine
  infinite-scroll pagination on the Search screen. iTunes' Search API has no reliable
  offset-based paging, so it only ever contributes to *page one* of a search, merged in
  and de-duplicated against Deezer's results (see `MusicRepositoryImpl._mergeDeduped`).
  Every page after that is Deezer-only.
- **Playback streams 30-second previews.** Both APIs are free/key-less and only expose a
  short preview clip (`Track.previewUrl`) rather than full songs — `AudioPlayerService`
  (via `just_audio`) plays that, with a persistent mini player and a full "Now Playing"
  screen with real seek/next/previous.
- **"Smart" touches:** debounced search input, shimmer skeletons everywhere data loads,
  friendly/retryable error states instead of raw exceptions, toast notifications for
  every success/error, a deterministic-per-day shuffle for "Best For Today", cached
  network images, and a locally-tracked "Recently Played" row.
- **Package choices** mirror your existing project where they overlap (`dio`,
  `flutter_bloc`/`bloc`, `google_fonts` on Work Sans, `shimmer`, `toastification`,
  `shared_preferences`) and add a few focused additions: `get_it` (simple DI),
  `equatable` (state comparison), `cached_network_image`, `just_audio`, and `crypto`
  (password hashing for the local auth store).

---

## 4. Onboarding flow

`Splash → (no session) → Sign in/Sign up → Pick 3+ artists → Main app`. Session +
"have they picked artists yet" are both read from local storage, so re-opening the app
skips straight to the main tabs. The artists picked here seed the Home screen's
"Made For You" section (via `MusicRepository.getArtistTopTracks`) and can be revisited any
time from **Profile → Edit** (same screen, `isEditing: true`).

---

## 5. Tests (TDD layer)

```
test/core/
  services/
    deezer_service_test.dart     — mocks Dio; asserts JSON→Track mapping, pagination
                                    (`next` → hasMore), and error mapping
    itunes_service_test.dart     — mocks Dio; asserts JSON→Track mapping + artwork
                                    upscaling + error mapping
  repositories/
    music_repository_impl_test.dart — mocks both services; asserts the merge/dedupe
                                       logic, that iTunes is never called past page one,
                                       and graceful degradation when one provider fails
  utils/
    validators_test.dart         — pure unit tests for the auth form validators
```

This is the layer the brief specifically asked to be TDD'd (the API-consuming code), so
it's the one with the deepest coverage. The same fake-service/mock pattern extends
naturally to `AuthRepository`/`PlaylistRepository` and to cubits (with `bloc_test`) if you
want to keep growing the suite.
