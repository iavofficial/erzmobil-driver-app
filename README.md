# ERZmobil Driver

This project contains the code for the Erzmobil Driver App.

## Getting Started
These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

What you need to install the app and how to install the app

-   [Visual Studio Code](https://code.visualstudio.com/) (recommended)
-   [Android Studio](https://developer.android.com/studio/) (optional)
-   [XCode](https://developer.apple.com/xcode/) (required for iOS)
-   [Flutter](https://docs.flutter.dev/get-started/install) (Version 2.2.3, Dart 2.13.4 )

### Run the project

In Visual Studio Code, open the project, go to the Terminal and type `flutter run`

## Configuration

### Cognito

The cognito configuration (user pool, region, etc) can be edited in the `lib/Amazon` file.

### Backend URLs, Text Styles, Constants

The base url for the backend communication is defined at `lib/Amazon.baseUrl`, the custom endpoints for the communication are defined in the `lib/Constants` class. This class also contains various constants like urls, phone numbers, text styles and custom colors.

### Localization

The texts files can be found here: `lib/l10n`

## How to build a release for Android

1. Make sure you have an existing keystore and the key.properties file set up. If not follow the steps described [here](https://docs.flutter.dev/deployment/android#create-an-upload-keystore)
2. Afterwards you can run `flutter build apk` or `flutter build appbundle`.
3. Grab the artifacts from `build\app\outputs\flutter-apk\app-release.apk/` or `build\app\outputs\bundle\release\app-release.aab`

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.