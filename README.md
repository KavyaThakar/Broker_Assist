#BrokerAssist
#Overview

BrokerAssist is a Flutter-based mobile application designed to simplify communication and data management between brokers and clients.
The application enables brokers to manage IPOs, portfolios, reports, reminders, and notifications, while clients can view shared data, download reports, and communicate securely.

The project uses Firebase for authentication, database storage, and real-time updates, and Provider for state management.

#Features
Authentication
Email & Password login using Firebase Authentication
Phone OTP login using Firebase Authentication
Role-based access (Broker / Client)
Broker Features
Add and manage IPO details
Create and assign reports to specific clients
Share reminders and notifications
Manage client portfolios
Chat with clients in real-time
Client Features
View IPO listings
View assigned reports
Download reports as PDF files
Receive reminders and notifications
View portfolio details
Chat with broker
Reports & Documents
Reports stored in Firebase
PDF generation for all report types
PDF download to public Downloads folder on Android

#Technology Stack
Frontend
Flutter
Dart
Material UI
State Management
Provider (ChangeNotifier)
Backend & Services
Firebase Authentication
Cloud Firestore
Firebase Cloud Messaging (local notifications support)
SharedPreferences (local caching)

#Utilities

PDF generation (pdf package)
File storage & permissions
