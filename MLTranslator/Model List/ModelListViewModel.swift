//
//  ModelListViewModel.swift
//  MLTranslator
//
//  Created by Alfian Losari on 02/11/19.
//  Copyright © 2019 Alfian Losari. All rights reserved.
//

import SwiftUI
import Firebase

class ModelListViewModel: NSObject, ObservableObject {
    
    static let shared = ModelListViewModel()
    @Published var allLanguages: [LanguageDownload] = []
 
    @Published var downloadingModels: Set<TranslateLanguage> = []
    @Published var downloadedModelsArray = [ISOLanguage]()
    @Published var downloadedModels: Set<TranslateLanguage> = [] {
        didSet {
            self.downloadedModelsArray = Array(self.downloadedModels.compactMap { $0.isoLanguage} )
        }
    }
    
    override private init() {
        super.init()
        
        let localModels = ModelManager.modelManager().downloadedTranslateModels
        downloadedModels = Set(localModels.map { $0.language })
        
        allLanguages = TranslateLanguage.allLanguages().compactMap { TranslateLanguage(rawValue: $0.uintValue) }.compactMap({ $0.isoLanguage }).map { LanguageDownload(languageCode: $0.languageCode, isoLanguage: $0, translateLanguage: $0.translateLanguage, isDownloaded: downloadedModels.contains($0.translateLanguage), isDownloading: downloadingModels.contains($0.translateLanguage)) }
        
        registerForModelDownloadDidSuccessNotification()
        registerForModelDownloadDidFailureNotification()
    }
    
    func registerForModelDownloadDidSuccessNotification() {
        NotificationCenter.default.addObserver(
            forName: .firebaseMLModelDownloadDidSucceed,
            object: nil,
            queue: nil
        ) { [weak self] notification in
            guard let self = self,
                let userInfo = notification.userInfo,
                let model = userInfo[ModelDownloadUserInfoKey.remoteModel.rawValue]
                    as? TranslateRemoteModel,
                let tuple = self.downloadModelTuple(with: model.language)
                else { return }
            
            self.downloadingModels.remove(model.language)
            self.downloadedModels.insert(model.language)
            
            var (index, current) = tuple
            current.isDownloading = false
            current.isDownloaded = true
            self.allLanguages[index] = current
        }
    }
    
    func registerForModelDownloadDidFailureNotification() {
        NotificationCenter.default.addObserver(
            forName: .firebaseMLModelDownloadDidFail,
            object: nil,
            queue: nil
        ) { [weak self] notification in
            guard let self = self,
                let userInfo = notification.userInfo,
                let model = userInfo[ModelDownloadUserInfoKey.remoteModel.rawValue]
                    as? TranslateRemoteModel,
                let tuple = self.downloadModelTuple(with: model.language)
                else { return }
            
            var (index, current) = tuple
            current.isDownloading = false
            current.isDownloaded = false
            self.allLanguages[index] = current
            
            self.downloadingModels.remove(model.language)
        }
    }
    
    func downloadModelTuple(with language: TranslateLanguage) -> (Int, LanguageDownload)? {
        guard let index = self.allLanguages.firstIndex(where: { $0.translateLanguage == language }) else {
            return nil
        }
        return (index, self.allLanguages[index])
    }
    
    
    func download(_ language: TranslateLanguage) {
        guard
            let tuple = self.downloadModelTuple(with: language),
            !downloadedModels.contains(language) else {
            return
        }
        
        var (index, model) = tuple
        model.isDownloading = true
        self.allLanguages[index] = model
        
        self.downloadingModels.insert(language)
        let modelToDownload = TranslateRemoteModel.translateRemoteModel(language: language)
        ModelManager.modelManager().download(
            modelToDownload,
            conditions: ModelDownloadConditions(
                allowsCellularAccess: true,
                allowsBackgroundDownloading: true
            )
        )
    }
}
