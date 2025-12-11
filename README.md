# KetoPilot 🚀

A sophisticated Flutter application for metabolic health optimization, focused on gram-centric macro tracking and biomarker monitoring for ketogenic therapy.

# Mission Statement

To provide transformative support and encouragement for individuals who might be:

- a diabetic tracking their glucose and estimated insulin levels
- mental health focused individuals with bipolar disorder, schizophrenia, or epilepsy, tracking ketone levels
- the cancer patient who is augmenting their standard of care with a diet targeting their glucose ketone index (GKI).
- the N=1 citizen scientist who is curious about their own metabolic health
- the loving parent who is taking care of their child due to their epilepsy or type 1 diabetes
- the stalwart endurance athlete who is dialing in their optimal fueling strategy
- a scientist, researcher, and student developing next generation biosensing systems

In their own individual way, each is pursuing and enabling transformation through personalized precision management of their metabolic state.

## 📱 Features

### Core Functionality

- **Gram-Centric Tracking**: Focus on grams rather than calories for precise macro management
- **Smart Goal System**: Different approaches for carbs (limits) vs protein/fat (goals)
- **Biomarker Monitoring**: Track glucose, BHB (ketones), and GKI (Glucose Ketone Index)
- **Real-time Health Status**: Color-coded indicators for optimal, good, and high ranges
- **Animated Progress Bars**: Beautiful visual feedback for daily nutrition progress

### UI/UX Excellence

- **Professional Medical Theme**: Clean, medical-grade green color scheme
- **Responsive Design**: Optimized for all screen sizes from iPhone SE to iPad Pro
- **MacroFactor-Inspired Design**: Clean bottom navigation with floating action button
- **Swipeable Views**: Swipe between Daily and Weekly views for both Nutrition and Biomarkers
- **Smooth Animations**: Polished micro-interactions throughout the app

### Dashboard Features

- **Daily & Weekly Nutrition**: Swipe between daily macro bars and weekly nutrition trends
- **Daily & Weekly Biomarkers**: Toggle between current readings and weekly biomarker patterns
- **GKI Circle Display**: Prominent glucose-ketone index with color-coded health status
- **Quick Actions Grid**: Fast access to logging, food diary, health tracking, and analytics
- **Health Metrics Overview**: Weight, heart rate, and other key indicators
- **Recent Readings**: Timeline of recent glucose and ketone measurements

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- iOS Simulator or Android Emulator
- Xcode (for iOS development)
- Android Studio (for Android development)

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/rvru/KetoPilot.git
   cd KetoPilot
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Generate auto route files**

   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the application**

   ```bash
   # iOS Simulator
   flutter run -d ios

   # Android Emulator
   flutter run -d android

   # macOS Desktop
   flutter run -d macos

   # Web Browser
   flutter run -d chrome
   ```

## 🍎 macOS Development Setup & Troubleshooting

If you encounter issues setting up the macOS environment, follow these troubleshooting steps based on common problems:

### 1. Flutter Command Not Found

If `flutter devices` returns `command not found`, add Flutter to your PATH permanently:

1. Open your config file: `nano ~/.zshrc`
2. Add this line at the bottom (adjust path to your installation):
   ```bash
   export PATH="$PATH:[PATH_TO_FLUTTER_GIT_DIRECTORY]/bin"
   ```
3. Save (Ctrl+O, Enter) and Exit (Ctrl+X).
4. Refresh terminal: `source ~/.zshrc`

### 2. Xcode & "xcodebuild" Errors

If you see `xcrun: error: unable to find utility "xcodebuild"`, you need the full Xcode app, not just command line tools.

- **Version Note:** If you are on macOS Sonoma (14.x), do not try to install the latest Xcode (which requires macOS 15). Download **Xcode 16.2** or **Xcode 15.4** from the [Apple Developer Downloads](https://developer.apple.com/download/all/) page.
- After installing, link it:
  ```bash
  sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
  sudo xcodebuild -runFirstLaunch
  ```

### 3. CocoaPods Installation Issues

If `sudo gem install cocoapods` fails due to Ruby version incompatibility:

- **Recommended:** Use Homebrew.
  ```bash
  brew install cocoapods
  ```
- **Alternative:** Install older compatible versions.
  ```bash
  sudo gem install drb -v 2.0.6
  sudo gem install activesupport -v 6.1.7.7
  sudo gem install cocoapods -v 1.14.3
  ```

### 4. Pod Install Permission Error (.netrc)

If `pod install` fails with `Permission bits for '/Users/.../.netrc' should be 0600`, run:

```bash
chmod 0600 ~/.netrc
```

## 📊 Core Widgets

### MacroBarsWidget

Displays daily macro consumption with animated vertical bars:

- **Carbs**: Red bars with dotted limit lines
- **Protein**: Blue bars with solid goal lines
- **Fat**: Green bars with solid goal lines
- Color changes when limits are exceeded

### MoleculeBarsWidget

Shows biomarker readings with health status indicators:

- **Glucose**: Orange bars (mg/dL) with optimal/good/high status
- **BHB**: Yellow bars (mmol/L) with ketosis indicators
- **GKI**: Blue bars with optimal ranges

### SwipeableSectionWidget

Container for Daily/Weekly views with:

- Smooth PageView transitions
- Tab indicators showing current view
- Visual swipe hints
- Consistent action buttons

## 🎨 Design System

### Color Palette

- **Primary**: Medical green (#4CAF50)
- **Secondary**: Complementary medical blue
- **Status Colors**:
  - Optimal: Green
  - Good: Orange
  - Critical: Red
- **Background**: Clean whites and light grays

### Typography

- **Headlines**: Bold, medical-grade typography
- **Body Text**: Clean, readable sans-serif
- **Data Values**: Emphasized numerical displays
- **Status Labels**: Color-coded health indicators

## 🏗️ Architecture

### Clean Architecture Implementation

```
lib/
├── core/                   # Core utilities and constants
│   ├── constants/         # App-wide constants
│   ├── themes/           # Theme configuration
│   └── router/           # Auto route configuration
├── features/             # Feature-based organization
│   ├── dashboard/        # Main dashboard feature
│   ├── data_entry/       # Biomarker logging
│   ├── food_diary/       # Nutrition tracking
│   └── health_logging/   # Symptom tracking
└── shared/              # Shared widgets and utilities
    ├── widgets/         # Reusable UI components
    └── extensions/      # Dart extensions
```

### State Management

- **Riverpod**: For reactive state management
- **Freezed**: For immutable data classes
- **Auto Route**: For declarative navigation

## 📈 Data Models

### HealthMetric

```dart
@freezed
class HealthMetric with _$HealthMetric {
  const factory HealthMetric({
    required String id,
    required DateTime timestamp,
    required double value,
    required String unit,
    required HealthMetricType type,
  }) = _HealthMetric;
}
```

### FoodEntry

```dart
@freezed
class FoodEntry with _$FoodEntry {
  const factory FoodEntry({
    required String id,
    required String name,
    required double carbsGrams,
    required double proteinGrams,
    required double fatGrams,
    required DateTime timestamp,
  }) = _FoodEntry;
}
```

## 🔧 Development Tools

### Code Generation

```bash
# Generate freezed classes
flutter packages pub run build_runner build

# Watch for changes (development)
flutter packages pub run build_runner watch
```

### Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter drive --target=test_driver/app.dart
```

### Build & Release

```bash
# Build for iOS
flutter build ios --release

# Build for Android
flutter build appbundle --release

# Build for macOS
flutter build macos --release

# Build for Web
flutter build web --release
```

## 📱 Platform Support

| Platform | Status       | Notes                   |
| -------- | ------------ | ----------------------- |
| iOS      | ✅ Supported | iOS 11.0+               |
| Android  | ✅ Supported | Android 6.0+ (API 23+)  |
| macOS    | ✅ Supported | macOS 10.14+            |
| Web      | ✅ Supported | Chrome, Safari, Firefox |
| Windows  | 🔄 Planned   | Future release          |
| Linux    | 🔄 Planned   | Future release          |

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Follow the established clean architecture patterns
- Use Freezed for data models
- Implement proper error handling
- Add unit tests for new features
- Follow the existing design system
- Ensure responsive design across all screen sizes

## 📅 Recent Updates (Dec 7, 2025)

### Sharing & Privacy Module

Implemented a comprehensive sharing system allowing users to export their progress as beautiful, customizable cards.

- **Sharing Hub**: Centralized dashboard for all sharing activities.
  - **macOS Integration**: "Preview" button simulates Instagram sharing by opening the generated image file directly.
  - **Android Integration**: Direct sharing to Instagram and Facebook using platform channels.
- **Dynamic Share Cards**:
  - **Morning Focus**: Sunrise gradient with glucose/ketone stats and motivational quotes.
  - **Night Reflection**: Dark theme with mood tracking and editable reflection notes.
  - **Challenge Card**: High-energy design for workout stats and achievements.
- **Privacy Controls**: Granular toggles to include/exclude Glucose, Ketones, Weight, Macros, and Notes.
- **History Tracking**: Local log of all shared items with mode-specific icons (☀️, 🌙, 🏆).

