# 🍳 Recipe App

A beautiful Flutter recipe application featuring a modern glassmorphism design with a sage green color scheme. Browse recipes from TheMealDB API, create your own custom recipes, and save your favorites.

![Flutter](https://img.shields.io/badge/Flutter-3.9.2+-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.9.2+-0175C2?logo=dart&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-blue)

## ✨ Features

- **🌐 API Integration**: Fetch random recipes from TheMealDB API
- **➕ Custom Recipes**: Create and edit your own recipes with full details
- **❤️ Favorites**: Save your favorite recipes for quick access
- **🔍 Search & Filter**: Search recipes by name and filter by category
- **📸 Image Support**: Add photos to your recipes from camera or gallery
- **🎨 Beautiful UI**: Glassmorphism design with sage green theme
- **📱 Responsive**: Works seamlessly on Android, iOS, Web, Windows, macOS, and Linux

## 🎨 Design

The app features a stunning glassmorphism design with:
- Frosted glass effects using `BackdropFilter`
- Sage green color palette (`#87A96B`, `#6B8E5A`, `#9CAF88`)
- Smooth animations and transitions
- Minimal, clean interface with white text and icons
- Gradient backgrounds for visual depth

## 📸 Screenshots

*Add screenshots of your app here*

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK (3.9.2 or higher)
- Android Studio / VS Code with Flutter extensions
- For iOS: Xcode (macOS only)
- For Android: Android SDK

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/p019.git
   cd p019
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Platform-Specific Setup

#### Android
- Minimum SDK: 21
- Target SDK: Latest
- No additional configuration needed

#### iOS
- Minimum iOS version: 12.0
- Run `pod install` in the `ios` directory if needed

#### Web
- No additional setup required
- Run with `flutter run -d chrome`

## 📦 Dependencies

- **flutter**: SDK
- **http**: ^1.2.0 - For API calls
- **google_fonts**: ^6.2.1 - Beautiful typography
- **image_picker**: ^1.1.2 - Camera and gallery access
- **cupertino_icons**: ^1.0.8 - iOS-style icons

## 🏗️ Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── recipe.dart          # Recipe data model
├── screens/
│   ├── main_screen.dart     # Main navigation screen
│   ├── recipe_list_screen.dart    # Recipe browsing
│   ├── recipe_detail_screen.dart   # Recipe details
│   ├── favorites_screen.dart       # Favorites list
│   └── add_edit_recipe_screen.dart # Create/edit recipes
├── services/
│   └── recipe_api_service.dart     # TheMealDB API integration
└── widgets/
    └── glass_widget.dart    # Reusable glassmorphism widget
```

## 🔧 Usage

### Browsing Recipes
- The home screen displays recipes fetched from TheMealDB API
- Tap on any recipe card to view full details
- Use the search bar to find specific recipes
- Filter by category using the category chips

### Creating Custom Recipes
1. Tap the "+" button in the bottom navigation
2. Fill in recipe details:
   - Title and description
   - Category
   - Prep time, cook time, and servings
   - Ingredients (add multiple)
   - Instructions (add multiple steps)
   - Recipe photo (optional)
3. Tap the save icon to save your recipe

### Managing Favorites
- Tap the heart icon on any recipe to add it to favorites
- View all favorites in the Favorites tab
- Remove favorites by tapping the heart icon again

## 🌐 API

The app uses [TheMealDB API](https://www.themealdb.com/api.php) to fetch recipe data:
- Random recipes endpoint
- Recipe search functionality
- Category filtering

## 🎨 Color Palette

- **Primary Sage Green**: `#87A96B`
- **Dark Sage Green**: `#6B8E5A`
- **Light Sage Green**: `#9CAF88`
- **Deeper Sage**: `#5A7A4A`
- **Dark Text**: `#2C3E2D`
- **White Text/Icons**: `#FFFFFF`

## 🛠️ Development

### Running Tests
```bash
flutter test
```

### Building for Production

#### Android
```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

#### Web
```bash
flutter build web --release
```

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 👤 Author

Your Name - [@yourusername](https://github.com/yourusername)

## 🙏 Acknowledgments

- [TheMealDB](https://www.themealdb.com/) for providing the recipe API
- Flutter team for the amazing framework
- Google Fonts for beautiful typography

## 📮 Contact

Project Link: [https://github.com/yourusername/p019](https://github.com/yourusername/p019)

---

Made with ❤️ using Flutter
