# ☕ Coffee Shop Flutter App

A modern, beautiful Flutter application for a coffee shop with advanced API integration, featuring authentication, shopping cart, favorites, order management, and **full dark mode support**.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

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



## 👨‍💻 Author

Kanizadev - [Your GitHub](https://github.com/kanizadev)

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
