//
//  FaceSwiftUI_sampleApp.swift
//  FaceSwiftUI-sample
//
//  Created by Dmitry Evglevsky on 24.01.23.
//

import SwiftUI

@main
struct FaceSwiftUI_sampleApp: App {
    var body: some Scene {
        WindowGroup {
            MainView(face: FaceFacade())
        }
    }
}
