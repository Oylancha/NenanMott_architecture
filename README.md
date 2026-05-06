NenanMott: NLP-Driven Educational Platform for the Chechen language
1. Project Overview & Motivation
NenanMott is an independent capstone project engineered to address the systematic lack of digital educational infrastructure for the Chechen language.
The primary objective was to design an offline-first, highly responsive mobile architecture capable of handling complex spaced-repetition algorithms (SRS), dynamic multimedia generation (Text-to-Speech), and cross-orthography mappings (Cyrillic to Latin), all while maintaining a seamless user experience.
2. System Architecture
The platform utilizes a robust, decoupled architecture separating the local data processing and state management from external cloud and AI microservices.
Tech Stack
- Frontend Client: Dart / Flutter (Optimized for iOS/Android deployment)
- State Management: Provider (Multi-provider architecture for decoupled state handling)
- Local Database: sqflite (Complex relational mapping for vocabulary, user progress, and SRS states)
- Cloud & Auth: Firebase Auth & Firebase Cloud Storage (For secure user authentication and JSON-based database backups)
- External APIs: * Custom Hugging Face Microservice (Python) for Chechen TTS generation.
    * Google Cloud Translation API for dynamic multi-language translations. (Disabled in the final version, although the code is written)
    * Pixabay API for automated visual context retrieval.
Data Flow
1. Local Processing: The Flutter client heavily relies on a local SQLite database for instantaneous data retrieval and offline capability. State changes (like answering a flashcard) immediately update local SRS metrics via the SpacedRepetitionService.
2. Microservice Integration: When a user requests audio for a custom Chechen word, the app asynchronously pings a custom Hugging Face endpoint (mms-tts-che model), retrieves the MP3 byte stream, and caches it locally using path_provider to prevent redundant network calls.
3. Cloud Synchronization: To prevent data loss without relying on a constant internet connection, the BackupServiceserializes the local SQLite database and pushes an encrypted backup to Firebase Storage, linked directly to the user's Google Auth UID.
3. Data Engineering and Algorithmic Challenges
Implementing a comprehensive language-learning system for Chechen required engineering custom solutions to bypass the limitations of standard language frameworks:
* Spaced Repetition System (SRS): Built a custom interval-based algorithm from scratch. It mathematically calculates the optimal time for a user to review a word based on historical correct/incorrect counts, graduating words through complex state layers (newWord -> learning -> reviewing -> learned).
* Orthographic Mapping: Chechen utilizes multiple alphabets. The application implements an AlphabetProvider that dynamically parses and maps dictionary entries between Cyrillic (Нохчийн) and Latin (Noxçiyn) representations across the entire UI in real-time.
* Acoustic Model Integration: Standard TTS APIs (like Apple or Google TTS) do not support Chechen. I engineered a bridge to a Massively Multilingual Speech (MMS) model hosted on Hugging Face, handling raw byte-stream conversions, asynchronous file I/O, and concurrent audio playback management within the Dart isolate.
4. Current State & Deployment
The application is in the late deployment phase and is fully operational. It successfully features a pre-loaded local dictionary, external dictionary parsing, dynamic user-generated content creation (with auto-fetched translations and images), localized UI (English/Russian), and a complete, analytics-driven learning loop.
5. Future Research Focus
The engineering challenges faced during the development of NenanMott have directly informed my future research and development goals. The next evolution of this project involves:
* Migrating the external Hugging Face TTS microservice to an on-device, lightweight local inference model to achieve 100% offline capability.
* Developing a custom NLP lemmatizer to automatically detect and group Chechen word roots and grammatical cases within the app.
* Expanding the data pipelines to support localized neural network training for other morphologically complex Caucasian languages.

Developed by Islam Elmurzaev - B.Sc. Computer Engineering
