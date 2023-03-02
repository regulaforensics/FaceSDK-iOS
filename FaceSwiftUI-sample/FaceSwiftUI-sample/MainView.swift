//
//  ContentView.swift
//  FaceSwiftUI-sample
//
//  Created by Dmitry Evglevsky on 24.01.23.
//

import SwiftUI
import FaceSDK

struct MainView: View {
    @ObservedObject
    var face: FaceFacade
    
    var body: some View {
        NavigationStack {
            if face.isInitialized {
                VStack(spacing: 60) {
                    Button("Face Capture") {
                        face.showFaceCapture()
                    }
                    .frame(width: 120)
                    .padding(10)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    Button("Liveness") {
                        face.showLiveness()
                    }
                    .frame(width: 120)
                    .padding(10)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }.navigationDestination(isPresented: $face.faceCaptureResultsReady) {
                    FaceCaptureResultsView(face: face)
                }.navigationDestination(isPresented: $face.livenessResultsReady) {
                    LivenessResultsView(face: face)
                }
            } else {
                Text("Initializing...")
            }
        }

    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(face: FaceFacade())
    }
}
