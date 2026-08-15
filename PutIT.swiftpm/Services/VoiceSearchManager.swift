import SwiftUI
import Speech
import AVFoundation

@MainActor
class VoiceSearchManager: ObservableObject {
    @Published var isRecording: Bool = false
    @Published var recognizedText: String = ""
    @Published var errorMessage: String? = nil
    
    private var audioEngine = AVAudioEngine()
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "th-TH"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    init() {
        if speechRecognizer == nil || speechRecognizer?.isAvailable == false {
            speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        }
    }
    
    func toggleListening(onTranscript: @escaping (String) -> Void) {
        if isRecording {
            stopListening()
        } else {
            startListening(onTranscript: onTranscript)
        }
    }
    
    func startListening(onTranscript: @escaping (String) -> Void) {
        stopListening()
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            Task { @MainActor in
                guard authStatus == .authorized else {
                    self.errorMessage = "Speech recognition permission denied"
                    return
                }
                
                if #available(iOS 17.0, *) {
                    AVAudioApplication.requestRecordPermission { granted in
                        Task { @MainActor in
                            guard granted else {
                                self.errorMessage = "Microphone permission denied"
                                return
                            }
                            self.beginAudioEngine(onTranscript: onTranscript)
                        }
                    }
                } else {
                    AVAudioSession.sharedInstance().requestRecordPermission { granted in
                        Task { @MainActor in
                            guard granted else {
                                self.errorMessage = "Microphone permission denied"
                                return
                            }
                            self.beginAudioEngine(onTranscript: onTranscript)
                        }
                    }
                }
            }
        }
    }
    
    private func beginAudioEngine(onTranscript: @escaping (String) -> Void) {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else { return }
            recognitionRequest.shouldReportPartialResults = true
            
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.removeTap(onBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                recognitionRequest.append(buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            
            isRecording = true
            errorMessage = nil
            
            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
                if let result = result {
                    let transcript = result.bestTranscription.formattedString
                    self.recognizedText = transcript
                    onTranscript(transcript)
                }
                
                if error != nil || result?.isFinal == true {
                    self.stopListening()
                }
            }
        } catch {
            self.errorMessage = "Failed to start audio engine: \(error.localizedDescription)"
            self.stopListening()
        }
    }
    
    func stopListening() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        recognitionRequest = nil
        recognitionTask = nil
        isRecording = false
    }
}
