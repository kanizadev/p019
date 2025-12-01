# ☕ Coffee Shop Flutter App

A modern, beautiful Flutter application for a coffee shop with advanced API integration, featuring authentication, shopping cart, favorites, order management, and **full dark mode support**.

![Flutter](https://img.shields.io/badge/Flutter-3.9.2+-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.9.2+-0175C2?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)

## ✨ Features

### Core Features
- 🔐 **User Authentication** - Secure login and sign up with persistent sessions
- ☕ **Coffee Menu** - Browse coffee items by category with beautiful UI
- 🛒 **Shopping Cart** - Add items, manage quantities, and place orders
- ❤️ **Favorites** - Save and manage your favorite coffee items
- 📦 **Order Management** - View order history and track orders
- 💳 **Payment** - Cash on delivery checkout system
- 📱 **Responsive Design** - Works seamlessly on all screen sizes

### UI/UX Features
- 🌙 **Dark Mode** - Full dark mode support with beautiful sage green theme
- 🎨 **Modern UI** - Beautiful sage green color scheme with smooth animations
- 🔄 **Pull to Refresh** - Refresh coffee items with pull-to-refresh gesture
- 🔍 **Search** - Search functionality for coffee items
- 📸 **Image Caching** - Optimized image loading with caching
- ✨ **Smooth Animations** - Delightful animations throughout the app

### Technical Features
- 🔄 **API Integration** - Advanced REST API integration with error handling
- 💾 **Local Storage** - Persistent data using SharedPreferences
- 🛡️ **Error Handling** - Comprehensive error handling with retry mechanisms
- ⚡ **Performance** - Optimized performance with efficient state management
- 🧩 **Modular Architecture** - Clean, organized code structure

## 📸 Screenshots

### Light Mode
- Beautiful sage green theme
- Clean and modern interface
- Intuitive navigation

### Dark Mode
- Fully optimized dark theme
- Easy on the eyes
- Consistent design language

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK (3.9.2 or higher)
- Android Studio / VS Code with Flutter extensions
- iOS Simulator / Android Emulator or physical device

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/coffee-shop-flutter.git
   cd coffee-shop-flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Build for Production

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

**Web:**
```bash
flutter build web --release
```

## 📁 Project Structure

```
lib/
├── auth/                    # Authentication pages
│   ├── login_page.dart
│   ├── sign_up_page.dart
│   └── edit_profile_page.dart
├── models/                  # Data models
│   ├── coffee_item.dart
│   ├── cart_item.dart
│   └── order.dart
├── services/                # API and business logic
│   └── api_service.dart
├── widgets/                 # Reusable widgets
│   ├── cart_item_widget.dart
│   ├── cart_summary_widget.dart
│   └── profile/
│       ├── header_card.dart
│       ├── stat_card.dart
│       └── order_tile.dart
├── main.dart                # App entry point
├── myhome.dart              # Home page
├── cart.dart                # Shopping cart
├── checkout.dart            # Checkout page
├── favorite.dart            # Favorites page
├── profile.dart             # User profile
├── menu.dart                # Navigation drawer
├── payment_page.dart        # Payment page
├── order_confirmation_page.dart
└── theme.dart               # App theme (light & dark)
```

## 🎨 Theme & Dark Mode

The app features a beautiful sage green color scheme with full dark mode support:

- **Light Theme**: Soft sage green palette with light backgrounds
- **Dark Theme**: Dark sage green palette optimized for low-light viewing
- **Theme Switching**: Toggle between light and dark mode from settings
- **Persistent Theme**: Theme preference is saved and restored on app restart

### Theme Colors

- **Primary**: Sage Green (#7A9E7E)
- **Secondary**: Soft Sage (#A8C686)
- **Accent**: Misty Sage (#C7D9B7)
- **Background**: Light/Dark sage wash
- **Text**: Deep woodland / Light text

## 🔌 API Integration

The app uses an advanced API service layer (`lib/services/api_service.dart`) that provides:

### Features

- **RESTful API Support** - Full HTTP client with GET/POST requests
- **Error Handling** - Comprehensive error handling with custom exceptions
- **Loading States** - Proper loading indicators during API calls
- **Retry Mechanism** - Built-in retry functionality for failed requests
- **Mock Data Fallback** - Falls back to mock data when API is unavailable
- **JSON Serialization** - Automatic JSON parsing and model conversion
- **Timeout Handling** - Request timeouts to prevent hanging requests

### API Endpoints

The app is configured to work with the following endpoints:

- `GET /api/v1/coffee/items` - Fetch all coffee items
- `GET /api/v1/coffee/items?category={category}` - Fetch items by category
- `POST /api/v1/orders` - Place a new order
- `GET /api/v1/orders/user/{userId}` - Get user orders

### Configuration

To use a real API, update the `baseUrl` in `lib/services/api_service.dart`:

```dart
static const String baseUrl = 'https://your-api-url.com/api/v1';
static const bool useMockData = false; // Set to false to use real API
```

### Mock Data Mode

By default, the app runs in mock data mode for development. The API service simulates network delays and returns mock data. This allows you to:

- Develop and test without a backend
- See how the app handles loading states
- Test error scenarios

To switch to real API mode, set `useMockData = false` in `api_service.dart`.

## 📦 Dependencies

### Core Dependencies

- `flutter` - Flutter SDK
- `http` - HTTP client for API calls
- `shared_preferences` - Local storage
- `google_fonts` - Custom fonts (Lato & Playfair Display)

### UI Dependencies

- `cached_network_image` - Image caching and loading
- `shimmer` - Loading placeholders
- `badges` - Badge widgets
- `carousel_slider` - Image carousels
- `animations` - Smooth animations

### Other Dependencies

- `provider` - State management (available but not used)
- `sqflite` - SQLite database (available)
- `image_picker` - Image picking functionality
- `intl` - Internationalization support

## 🏗️ Architecture

The app follows a clean architecture pattern:

- **Models**: Data classes representing business entities
- **Services**: API and business logic layer
- **Widgets**: Reusable UI components
- **Pages**: Screen-level widgets
- **Theme**: Centralized theme configuration

### State Management

Currently uses Flutter's built-in `setState` for state management. For larger apps, consider migrating to:
- Provider
- Riverpod
- Bloc
- GetX

## 🧪 Testing

Run tests with:
```bash
flutter test
```

## 📱 Platform Support

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows (partial)
- ✅ macOS (partial)
- ✅ Linux (partial)

## 🐛 Error Handling

The app handles various error scenarios:

- **Network Errors** - Shows retry option
- **API Errors** - Displays error messages with status codes
- **Timeout Errors** - Handles request timeouts gracefully
- **JSON Parsing Errors** - Falls back to mock data
- **Empty States** - Beautiful empty state screens

## 🔮 Future Enhancements

- [ ] Add real backend API integration
- [ ] Implement caching strategy
- [ ] Add offline mode support
- [ ] Implement push notifications
- [ ] Add payment gateway integration (Stripe, PayPal)
- [ ] Implement user reviews and ratings
- [ ] Add advanced search functionality
- [ ] Implement pagination for large datasets
- [ ] Add social login (Google, Apple)
- [ ] Implement loyalty program
- [ ] Add order tracking with maps
- [ ] Implement push notifications for order updates

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Author

Your Name - [Your GitHub](https://github.com/yourusername)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design for design guidelines
- Unsplash for beautiful coffee images
- All contributors and supporters

## 📞 Support

If you have any questions or need help, please:
- Open an issue on GitHub
- Contact the maintainers
- Check the documentation

---

Made with ❤️ using Flutter
