//
//  ModelListView.swift
//  MLTranslator
//
//  Created by Alfian Losari on 02/11/19.
//  Copyright © 2019 Alfian Losari. All rights reserved.
//

import SwiftUI

struct ModelListView: View {
    
    @ObservedObject var modelListViewModel = ModelListViewModel.shared
    
    var body: some View {
     
        NavigationView {
            List {
                ForEach(self.modelListViewModel.allLanguages) { (lang) in
                    HStack {
                        Text(lang.isoLanguage.description)
                        Spacer()
                        if (lang.isDownloading) {
                            LoadingView()
                        } else if !lang.isDownloaded {
                            Image(systemName: "icloud.and.arrow.down")
                                .foregroundColor(.blue)
                        }
                    }
                    .onTapGesture {
                        self.modelListViewModel.download(lang.translateLanguage)
                    }
                }
                .onDelete { (indexSet) in
                    
                }
            }
            .navigationBarTitle("SwiftUI MLKit Language")
        }
    }
}
