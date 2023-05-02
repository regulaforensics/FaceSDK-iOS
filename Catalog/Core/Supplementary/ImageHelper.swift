//
//  ImageHelper.swift
//  Catalog
//
//  Created by Serge Rylko on 30.08.22.
//  Copyright © 2022 Regula. All rights reserved.
//

import Foundation
import UIKit
import FaceSDK

class ImageHelper {
    
    static func drawFaceDetection(onImage image: UIImage,
                                  detection: DetectFaceResult,
                                  color: UIColor,
                                  lineWidth: CGFloat = 9,
                                  pointSize: CGFloat = 14) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(image.size, false, 0)
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }
        ctx.saveGState()
        ctx.setLineWidth(lineWidth)
        image.draw(at: .zero)

        ctx.setStrokeColor(color.cgColor)
        ctx.setFillColor(color.cgColor)
        ctx.stroke(detection.faceRect)
        
        detection.landmarks?.forEach({ landmark in
            let landmarkPointSize: CGFloat = pointSize
            let size = CGSize(width: landmarkPointSize, height: landmarkPointSize)
            ctx.fillEllipse(in: CGRect(origin: landmark.cgPoint, size: size))
        })
        
        ctx.restoreGState()
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
}
