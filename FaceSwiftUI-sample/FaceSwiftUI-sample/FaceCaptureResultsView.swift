//
//  FaceCaptureResultsView.swift
//  FaceSwiftUI-sample
//
//  Created by Dmitry Evglevsky on 28.02.23.
//

import SwiftUI
import FaceSDK

struct FaceCaptureResultsView: View {
    let face: FaceFacade
    
    var body: some View {
        if let image = face.faceCaptureResponse?.image?.image {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(32)
        } else {
            Text("No Image")
        }
    }
}
