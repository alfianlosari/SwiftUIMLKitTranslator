//
//  ContentView.swift
//  MLTranslator
//
//  Created by Alfian Losari on 30/10/19.
//  Copyright © 2019 Alfian Losari. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TranslationView()
                .tabItem {
                    Image(systemName: "bubble.left.and.bubble.right")
                    Text("Translation")
            }.tag(0)
            
            ModelListView()
                .tabItem {
                    Image(systemName: "tray.fill")
                    Text("Model")
            }.tag(1)
        }
        .edgesIgnoringSafeArea(.top)
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
