<p align="center">
  <img width="250" alt="XpenseTracker home" src="https://github.com/jlcl11/XpenseTracker/assets/92518378/f43852d4-33c2-469c-8dac-23f86b421a9a" />
  <img width="250" alt="XpenseTracker new movement" src="https://github.com/jlcl11/XpenseTracker/assets/92518378/c70c4917-9024-4f63-a6cd-52e1ac17b149" />
  <img width="250" alt="XpenseTracker graph" src="https://github.com/jlcl11/XpenseTracker/assets/92518378/8a76fe05-a63c-4935-a814-ff3540e13a53" />
</p>

<h1 align="center">
  <br>
  XpenseTracker
  <br>
</h1>

<h3 align="center">A clean UIKit expense tracker with Firebase auth, Firestore and interactive charts.</h3>

<p align="center">
  <strong>UIKit</strong> &nbsp;·&nbsp; <strong>Firebase Auth</strong> &nbsp;·&nbsp; <strong>Cloud Firestore</strong> &nbsp;·&nbsp; <strong>Interactive Charts</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=apple&logoColor=white" alt="iOS">
  <img src="https://img.shields.io/badge/Swift-F05138?style=for-the-badge&logo=swift&logoColor=white" alt="Swift">
  <img src="https://img.shields.io/badge/UIKit-2396F3?style=for-the-badge&logo=apple&logoColor=white" alt="UIKit">
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase">
  <img src="https://img.shields.io/badge/Google_Sign--In-4285F4?style=for-the-badge&logo=google&logoColor=white" alt="Google Sign-In">
</p>

---

## What is XpenseTracker

XpenseTracker (SpendR) is a personal-finance iOS app to record expenses and income, organise them with custom tags, and visualise spending patterns over time. It's a 2023 portfolio project focused on showing UIKit fluency and Firebase integration, with a classic MVC structure.

Built with UIKit screens, Firebase Authentication (email/password + Google Sign-In) and Cloud Firestore for persistence. Dependencies are managed with CocoaPods.

---

## Features

| | |
|---|---|
| **Track** | Record expenses and income with amount, category, description and date. Mark each as income or expense. |
| **Organise** | Custom tags per movement for flexible categorisation. Tag manager in the user page. |
| **Visualise** | Interactive charts of spending trends and category breakdowns. |
| **Filter** | Sortable, filterable history table with real-time balance updates. |
| **Auth** | Email + password sign-up/login backed by Firebase Auth. Google Sign-In for one-tap onboarding. |
| **Profile** | Edit personal details, preferred currency, and tag library from the user page. |

---

## Screens

| Screen | What it does |
|---|---|
| **Home** | Personalised welcome, dynamic balance, "Add Movement" CTA, sortable history |
| **New Movement** | Capture amount, category, description, tags and income/expense flag |
| **Movement Detail** | Full transaction info with single-tap delete |
| **User Page** | Profile editor, currency selector, tag management |
| **Graph** | Interactive chart of spending trends and category mix |
| **Login / Sign-Up** | Firebase email + password or Google Sign-In |

---

## Architecture

```
SpendR/                           CocoaPods workspace
  Podfile                         CocoaPods dependency manifest
  SpendR.xcworkspace              Open this (not the .xcodeproj)
  SpendR/                         Main app target
    AppComponents/                AppDelegate / SceneDelegate
    Controllers/
      InitialViews/               Login / SignUp view controllers
      LoggedInViews/              Home, Graph, UserPage and movement view controllers
      utilVCs/                    Reusable horizontal tag scroller
    Models/                       Movement, Tag, User
    Utils/                        FirebaseOperations, UserManager, extensions
    Views/                        Storyboards and XIBs
  SpendRUITests/                  XCUITest flows: login, sign-up, home, movements
```

---

## Quick Start

**Requirements:** Xcode 15+ · iOS 17+ · CocoaPods · Firebase project (Auth + Cloud Firestore enabled)

```bash
git clone https://github.com/jlcl11/XpenseTracker.git
cd XpenseTracker/SpendR
pod install
open SpendR.xcworkspace
```

Drop your `GoogleService-Info.plist` into the project (Firebase console → iOS app), enable Email/Password + Google Sign-In providers, then build and run.

---

## Tech Stack

| Technology | Role |
|---|---|
| **UIKit** | Core view layer — controllers, storyboards, programmatic constraints |
| **Firebase Auth** | Email + Google Sign-In authentication |
| **Cloud Firestore** | Cloud-stored documents for movements, tags and user profile |
| **Charts** | Interactive chart rendering for spending trends |
| **SymbolPicker** | Symbol picker for tag and category icons |
| **CocoaPods** | Dependency management |
| **XCTest** | UI tests for login, sign-up, home and movements |

---

<p align="center">
  Built by <a href="https://github.com/jlcl11">Jose Luis Corral Lopez</a> · Portfolio sample showing UIKit + Firebase
</p>
