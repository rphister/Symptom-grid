# SymptomGrid – iOS SwiftUI App (Editable & Saveable)

This app shows your **symptoms in rows** and **time of day in columns** (Morning, Midday, Evening, Night). Each cell is editable (pain 0–10, numbness on/off, stiffness level, notes) and **automatically saved** locally on your device. You can switch days with the date picker and export a CSV for a given date.

## How to set up (Xcode on Mac + iPhone)
1. Open **Xcode** → **File > New > Project…** → choose **App** (iOS), click **Next**.
2. Product Name: `SymptomGrid`, Interface: **SwiftUI**, Language: **Swift**. Click **Next**, choose a folder, then **Create**.
3. In the new project, **delete** the default `ContentView.swift` and `<ProjectName>App.swift` files.
4. Drag the files from this folder into Xcode's Project Navigator (or use **File > Add Files to "SymptomGrid"...**):
   - `SymptomGridApp.swift`
   - `Models.swift`
   - `LogStore.swift`
   - `ContentView.swift`
   - `Editors.swift`
   - `CSVExporter.swift`
   - `ActivityView.swift`
5. In the Xcode toolbar, choose your **iPhone** (connected via cable or on same Wi‑Fi with developer mode) as the run target.
6. Press **Run** (▶). The app will install and run on your iPhone.

> **Note:** The app saves to a local JSON file in your app’s Documents folder. No accounts or servers needed.

## What you get
- **Grid view**: Rows for Hands, Elbows, Shoulders, Knees, Ankles; columns for Morning, Midday, Evening, Night.
- **Tap any cell** to edit pain (0–10), numbness, stiffness (None/Mild/Moderate/Severe), and notes.
- **Auto-save** after every change.
- **Date picker** to switch days quickly.
- **Export CSV** for the selected date (Share/Save anywhere).
- **Reset day** to clear entries if needed.

## Customize rows/columns
Open `Models.swift` and edit `BodyArea.allCases` (add/remove rows) or `TimeSlot.allCases` (add/remove columns). The app adapts automatically.

## Troubleshooting
- If you see a blank grid or an error, stop the app, clean build (Shift+Cmd+K), then build again.
- Make sure iOS Deployment Target (in Project settings → iOS Deployment Target) is **iOS 16.0** or newer.
- If CSV sharing doesn’t appear, check iPhone permissions for the app.
