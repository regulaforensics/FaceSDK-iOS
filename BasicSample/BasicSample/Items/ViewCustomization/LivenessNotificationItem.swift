//
//  LivenessNotificationItem.swift
//  BasicSample
//
//  Created by Serge Rylko on 4.07.24.
//  Copyright © 2024 Regula. All rights reserved.
//

import Foundation
import FaceSDK

final class LivenessNotificationItem: CatalogItem {
    override init() {
        super.init()

        title = "Liveness Notification"
        itemDescription = "Get liveness processing status"
        category = .viewCustomization
    }

    override func onItemSelected(from viewController: UIViewController) {
        FaceSDK.service.livenessDelegate = self
        FaceSDK.service.startLiveness(
            from: viewController,
            animated: true,
            onLiveness: { [weak self, weak viewController] response in
                guard let self = self, let viewController = viewController else { return }
                self.showLivenessResult(response, from: viewController)
                FaceSDK.service.livenessDelegate = nil
            },
            completion: nil
        )
    }

    private func notification() -> [String: Any]? {
        guard
            let jsonURL = Bundle.main.url(forResource: "notification.json", withExtension: nil),
            let data = try? Data(contentsOf: jsonURL),
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        return json
    }

    private func updateStatus(name: String) {
        guard let notificationJSON = notification() else { return }
        let updatedJSON = JSONHelper.updateJSON(json: notificationJSON, targetKey: "text", newValue: name)
        FaceSDK.service.customization.customUILayerJSON = updatedJSON
    }

    deinit {
        FaceSDK.service.customization.customUILayerJSON = nil
    }
}

extension LivenessNotificationItem: LivenessDelegate {
    func processStatusChanged(_ status: LivenessProcessStatus, result: LivenessResponse?) {
        updateStatus(name: status.name)
    }
}

extension LivenessProcessStatus {
    fileprivate var name: String {
        switch self {
        case .start: return "START"
        case .preparing: return "PREPARING"
        case .newSession: return "START"
        case .progress: return "PROGRESS"
        case .nextStage: return "NEXT_STAGE"
        case .sectorChanged: return "SECTOR_CHANGED"
        case .processing: return "PROCESSING"
        case .lowBrightness: return "LOW_BRIGHTNESS"
        case .fitFace: return "FIT_FACE"
        case .moveAway: return "MOVE_AWAY"
        case .moveCloser: return "MOVE_CLOSER"
        case .turnHead: return "TURN_HEAD"
        case .failed: return "FAILED"
        case .retry: return "RETRY"
        case .success: return "SUCCESS"
        @unknown default: return "UNKNOWN"
        }
    }
}

final class JSONHelper {
    static func updateJSON(json: [String: Any], targetKey: String, newValue: Any) -> [String: Any] {
        var jsonResult = [String: Any]()
        json.forEach { (key, value) in
            if key == targetKey {
                jsonResult[key] = newValue
            } else {
                if let value = value as? [String: Any] {
                    jsonResult[key] = updateJSON(json: value, targetKey: targetKey, newValue: newValue)
                } else if let value = value as? [Any] {
                    jsonResult[key] = updateJSONArray(array: value, targetKey: targetKey, newValue: newValue)
                } else {
                    jsonResult[key] = value
                }
            }
        }
        return jsonResult
    }

    static func updateJSONArray(array: [Any], targetKey: String, newValue: Any) -> [Any] {
        var resultArray = [Any]()

        array.forEach { value in
            if let value = value as? [String: Any] {
                let newValue = updateJSON(json: value, targetKey: targetKey, newValue: newValue)
                resultArray.append(newValue)
            }
        }
        return resultArray
    }
    static func updateJSON(json: [String: Any],
                           objectKey: String,
                           newField: String,
                           newFieldValue: Any) -> [String: Any] {
        var jsonResult = [String: Any]()
        json.forEach { (key, value) in
            if key == objectKey {
                if var value = value as? [String: Any] {
                    value[newField] = newFieldValue
                    jsonResult[key] = value
                }
            } else {
                if let value = value as? [String: Any] {
                    jsonResult[key] = updateJSON(json: value, 
                                                 objectKey: objectKey,
                                                 newField: newField,
                                                 newFieldValue: newFieldValue)
                } else if let value = value as? [Any] {
                    jsonResult[key] = updateJSONArray(array: value, 
                                                      objectKey: objectKey,
                                                      newField: newField,
                                                      newFieldValue: newFieldValue)
                } else {
                    jsonResult[key] = value
                }
            }
        }
        return jsonResult
    }

    static func updateJSONArray(array: [Any], objectKey: String, newField: String, newFieldValue: Any) -> [Any] {
        var resultArray = [Any]()

        array.forEach { value in
            if let value = value as? [String: Any] {
                let newValue = updateJSON(json: value,
                                          objectKey: objectKey,
                                          newField: newField,
                                          newFieldValue: newFieldValue)
                resultArray.append(newValue)
            }
        }
        return resultArray
    }
}
