# CamotesLens — Implementation Plan

## Architecture

```
CamotesLens/
├── frontend/          ← Flutter Android App
│   ├── lib/
│   │   ├── main.dart
│   │   ├── app/
│   │   ├── models/
│   │   ├── screens/
│   │   ├── services/
│   │   ├── widgets/
│   │   └── utils/
│   ├── pubspec.yaml
│   └── android/
└── backend/           ← Python Flask/FastAPI API
    ├── app.py
    ├── requirements.txt
    ├── class_names.json
    ├── model/
    ├── services/
    └── utils/
```

## Phase Execution Order
1. Flutter project scaffold + pubspec.yaml
2. App theme + constants
3. Models (ClassificationResult)
4. Services (ApiService, ImageService)
5. Widgets (reusable components)
6. Screens (Home, Preview, Result, About)
7. Backend (Flask API, preprocessing, predictor)
8. Tests
