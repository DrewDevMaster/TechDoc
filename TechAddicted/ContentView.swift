//
//  ContentView.swift
//  TechAddicted
//
//  Created by Drew on 28.05.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .onAppear() {
            //
        }
        .task {
            //_ = try? await fetchProfile()
        }
    }
}

#Preview {
    ContentView()
}
