# DarkNote - Programmatic iOS App

A highly customizable, programmatic (no Storyboard), dark-themed note-taking app built with Swift and UIKit.

## Features
- **Programmatic UI**: Built entirely without Storyboards/XIBs.
- **Dark Mode**: Deep dark theme with vibrant accents.
- **Persistence**: Notes are saved to the device's document directory (JSON).
- **Search & Filter**: Real-time search and favorites filtering.
- **Animations**: Custom micro-animations for interactions.
- **Editing**: Custom inputs for title and date tracking.

## How to Run in Xcode

Since this project was generated file-by-file, you need to create an Xcode project to run it.

1. **Open Xcode** and create a **New Project**.
2. Select **iOS > App**.
3. **Product Name**: `DarkNote` (or whatever you prefer).
4. **Interface**: Select **Storyboard** (don't worry, we'll remove it).
5. **Language**: **Swift**.
6. Create the project in a known location (e.g., Desktop).

### Importing Files
1. **Delete** the default `ViewController.swift` and `SceneDelegate.swift`, `AppDelegate.swift` from the new Xcode project.
2. **Move** the `Sources` folder from this generated project into your Xcode project folder on disk.
3. **Drag and Drop** the `Sources` folder into the Xcode Project Navigator. Make sure "Copy items if needed" is unchecked (since they are already there) and "Create groups" is selected. Check your target.

### Configuration
1. **Info.plist**:
   - If Xcode generated an `Info.plist`, you can leave it.
   - If not, or if you want to be sure, you can look at the simplified `Info.plist` provided in this package.
   - **Crucial Step**: To enable programmatic UI, open your target settings -> **General** -> **Deployment Info**. Make sure "Main Interface" is **empty** (delete "Main").
2. **Scene Manifest**:
   - Ensure your `Info.plist` (or Target -> Info -> Custom iOS Target Properties) -> `Application Scene Manifest` -> `Scene Configuration` -> `Application Session Role` -> `Item 0` -> `Scene Delegate Class Name` matches `$(PRODUCT_MODULE_NAME).SceneDelegate`.

### Run
- Select your simulator or device.
- Hit **Run (Cmd+R)**.

## Project Structure
- `Sources/Application`: AppDelegate & SceneDelegate.
- `Sources/Controllers`: ViewControllers (List, Detail).
- `Sources/Models`: Note data model.
- `Sources/Managers`: Persistence logic (NoteManager).
- `Sources/Views`: Custom UI components (NoteCell).
- `Sources/Utils`: Theme and Extensions.
