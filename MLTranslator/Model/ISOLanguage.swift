//
//  ISOLanguage.swift
//  MLTranslator
//
//  Created by Alfian Losari on 30/10/19.
//  Copyright © 2019 Alfian Losari. All rights reserved.
//

import Foundation
import Firebase

struct ISOLanguageContainer {
   
    private(set) var languagesDict: [String: ISOLanguage] = [:]
    
    static let shared = ISOLanguageContainer()
    private init() {
        let url = Bundle.main.url(forResource: "bcp47", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        
        json.forEach { (element) in
            if let dict = element.value as? [String: Any]  {
                languagesDict[element.key] = ISOLanguage(code: element.key, dict: dict)
            }
        }
    }
}

struct LanguageDownload: Identifiable, Hashable {
    
    var id: String {
        languageCode
    }
    
    let languageCode: String
    let isoLanguage: ISOLanguage
    let translateLanguage: TranslateLanguage
    
    var isDownloaded = false
    var isDownloading = false
    
}

struct ISOLanguage: Identifiable, Hashable {
    
    var id: String {
        languageCode
    }
    
    let languageCode: String
    let name: String
    let nativeName: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    
    init(code: String, dict: [String:Any]) {
        self.languageCode = code
        self.name = dict["name"] as? String ?? ""
        self.nativeName = dict["nativeName"] as? String ?? ""
    }
    
    var description: String {
         "\(languageCodeName)\n\(nativeName)"
    }
    
    var languageCodeName: String {
        "\(languageCode)-\(name)"
    }
    
    var translateLanguage: TranslateLanguage {
        TranslateLanguage.fromLanguageCode(languageCode)
    }
    
}

extension TranslateLanguage {
    
    var isoLanguage: ISOLanguage? {
        ISOLanguageContainer.shared.languagesDict[self.toLanguageCode()]
    }
}
