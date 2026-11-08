# Quotes

A calm, Apple-style quotes app for iPhone, with Home Screen and Lock Screen widgets. Built with SwiftUI, WidgetKit and App Intents for iOS 26.

## Features

- **Today**: one large serif quote on a soft gradient, with Liquid Glass buttons to favorite, share or skip. Swipe left or right to move between quotes.
- **Rotation on a schedule**: quotes change by themselves every 15 minutes, 30 minutes, 1/3/6/12 hours, or once a day. Today shows a live countdown to the next one.
- **Editable library**: 54 classic public-domain quotes to start with. Search them, filter by category, add your own, edit any quote, delete one or several at once, and restore deleted built-in quotes.
- **Favorites**: save quotes with a tap, then set the widget to show only those.
- **Night mode**: Automatic, Light or Night appearance, using a dark version of the palette.
- **Widgets**
  - Small, medium and large on the Home Screen, plus rectangular and inline on the Lock Screen.
  - Configurable: show all quotes, Favorites, My Quotes, or one category, on the app's schedule or the widget's own.
  - Interactive ♥ and → buttons to favorite or skip without opening the app.
  - Tapping the widget opens that quote in the app.

## Design

The palette comes from [Color Hunt](https://colorhunt.co/palette/f4f4f2e8e8e8bbbfca495464):

| Token | Light | Night |
| ----- | ----- | ----- |
| Paper | `#F4F4F2` | `#1E232A` |
| Mist  | `#E8E8E8` | `#2A3039` |
| Fog   | `#BBBFCA` | `#3B4552` |
| Ink   | `#495464` | `#E8E8E8` |

Typography uses New York (serif) for quotes and SF Pro for the interface.

## Project structure

```
Quotes/            App target: SwiftUI views, QuoteStore, assets
  Views/           Today, Library, Favorites, Settings, quote editor
QuotesWidget/      Widget extension: timeline provider and widget views
Shared/            Compiled into both targets: models, built-in quotes,
                   App Group storage, rotation logic, App Intents, theme
Config/            Info.plist files and entitlements
```

The app and widget share favorites, your own quotes, deleted quotes, the rotation interval and the skip offset through the App Group `group.com.sayatamanzhol.Quotes`. Which quote is shown is worked out the same way in both, so they always agree.

## Requirements

- Xcode 27 or later
- iOS 26 or later
- An Apple ID for signing (a free account works)

## Build and run

1. Open `Quotes.xcodeproj` in Xcode.
2. Select the **Quotes** target, open **Signing & Capabilities**, and choose your own team. If you use a different team, change the bundle identifiers and the App Group to ones you own.
3. Choose your iPhone or a simulator and press **Run**.

On a real device signed with a free Apple ID, trust your developer profile first: **Settings → General → VPN & Device Management**. Apps signed this way expire after 7 days, so reinstall from Xcode when that happens.

From the command line:

```bash
xcodebuild -project Quotes.xcodeproj -scheme Quotes -destination 'generic/platform=iOS Simulator' build
```

## Adding the widget

Long-press the Home Screen, tap **Edit → Add Widget**, search for **Quotes** and pick a size. Long-press the widget and choose **Edit Widget** to pick which quotes it shows and how often they change.
