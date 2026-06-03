# Food Delivery App

A cross-platform **Flutter** food ordering app with a dark UI. Browse menus by category, view item details, manage a cart, and sign in with **Firebase Authentication**. Menu data is loaded from **Cloud Firestore**.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore%20%7C%20Storage-FFCA28?logo=firebase)
![Dart](https://img.shields.io/badge/Dart-2.19+-0175C2?logo=dart)

## Features

- **Home** — Category shortcuts (Burger, Recipe, Pizza, Drinks) and featured items from Firestore
- **Category browsing** — Tap a category to see its items
- **Food details** — Image, price, quantity selector, add to cart
- **Shopping cart** — View items, adjust quantity, see totals
- **Authentication** — Email/password sign-up and login (Firebase Auth)
- **State management** — [Provider](https://pub.dev/packages/provider) for cart and Firestore-backed lists

## Tech stack

| Layer        | Technology                          |
|-------------|--------------------------------------|
| Framework   | Flutter                              |
| Backend     | Firebase (Auth, Firestore, Storage)  |
| State       | Provider                             |
| Language    | Dart                                 |


## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel recommended)
- [Android Studio](https://developer.android.com/studio) or VS Code with Flutter extensions
- A [Firebase](https://console.firebase.google.com/) project with:
  - **Authentication** — Email/Password enabled
  - **Cloud Firestore** — Database with your menu collections (see [Firestore structure](#firestore-structure))
  - **Firebase Storage** (optional, for hosting images)
