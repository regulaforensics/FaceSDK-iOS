//
//  ViewController.swift
//  FaceCertificatePinning
//
//  Created by Serge Rylko on 13.10.23.
//

import UIKit
import FaceSDK


class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    prepareFaceSDK()
  }

  private func prepareFaceSDK() {
    FaceSDK.service.initialize { success, error in
      if success {
        print("FaceSDK initialized")
      } else if let error = error {
        print(error.localizedDescription)
      }
    }
  }

  @IBAction private func didPressStartButton(_ sender: Any) {
    FaceSDK.service.startLiveness(from: self, animated: true) { [weak self] response in
      if response.liveness == .passed {
        print("LivenessPassed")
      } else if let error = response.error {
        self?.handle(error: error)
      }
    }
  }

  private func handle(error: Error) {
    if case LivenessError.cancelled = error {
      return
    }
    let title = "Liveness Error"
    let message = error.localizedDescription


    let controller = UIAlertController(title: title,
                                       message: message,
                                       preferredStyle: .alert)
    controller.addAction(.init(title: "OK", style: .cancel))
    present(controller, animated: true)
  }
}
