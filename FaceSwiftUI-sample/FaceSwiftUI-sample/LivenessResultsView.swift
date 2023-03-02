//
//  LivenessResults.swift
//  FaceSwiftUI-sample
//
//  Created by Dmitry Evglevsky on 28.02.23.
//

import SwiftUI
import FaceSDK

struct LivenessResultsView: View {
    let face: FaceFacade
    
    var body: some View {
        if let image = face.livenessResponse?.image {
            VStack {
                if face.livenessResponse!.liveness == .passed {
                    Text("Liveness status: PASSED")
                } else {
                    Text("Liveness status: FAILED")
                }
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(32)
            }
        } else {
            Text("No Image")
        }
    }
}
