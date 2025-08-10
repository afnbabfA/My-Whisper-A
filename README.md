# SpeechTranscriber

SwiftUI macOS app that records microphone audio and transcribes it to text using OpenAI Whisper or WhisperX models.

## Features
- Toggle recording from the microphone.
- Choose transcription engine: Whisper or WhisperX.
- Select model size (tiny, base, small, medium, large).
- Models already downloaded to `~/.cache/whisper` are shown with a checkmark.

## Requirements
- macOS with Swift 6.1 and SwiftUI.
- Python 3 with the following packages installed:
  - `openai-whisper`
  - `whisperx` (`pip install git+https://github.com/m-bain/whisperX.git`)

## Usage
1. Install the Python dependencies:
   ```bash
   pip install openai-whisper
   pip install git+https://github.com/m-bain/whisperX.git
   ```
2. Build and run the app (on macOS):
   ```bash
   swift run
   ```
3. Pick the engine and model, press the microphone button to start/stop recording. The transcript will appear after recording stops.

The Swift code calls `scripts/transcribe.py` to perform model management and transcription.
