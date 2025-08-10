import Foundation
import AVFoundation

struct ModelInfo: Identifiable, Codable {
    var id: String { name }
    let name: String
    let downloaded: Bool
}

class TranscriberViewModel: ObservableObject {
    @Published var engines = ["whisper", "whisperx"]
    @Published var selectedEngine = "whisper"
    @Published var models: [ModelInfo] = []
    @Published var selectedModel = "base"
    @Published var isRecording = false
    @Published var transcript = ""

    private var recorder: AVAudioRecorder?
    private var audioURL: URL {
        FileManager.default.temporaryDirectory.appendingPathComponent("recording.wav")
    }

    init() {
        loadModels()
    }

    func loadModels() {
        DispatchQueue.global().async {
            let output = self.runPython(["list-models", self.selectedEngine])
            if let data = output.data(using: .utf8),
               let decoded = try? JSONDecoder().decode([ModelInfo].self, from: data) {
                DispatchQueue.main.async {
                    self.models = decoded
                    if !decoded.map({ $0.name }).contains(self.selectedModel) {
                        self.selectedModel = decoded.first?.name ?? "base"
                    }
                }
            }
        }
    }

    func toggleRecording() {
        isRecording ? stopRecording() : startRecording()
    }

    private func startRecording() {
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do {
            recorder = try AVAudioRecorder(url: audioURL, settings: settings)
            recorder?.record()
            DispatchQueue.main.async { self.isRecording = true }
        } catch {
            print("Recording failed: \(error)")
        }
    }

    private func stopRecording() {
        recorder?.stop()
        DispatchQueue.main.async { self.isRecording = false }
        transcribe()
    }

    private func transcribe() {
        DispatchQueue.global().async {
            let output = self.runPython(["transcribe", self.selectedEngine, self.selectedModel, self.audioURL.path])
            DispatchQueue.main.async {
                self.transcript = output
            }
        }
    }

    private func runPython(_ arguments: [String]) -> String {
        let process = Process()
        let scriptPath = Bundle.main.path(forResource: "transcribe", ofType: "py") ?? "../scripts/transcribe.py"
        process.executableURL = URL(fileURLWithPath: "/usr/bin/python3")
        process.arguments = [scriptPath] + arguments
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        do {
            try process.run()
        } catch {
            return "Error running python: \(error)"
        }
        process.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
    }
}
