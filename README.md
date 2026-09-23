# CamotesLens — Sweet Potato Variety Classifier

A thesis project Android application that uses a CNN-based (EfficientNetB0) image classification model to assist in identifying sweet potato varieties from leaf images.

---

## Project Structure

```
CamotesLens/
├── lib/                         ← Flutter application source
│   ├── main.dart
│   ├── app/
│   │   ├── app.dart             ← Root MaterialApp
│   │   └── theme.dart           ← Material 3 theme
│   ├── models/
│   │   └── classification_result.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── image_preview_screen.dart
│   │   ├── result_screen.dart
│   │   └── about_screen.dart
│   ├── services/
│   │   ├── api_service.dart
│   │   └── image_service.dart
│   ├── widgets/
│   │   ├── primary_button.dart
│   │   ├── image_picker_card.dart
│   │   ├── confidence_card.dart
│   │   └── probability_list.dart
│   └── utils/
│       └── constants.dart
│
├── android/                     ← Android configuration
├── test/                        ← Flutter unit/widget tests
├── pubspec.yaml
│
└── backend/                     ← Python Flask API
    ├── app.py
    ├── requirements.txt
    ├── class_names.json          ← ⚠️ Replace with your variety names
    ├── .env.example
    ├── model/
    │   └── trained_model.keras   ← ⚠️ Place your trained model here
    ├── services/
    │   ├── predictor.py
    │   └── preprocessing.py
    ├── utils/
    │   └── validators.py
    └── tests/
        ├── test_validators.py
        └── test_api.py
```

---

## ⚠️ Before You Start — Required Files

You must provide **two files** from your training pipeline:

| File | Location | Description |
|------|----------|-------------|
| `trained_model.keras` | `backend/model/` | Your trained EfficientNetB0 model |
| `class_names.json` | `backend/` | Ordered list of variety class names |

### class_names.json format
```json
["Variety A", "Variety B", "Variety C", "Variety D"]
```
**IMPORTANT:** The order must exactly match the class indices used during model training (i.e., the same order as `class_indices` in your Keras `flow_from_directory` or your custom label encoder).

---

## Running the Python Backend

### 1. Set up Python environment

```powershell
cd backend
python -m venv venv
venv\Scripts\activate       # Windows
pip install -r requirements.txt
```

### 2. Place your model

Copy your trained model:
```
backend/model/trained_model.keras
```

### 3. Configure class names

Edit `backend/class_names.json` with your actual variety names.

### 4. Start the API server

```powershell
python app.py
```

The server starts on `http://0.0.0.0:5000`.

Verify it is running:
```
GET http://localhost:5000/health
```

---

## Running the Flutter App

### Prerequisites

- Flutter SDK (≥ 3.3.0)
- Android Studio / VS Code with Flutter plugin
- Android device or emulator (API 21+)

### 1. Install dependencies

```powershell
flutter pub get
```

### 2. Configure the API URL

Open [`lib/utils/constants.dart`](lib/utils/constants.dart) and set `ApiConfig.baseUrl`:

| Scenario | URL |
|----------|-----|
| Android Emulator (same machine) | `http://10.0.2.2:5000` |
| Physical Android device (same Wi-Fi) | `http://192.168.x.x:5000` (your PC's LAN IP) |

To find your PC's LAN IP on Windows:
```powershell
ipconfig
# Look for IPv4 Address under your Wi-Fi or Ethernet adapter
```

### 3. Run on device/emulator

```powershell
flutter run
```

---

## Connecting a Physical Android Phone to the Local API

1. Connect your phone to the **same Wi-Fi network** as your development PC.
2. Find your PC's local IP address (`ipconfig` → IPv4 Address under Wi-Fi).
3. Update `ApiConfig.baseUrl` in `constants.dart`:
   ```dart
   static const String baseUrl = 'http://192.168.1.100:5000';
   ```
4. Ensure Windows Firewall allows inbound connections on port 5000.
5. Rebuild and run the app.

---

## Android Permissions Required

| Permission | Purpose |
|-----------|---------|
| `CAMERA` | Capture leaf photos |
| `READ_EXTERNAL_STORAGE` | Gallery access (Android ≤ 12) |
| `READ_MEDIA_IMAGES` | Gallery access (Android 13+) |
| `INTERNET` | Communicate with the classification API |

---

## Running Tests

### Flutter tests

```powershell
flutter test
```

### Backend tests (no real model required)

```powershell
cd backend
python -m pytest tests/ -v
```

---

## Using Mock Data (UI Development Without a Server)

In `ImagePreviewScreen`, replace the `_onAnalyze` call with:
```dart
final result = ClassificationResult.mock();
```
This lets you develop and test the Result screen without a running backend.

---

## Replacing the Mock Model With Your Trained Model

1. Copy your trained model file:
   ```
   backend/model/trained_model.keras
   ```
2. Update `class_names.json` with your actual variety names in training order.
3. Restart the Flask server — it validates that model output size matches `class_names.json` at startup.
4. Test with:
   ```
   POST http://localhost:5000/predict
   Body: multipart/form-data, field "image" = your JPEG/PNG leaf image
   ```

---

## API Reference

### POST /predict

**Request:** `multipart/form-data`  
**Field:** `image` — JPEG or PNG file (max 10 MB)

**Success Response (HTTP 200):**
```json
{
  "success": true,
  "predicted_class": "VARIETY_NAME",
  "confidence": 0.94,
  "probabilities": {
    "VARIETY_1": 0.94,
    "VARIETY_2": 0.03,
    "VARIETY_3": 0.02,
    "VARIETY_4": 0.01
  }
}
```

**Error Response (HTTP 4xx/5xx):**
```json
{
  "success": false,
  "error": "Human-readable error message."
}
```

### GET /health

Returns API status and loaded class names.

---

## Classification Limitation

> **This application is an identification aid only.** The classification result should not be treated as a definitive agronomic identification. Results may be affected by image quality, lighting conditions, leaf developmental stage, disease, physical damage, and varieties not represented in the training dataset.

---

## Thesis Project Scope

This application is specifically for **sweet potato variety classification using leaf images**. It does not include:
- Plant disease diagnosis
- Tuber or yield classification  
- Plant health or pest detection
- Agronomic recommendations
- GPS, social, or marketplace features
