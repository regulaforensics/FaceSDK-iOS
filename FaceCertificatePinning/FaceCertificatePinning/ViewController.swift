//
//  ViewController.swift
//  FaceCertificatePinning
//
//  Created by Serge Rylko on 13.10.23.
//

import UIKit
import FaceSDK

enum Section {
  case main
}

typealias ResultsDataSource = UICollectionViewDiffableDataSource<Section, DetectFaceResult>

class ViewController: UIViewController {

  @IBOutlet private weak var imageView: UIImageView!
  @IBOutlet private weak var detectButton: UIButton!
  @IBOutlet private weak var collectionView: UICollectionView!
  @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
  private let image = UIImage(named: "sample1.jpg")
  private lazy var dataSource = makeDataSource()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    imageView.image = image
    prepareFaceSDK()
  }
  
  private func prepareFaceSDK() {
    showLoading(loading: true)
    FaceSDK.service.initialize { success, error in
      self.showLoading(loading: false)
      if success {
        print("FaceSDK initialized")
      } else if let error = error {
        print(error.localizedDescription)
      }
    }
  }
  
  @IBAction func didPressDetectFacesButton(_ sender: Any) {
    guard let image = image else { return }
    let config = DetectFacesConfiguration()
    let outpupImageParams = OutputImageParams()
    outpupImageParams.crop = OutputImageCrop(type: .ratio4x5)
    config.outputImageParams = outpupImageParams
    config.onlyCentralFace = false
    let request = DetectFacesRequest(image: image, configuration: config)
    
    showLoading(loading: true)
    
    FaceSDK.service.detectFaces(by: request) { [weak self] response in
      guard let self = self else { return }
      self.showLoading(loading: false)
      if let detections = response.allDetections {
        var snapshot = NSDiffableDataSourceSnapshot<Section, DetectFaceResult>()
        snapshot.appendSections([.main])
        snapshot.appendItems(detections)
        self.dataSource.apply(snapshot)
      } else if let error = response.error {
        print(error.localizedDescription)
      }
    }
  }
  
  private func makeDataSource() -> ResultsDataSource {
    let dataSource = ResultsDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, result in
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetectionCollectionViewCell", for: indexPath) as? DetectionCollectionViewCell else { fatalError() }
      cell.imageView.image = result.crop
      return cell
    })
    
    return dataSource
  }
  
  private func showLoading(loading: Bool) {
    if loading {
      activityIndicator.startAnimating()
    } else {
      activityIndicator.stopAnimating()
    }
    detectButton.isEnabled = !loading
  }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let width = collectionView.bounds.width / 3
    let height = width * 5 / 4
    return .init(width: width, height: height)
  }
}
