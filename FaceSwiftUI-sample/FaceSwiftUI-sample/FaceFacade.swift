//
//  FaceFacade.swift
//  FaceSwiftUI-sample
//
//  Created by Dmitry Evglevsky on 28.02.23.
//

import Foundation
import Combine
import FaceSDK

class FaceFacade: ObservableObject {
    @Published
    var isInitialized: Bool = false
    
    @Published
    var livenessResponse: LivenessResponse?
    @Published
    var livenessResultsReady: Bool = false
    
    @Published
    var faceCaptureResponse: FaceCaptureResponse?
    @Published
    var faceCaptureResultsReady: Bool = false
    
    private var cancellables: Set<AnyCancellable> = .init()
    
    init() {
        setup()
    }
    
    func setup() {
        FaceSDK.service.initializeFace().sink { [unowned self] completion in
            switch completion {
            case .finished:
                self.isInitialized = true
            case .failure(let error):
                print(error.localizedDescription)
            }
        } receiveValue: { _ in
            
        }.store(in: &cancellables)
        
        $faceCaptureResponse
            .compactMap { $0 != nil }
            .assign(to: &$faceCaptureResultsReady)
        
        $livenessResponse
            .compactMap { $0 != nil }
            .assign(to: &$livenessResultsReady)
    }
    
    func showFaceCapture() {
        guard let presenter = UIApplication.shared.rootViewController else {
            return
        }
        
        FaceSDK.service.presentFaceCaptureViewController(from: presenter, animated: true) { response in
            self.faceCaptureResponse = response
        }
    }
    
    func showLiveness() {
        guard let presenter = UIApplication.shared.rootViewController else {
            return
        }
        
        // Apply some configuration
        let configuration = LivenessConfiguration {
            $0.attemptsCount = 2
            $0.stepSkippingMask = [.onboarding, .success]
        }
        
        FaceSDK.service.startLiveness(from: presenter, animated: false, configuration: configuration) { response in
            self.livenessResponse = response
        }
    }
}

extension FaceSDK {
    
    func initializeFace() -> AnyPublisher<Bool, Error> {
        Deferred {
            Future<Bool, Error> { promise in
                FaceSDK.service.initialize() { success, error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(success))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
}

