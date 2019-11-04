//
//  TranslatorView.swift
//  MLTranslator
//
//  Created by Alfian Losari on 02/11/19.
//  Copyright © 2019 Alfian Losari. All rights reserved.
//

import SwiftUI
import Combine
import Firebase

struct TranslationView: View {
    
    @ObservedObject var translator = TranslatorViewModel()
    @ObservedObject var modelListViewModel = ModelListViewModel.shared
    
    var body: some View {
        
        NavigationView {
            Form {
                if self.modelListViewModel.downloadedModelsArray.count < 2 {
                    Text("Please download at least 2 different models to begin identification and translation")
                } else {
                    Section() {
                        HStack {
                            Text("Detected")
                            Spacer()
                            Text(self.translator.detectedLanguage?.description ?? "No detected language")
                                .font(.headline)
                        }
                        
                        if self.translator.error != nil {
                            Text(self.translator.error!)
                                .foregroundColor(.red)
                        }
                        
                        TextView(text: $translator.text)
                            .frame(height: 200)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 1))
                            .padding(.top, 8)
                            .padding(.bottom, 8)
                    }
                    
                    Section() {
                        Picker(selection: $translator.destinationLanguage, label: Text("Translate to")) {
                            ForEach(self.modelListViewModel.downloadedModelsArray) { (language) in
                                Text(language.description)
                                    .tag(language)
                            }
                        }
                        
                        TextView(text: $translator.result, isEditable: false)
                            .frame(height: 200)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 1))
                            .padding(.top, 8)
                            .padding(.bottom, 8)
                        
                        if translator.isTextToSpeechAvailable {
                            
                            Button(action: {
                                self.translator.performTextToSpeechForResult()
                            }) {
                                HStack {
                                    Text("Speak")
                                    Spacer()
                                    Image(systemName: "waveform.path")
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("SwiftUI MLKit Language")
        }
    }
}
