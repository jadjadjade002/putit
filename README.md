# 📍 PutIT — Spatial Memory & Smart Pack Assistant
> **Swift Playgrounds 4.6+ App Playground (iPadOS & macOS)**  
> Developed for **Young iOS Developer Hackathon 2026**

---

## 🌟 Overview
**PutIT** is an on-device spatial intelligence assistant designed to solve the everyday pain point of misplacing household items. By leveraging Apple's on-device **Neural Engine (Vision Framework 1,300+ Taxonomy)** and **SwiftData**, PutIT allows users to take a photo of where they store an item, automatically detects and pins the item on the photo, recommends common storage spots, tracks relocation history, and assists with packing checklists.

---

## 🚀 Key Features

### 1. 🎯 AI Auto-Pin & Visual Anchor
- Uses Apple Vision saliency and dual-pass classification to automatically place a pulsing target pin on the object in the photo.
- Normalized coordinate mapping ensures accurate pin placement across iPad orientations and aspect ratios.

### 2. 🧠 Apple Vision 1,300+ Taxonomy Engine
- Powered by `VNClassifyImageRequest` directly on Apple Neural Engine with comprehensive bilingual mapping.
- 100% offline — zero cloud dependency, zero external API latency, zero privacy leaks.

### 3. 💡 Smart Spatial Recommendation
- Analyzes existing storage habits in SwiftData and auto-suggests the room, cabinet, and drawer for similar items.

### 4. 🎙️ Natural Language Voice Search
- Speech-to-text powered by `SFSpeechRecognizer` with custom keyword parsing for fast hands-free item retrieval.

### 5. 🧳 Smart Pack & Travel Checklist
- Contextual packing checklists for **Travel**, **Work**, and **Daily Essentials**.
- Dynamically links each checklist item to your saved inventory, displaying its exact room/shelf and visual photo pin.

### 6. 🌐 15 Global Languages
- Full localized dictionary supporting:
  🇹🇭 Thai, 🇬🇧 English, 🇪🇸 Spanish, 🇫🇷 French, 🇩🇪 German, 🇨🇳 Mandarin, 🇯🇵 Japanese, 🇰🇷 Korean, 🇧🇷 Portuguese, 🇮🇹 Italian, 🇷🇺 Russian, 🇸🇦 Arabic, 🇮🇳 Hindi, 🇹🇷 Turkish, 🇻🇳 Vietnamese.
- Includes a smooth Slide-Out sheet modal picker with live search.

---

## 📱 Platform & Requirements
- **Target Platform:** iPadOS 17.0+ / macOS Sonoma 14.0+
- **Development Tool:** Swift Playgrounds 4.6+ / Xcode 16+
- **Architecture:** 100% Swift, SwiftUI, SwiftData, Apple Vision, Speech Framework.
- **Privacy:** 100% On-Device (No tracking, no external network requests).

---

## 📦 How to Run on iPad
1. Download `PutIT.swiftpm.zip` or clone this repository.
2. In the **Files (ไฟล์)** app on iPad, tap `PutIT.swiftpm.zip` to unarchive.
3. Tap **`PutIT.swiftpm`** to launch directly in **Swift Playgrounds**.

---

## 👨‍💻 License & Author
Built with ❤️ for **Young iOS Developer Hackathon 2026**.
