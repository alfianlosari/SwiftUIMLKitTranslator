//
//  TranslatorViewModel.swift
//  MLTranslator
//
//  Created by Alfian Losari on 02/11/19.
//  Copyright © 2019 Alfian Losari. All rights reserved.
//

import SwiftUI
import Combine
import Firebase
import AVFoundation

class TranslatorViewModel: ObservableObject {
    
    @Published var detectedLanguage: ISOLanguage?
    @Published var destinationLanguage: ISOLanguage = ModelManager.modelManager().downloadedTranslateModels.first?.language.isoLanguage
    @Published var text = ""
    @Published var result = ""
    @Published var error: String?
    @Published var isTextToSpeechAvailable = false
    
    private let synthesizer = AVSpeechSynthesizer()
    private var translator: Translator?
    private var publisher: AnyCancellable?
    
    private let languageId = NaturalLanguage.naturalLanguage().languageIdentification()

    init() {
        observeProperties()
    }
    
    private func observeProperties() {
        publisher = Publishers.CombineLatest( $destinationLanguage, $text)
            .debounce(for: 0.15, scheduler: RunLoop.main)
            .sink { [weak self] (combinedResults) in
                guard let self = self else { return }
                self.error = nil
                
                let (_destination, text) = combinedResults
                guard let destination = _destination, !text.isEmpty else {
                    self.reset()
                    return
                }
                
                self.languageId.identifyLanguage(for: text) { [weak self] (languageCode, error) in
                    guard let self = self else { return }
                    if let error = error {
                        self.error = error.localizedDescription
                        return
                    }
                    
                    guard let languageCode = languageCode, languageCode != "und" else {
                        self.reset()
                        return
                    }
                    
                    guard ModelListViewModel.shared.downloadedModels.contains(TranslateLanguage.fromLanguageCode(languageCode)) else {
                        self.error = "Please download \(TranslateLanguage.fromLanguageCode(languageCode).isoLanguage?.description ?? "") language models to continue translation"
                        return
                    }
                    
                    let source = TranslateLanguage.fromLanguageCode(languageCode)
                    self.detectedLanguage = source.isoLanguage
                    self.performLanguageTranslation(source: source, destination: destination.translateLanguage, text: text)
                }
        }
    }
    
    private func performLanguageTranslation(source: TranslateLanguage, destination: TranslateLanguage, text: String) {
        let options = TranslatorOptions(sourceLanguage: source, targetLanguage: destination)
        translator = NaturalLanguage.naturalLanguage().translator(options: options)
        let conditions = ModelDownloadConditions(allowsCellularAccess: true, allowsBackgroundDownloading: true)
        
        translator?.downloadModelIfNeeded(with: conditions) { [weak self] (error) in
            guard let self = self else { return }
            if let error = error {
                self.error = error.localizedDescription
                return
            }
            
            self.translator?.translate(text, completion: { [weak self] (result, error) in
                guard let self = self else { return }
                if let error = error {
                    self.error = error.localizedDescription
                } else {
                    self.result = result ?? ""
                    self.isTextToSpeechAvailable = self.detectedLanguage != nil && self.destinationLanguage != nil && !self.result.isEmpty
                }
            })
        }
    }
    
    func performTextToSpeechForResult() {
        guard let destination = destinationLanguage, !result.isEmpty else {
            return
        }
        
        synthesizer.pauseSpeaking(at: .immediate)
        
        let utterance = AVSpeechUtterance(string: result)
        utterance.voice = AVSpeechSynthesisVoice(language: destination.languageCode)
        utterance.rate = 0.5
        synthesizer.speak(utterance)
    }
    
    private func reset() {
        self.result = ""
        self.detectedLanguage = nil
        self.isTextToSpeechAvailable = false
    }
}
