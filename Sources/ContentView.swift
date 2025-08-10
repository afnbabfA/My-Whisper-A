import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TranscriberViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Picker("Engine", selection: $viewModel.selectedEngine) {
                ForEach(viewModel.engines, id: \.self) { engine in
                    Text(engine.capitalized).tag(engine)
                }
            }
            .onChange(of: viewModel.selectedEngine) { _ in
                viewModel.loadModels()
            }

            Picker("Model", selection: $viewModel.selectedModel) {
                ForEach(viewModel.models) { model in
                    HStack {
                        Text(model.name)
                        if model.downloaded {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .tag(model.name)
                }
            }

            Button(action: viewModel.toggleRecording) {
                Image(systemName: viewModel.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(viewModel.isRecording ? .red : .blue)
            }

            Text("Transcription:")
                .font(.headline)
            ScrollView {
                Text(viewModel.transcript)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Spacer()
        }
        .padding()
        .frame(minWidth: 400, minHeight: 400)
    }
}

#Preview {
    ContentView()
}
