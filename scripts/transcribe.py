import argparse
import json
from pathlib import Path

WHISPER_MODELS = ["tiny", "base", "small", "medium", "large"]


def list_models(engine: str):
    cache_dir = Path.home() / ".cache" / "whisper"
    models = []
    for name in WHISPER_MODELS:
        model_path = cache_dir / f"{name}.pt"
        models.append({"name": name, "downloaded": model_path.exists()})
    print(json.dumps(models))


def transcribe(engine: str, model_size: str, audio_path: str):
    if engine == "whisperx":
        import torch  # noqa: F401
        import whisperx

        device = "cuda" if torch.cuda.is_available() else "cpu"
        model = whisperx.load_model(model_size, device)
        audio = whisperx.load_audio(audio_path)
        result = model.transcribe(audio)
        text = result.get("text")
        if not text and "segments" in result:
            text = " ".join(seg["text"] for seg in result["segments"])
        print(text or "")
    else:
        import whisper

        model = whisper.load_model(model_size)
        result = model.transcribe(audio_path)
        print(result.get("text", ""))


def main():
    parser = argparse.ArgumentParser(description="Transcribe audio using Whisper or WhisperX")
    sub = parser.add_subparsers(dest="cmd", required=True)

    list_parser = sub.add_parser("list-models")
    list_parser.add_argument("engine", choices=["whisper", "whisperx"])

    trans_parser = sub.add_parser("transcribe")
    trans_parser.add_argument("engine", choices=["whisper", "whisperx"])
    trans_parser.add_argument("model")
    trans_parser.add_argument("audio")

    args = parser.parse_args()

    if args.cmd == "list-models":
        list_models(args.engine)
    elif args.cmd == "transcribe":
        transcribe(args.engine, args.model, args.audio)


if __name__ == "__main__":
    main()
