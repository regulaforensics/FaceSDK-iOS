//
//  MatchFacesViewController.swift
//  FaceMatchOffline-sample
//
//  Created by Dmitry Evglevsky on 7.12.23.
//  Copyright © 2023 Regula. All rights reserved.
//

import FaceSDK
import UIKit
import Photos

class MatchFacesViewController: UIViewController {
    private enum Position {
        case first
        case second
    }
    
    @IBOutlet private weak var acitvityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private weak var initializationLabel: UILabel!

  private lazy var firstImageView: UIImageView = {
      let view = UIImageView()
      let tapGestureFirst = UITapGestureRecognizer(target: self, action: #selector(self.handleFirstImageTap))
      view.addGestureRecognizer(tapGestureFirst)
      view.contentMode = .scaleAspectFit
      view.isUserInteractionEnabled = true
      view.backgroundColor = .lightGray
      return view
  }()
  private lazy var firstImageDetectAllSwitch = UISwitch()
  private lazy var secondImageView: UIImageView = {
      let view = UIImageView()
      let tapGestureFirst = UITapGestureRecognizer(target: self, action: #selector(self.handleSecondImageTap))
      view.addGestureRecognizer(tapGestureFirst)
      view.contentMode = .scaleAspectFit
      view.isUserInteractionEnabled = true
      view.backgroundColor = .lightGray
      return view
  }()
  private lazy var secondImageDetectAllSwitch = UISwitch()

  private var selectedFirstImageType: ImageType? {
      didSet { updateImageTypeTitle(position: .first) }
  }
  private var selectedSecondImageType: ImageType? {
      didSet { updateImageTypeTitle(position: .second) }
  }

  private lazy var matchFacesButton: UIButton = {
      let button = UIButton(type: .system)
      button.addTarget(self, action: #selector(handleMatchButtonPress), for: .touchUpInside)
      button.setTitle("MATCH", for: .normal)
      button.setTitleColor(.white, for: .normal)
      button.titleLabel?.font = .systemFont(ofSize: 15)
      button.backgroundColor = .systemBlue
      button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
      button.layer.cornerRadius = 5
      button.clipsToBounds = false
      return button
  }()

  private lazy var clearButton: UIButton = {
      let button = UIButton(type: .system)
      button.addTarget(self, action: #selector(handleClearButtonPress), for: .touchUpInside)
      button.setTitle("CLEAR", for: .normal)
      button.setTitleColor(.white, for: .normal)
      button.titleLabel?.font = .systemFont(ofSize: 15)
      button.backgroundColor = .systemBlue
      button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
      button.layer.cornerRadius = 5
      button.layer.cornerRadius = 5
      button.clipsToBounds = false
      return button
  }()

  private lazy var firstImageTypeButton: UIButton = {
      let button = UIButton(type: .system)
      button.translatesAutoresizingMaskIntoConstraints = false
      button.addTarget(self, action: #selector(didPressImageTypeButton), for: .touchUpInside)
      button.tag = 0
      button.setTitle(imageTypeLabelDefaultText, for: .normal)
      return button
  }()

  private lazy var secondImageTypeButton: UIButton = {
      let button = UIButton(type: .system)
      button.translatesAutoresizingMaskIntoConstraints = false
      button.addTarget(self, action: #selector(didPressImageTypeButton), for: .touchUpInside)
      button.tag = 1
      button.setTitle(imageTypeLabelDefaultText, for: .normal)
      return button
  }()

  private lazy var similarityLabel: UILabel = {
      let label = UILabel()
      label.text = similarityLabelDefaultText
      label.font = .preferredFont(forTextStyle: .title3)
      label.numberOfLines = 0
      return label
  }()

  private lazy var detectionsButton: UIButton = {
      let button = UIButton(type: .system)
      button.addTarget(self, action: #selector(didPressDetectionsButton), for: .touchUpInside)
      button.isHidden = true
      button.titleLabel?.font = .systemFont(ofSize: 15)
      return button
  }()

  private var lastDetections: [MatchFacesDetection] = [] {
      didSet { updateDetectionAppearance() }
  }

  private lazy var firstImagePicker: ImagePicker = ImagePicker(presenter: self, delegate: self)
  private lazy var secondImagePicker: ImagePicker = ImagePicker(presenter: self, delegate: self)

  private let similarityLabelDefaultText = "Similarity: null."
  private let imageTypeLabelDefaultText = "ImageType"


    func setupUI() {
      view = UIView()
      if #available(iOS 13.0, *) {
          view.backgroundColor = .systemBackground
      } else {
          view.backgroundColor = .white
      }

      let root = UIStackView()
      root.spacing = 15
      root.axis = .vertical

      view.addSubview(root)
      root.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
        root.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
          root.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
          root.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
          root.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
      ])

      let imagesContainer = UIStackView()
      imagesContainer.axis = .vertical
      imagesContainer.distribution = .fillEqually
      imagesContainer.spacing = 45
      imagesContainer.addArrangedSubview(firstImageView)

      func makeOptionLabel(text: String) -> UILabel {
          let label = UILabel()
          label.text = text
          label.font = .preferredFont(forTextStyle: .body)
          return label
      }

      func makeOptionsRow(text: String, switchView: UISwitch) -> UIView {
          let row = UIStackView()
          row.spacing = 5
          row.axis = .horizontal
          row.addArrangedSubview(makeOptionLabel(text: text))
          row.addArrangedSubview(switchView)
          return row
      }

      let firstDetectAllRow = makeOptionsRow(text: "DetectAll", switchView: firstImageDetectAllSwitch)
      firstImageView.addSubview(firstDetectAllRow)
      firstDetectAllRow.translatesAutoresizingMaskIntoConstraints = false

      firstImageTypeButton.translatesAutoresizingMaskIntoConstraints = false
      firstImageView.addSubview(firstImageTypeButton)


      NSLayoutConstraint.activate([
          firstImageTypeButton.leadingAnchor.constraint(equalTo: firstImageView.leadingAnchor, constant: 5.0),
          firstImageTypeButton.bottomAnchor.constraint(equalTo: firstImageView.bottomAnchor),

          firstDetectAllRow.trailingAnchor.constraint(equalTo: firstImageView.trailingAnchor),
          firstDetectAllRow.bottomAnchor.constraint(equalTo: firstImageView.bottomAnchor)
      ])

      imagesContainer.addArrangedSubview(secondImageView)
      let secondDetectAllRow = makeOptionsRow(text: "DetectAll", switchView: secondImageDetectAllSwitch)
      secondImageView.addSubview(secondDetectAllRow)
      secondDetectAllRow.translatesAutoresizingMaskIntoConstraints = false

      secondImageTypeButton.translatesAutoresizingMaskIntoConstraints = false
      secondImageView.addSubview(secondImageTypeButton)

      NSLayoutConstraint.activate([
          secondImageTypeButton.leadingAnchor.constraint(equalTo: secondImageView.leadingAnchor, constant: 5.0),
          secondImageTypeButton.bottomAnchor.constraint(equalTo: secondImageView.bottomAnchor),

          secondDetectAllRow.trailingAnchor.constraint(equalTo: secondImageView.trailingAnchor),
          secondDetectAllRow.bottomAnchor.constraint(equalTo: secondImageView.bottomAnchor)
      ])

      let resultsStackView = UIStackView()
      resultsStackView.axis = .horizontal
      resultsStackView.spacing = 15
      resultsStackView.distribution = .fillEqually
      resultsStackView.addArrangedSubview(similarityLabel)
      resultsStackView.addArrangedSubview(detectionsButton)

      root.addArrangedSubview(imagesContainer)
      root.addArrangedSubview(matchFacesButton)
      root.addArrangedSubview(clearButton)
      root.addArrangedSubview(resultsStackView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }

        let filePath = Bundle.main.path(forResource: "regula", ofType: "license")!
        let data = NSData(contentsOfFile: filePath)! as Data
        let initConfiguration = InitializationConfiguration {
            $0.licenseData = data
        }
        
        FaceSDK.service.initialize(configuration: initConfiguration) { success, error in
            self.acitvityIndicatorView.stopAnimating()
            if error == nil {
                self.initializationLabel.isHidden = true
                self.setupUI()
            } else {
                self.initializationLabel.text = error?.localizedDescription
            }
        }
    }

  @objc private func handleFirstImageTap() {
      similarityLabel.text = similarityLabelDefaultText
      firstImagePicker.presentPickerActions(from: firstImageView)
  }

  @objc private func handleSecondImageTap() {
      similarityLabel.text = similarityLabelDefaultText
      secondImagePicker.presentPickerActions(from: secondImageView)
  }

  @objc private func didPressImageTypeButton(_ sender: UIButton) {
      let position = sender.tag == 0 ? Position.first : Position.second
      showImageTypePicker(for: position)
  }

  @objc private func didPressDetectionsButton(_ sender: Any) {
      let detections = lastDetections
          .flatMap({ $0.faces.compactMap { $0.crop } })
      if detections.count > 0 {
          let controller = ImagesPreviewViewController(images: detections)
          navigationController?.pushViewController(controller, animated: true)
      }
  }

    private func detectAllOptionValueFor(position: Position) -> Bool {
        switch position {
        case .first:
            return firstImageDetectAllSwitch.isOn
        case .second:
            return secondImageDetectAllSwitch.isOn
        }
    }

//    private func createImageForPosition(_ position: Position, completion: @escaping (UIImage?, ImageType) -> Void) {
//        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        alert.addAction(UIAlertAction(title: "Regula FaceCaptureUI", style: .default, handler: { _ in
//            FaceSDK.service.presentFaceCaptureViewController(
//                from: self,
//                animated: true,
//                onCapture: { response in
//                    let image = response.image?.image
//                    completion(image, .live)
//                },
//                completion: nil
//            )
//        }))
//        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
//            self.pickImage(sourceType: .photoLibrary) { image in
//                completion(image, .printed)
//            }
//        }))
//        alert.addAction(UIAlertAction(title: "Camera Shoot", style: .default, handler: { _ in
//            self.pickImage(sourceType: .camera) { image in
//                completion(image, .live)
//            }
//        }))
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
//            completion(nil, .external)
//        }))
//
//
//        let imageView: UIImageView
//        switch position {
//        case .first:
//            imageView = firstImageView
//        case .second:
//            imageView = secondImageView
//        }
//
//        if let popoverPresentationController = alert.popoverPresentationController {
//            popoverPresentationController.sourceView = view
//            popoverPresentationController.sourceRect = CGRect(
//                x: imageView.frame.midX,
//                y: imageView.frame.midY,
//                width: 0,
//                height: 0
//            )
//        }
//        self.present(alert, animated: true, completion: nil)
//    }

    @objc private func handleMatchButtonPress() {
      guard let firstPickedImage = firstImageView.image, let secondPickedImage = secondImageView.image else {
          let alert = UIAlertController(title: "Having both images is required", message: nil, preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
          present(alert, animated: true, completion: nil)
          return
      }

      let firstImage = MatchFacesImage(image: firstPickedImage,
                                       imageType: selectedFirstImageType ?? .printed,
                                       detectAll: detectAllOptionValueFor(position: .first))
      let secondImage = MatchFacesImage(image: secondPickedImage,
                                        imageType: selectedSecondImageType ?? .printed,
                                        detectAll: detectAllOptionValueFor(position: .second))

      let request = MatchFacesRequest(images: [firstImage, secondImage])

      let outputImageParams = OutputImageParams()
      outputImageParams.crop = .init(type: .ratio3x4)
      outputImageParams.backgroundColor = .white
      request.outputImageParams = outputImageParams

      similarityLabel.text = "Processing..."
      matchFacesButton.isEnabled = false
      clearButton.isEnabled = false

      FaceSDK.service.matchFaces(request, completion: { [weak self](response: MatchFacesResponse) in
          self?.matchFacesButton.isEnabled = true
          self?.clearButton.isEnabled = true

          self?.handleMatchFacesResponse(response: response)
      })
    }

  @objc private func handleClearButtonPress(sender: UIButton) {
      firstImageView.image = nil
      selectedFirstImageType = nil

      secondImageView.image = nil
      selectedSecondImageType = nil

      lastDetections = []
      similarityLabel.text = similarityLabelDefaultText
  }
  private func handleMatchFacesResponse(response: MatchFacesResponse) {
      if let error = response.error {
          self.similarityLabel.text = "Error: \(error.localizedDescription)"
          self.lastDetections = []
          return
      }

      if let firstPair = response.results.first {
          let similarityValue = firstPair.similarity?.doubleValue ?? 0.0
          let similarityRounded = (similarityValue * 100 * 100).rounded() / 100
          similarityLabel.text = "Similarity: \(similarityRounded)%"
      } else {
          similarityLabel.text = "Similarity: no matched pair found"
      }
      lastDetections = response.detections
  }

  private func showImageTypePicker(for position: Position) {
      func pick(type: ImageType, forPosition position: Position) {
          switch position {
          case .first: selectedFirstImageType = type
          case .second: selectedSecondImageType = type
          }
      }
      func isImageTypeSelected(type: ImageType, position: Position) -> Bool{
          switch position {
          case .first: selectedFirstImageType == type
          case .second: selectedSecondImageType == type
          }
      }

      let controller = UIAlertController(title: "Image Type", message: nil, preferredStyle: .actionSheet)
      let types: [ImageType] = [.printed, .RFID, .live, .documentWithLive, .external, .ghostPortrait, .barcode]

      for type in types {
          let actionPrinted = UIAlertAction(title: title(for: type), style: .default) { action in
              print(type.rawValue)
              pick(type: type, forPosition: position)
          }
          actionPrinted.setValue(isImageTypeSelected(type: type, position: position), forKey: "checked")
          controller.addAction(actionPrinted)
      }
      controller.addAction(.init(title: "Cancel", style: .cancel, handler: nil))

      present(controller, animated: true)
  }

  private func title(for imageType: ImageType) -> String {
      switch imageType {
      case .printed: return "PRINTED"
      case .RFID: return "RFID"
      case .live: return "LIVE"
      case .documentWithLive: return "DOCUMENT WITH LIVE"
      case .external: return "EXTERNAL"
      case .ghostPortrait: return "GHOST PORTRAIT"
      case .barcode: return "BARCODE"
      @unknown default: return ""
      }
  }

  private func updateImageTypeTitle(position: Position) {
      let imageType: ImageType?
      var title: String = "ImageType"
      let button: UIButton

      switch position {
      case .first:
          imageType = selectedFirstImageType
          button = firstImageTypeButton
      case .second:
          imageType = selectedSecondImageType
          button = secondImageTypeButton
      }

      if let selectedFirstImageType = imageType {
          title.append(": \(self.title(for: selectedFirstImageType))")
      }
      button.setTitle(title, for: .normal)
  }

  private func updateDetectionAppearance() {
      detectionsButton.isHidden = lastDetections.isEmpty
      let faces = lastDetections.reduce(0) { $0 + $1.faces.count }
      detectionsButton.setTitle("DETECTIONS (\(faces))", for: .normal)
  }

//    private func pickImage(sourceType: UIImagePickerController.SourceType, completion: @escaping ((UIImage?) -> Void)) {
//        PHPhotoLibrary.requestAuthorization { (status) in
//            DispatchQueue.main.async {
//                switch status {
//                case .authorized:
//                    if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
//                        self.imagePickerCompletion = completion
//                        let imagePicker = UIImagePickerController()
//                        imagePicker.delegate = self
//                        imagePicker.sourceType = sourceType
//                        imagePicker.allowsEditing = false
//                        imagePicker.navigationBar.tintColor = .black
//                        self.present(imagePicker, animated: true, completion: nil)
//
//                    } else {
//                        completion(nil)
//                    }
//                case .denied:
//                    let message = NSLocalizedString("Application doesn't have permission to use the camera, please change privacy settings", comment: "Alert message when the user has denied access to the gallery")
//                    let alertController = UIAlertController(title: NSLocalizedString("Gallery Unavailable", comment: "Alert eror title"), message: message, preferredStyle: .alert)
//                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert manager, OK button tittle"), style: .cancel, handler: nil))
//                    alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"), style: .default, handler: { action in
//                        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
//                        if #available(iOS 10.0, *) {
//                            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
//                        } else {
//                            UIApplication.shared.openURL(settingsURL)
//                        }
//                    }))
//                    self.present(alertController, animated: true, completion: nil)
//                    print("PHPhotoLibrary status: denied")
//                    completion(nil)
//                case .notDetermined:
//                    print("PHPhotoLibrary status: notDetermined")
//                    completion(nil)
//                case .restricted:
//                    print("PHPhotoLibrary status: restricted")
//                    completion(nil)
//                case .limited:
//                    print("PHPhotoLibrary status: Limited")
//                    completion(nil)
//                @unknown default:
//                    fatalError()
//                }
//            }
//        }
//    }
}

extension MatchFacesViewController: ImagePickerDelegate {
    func didPickImage(delegate: ImagePicker, image: UIImage, sourceType: UIImagePickerController.SourceType) {

        switch delegate {
        case firstImagePicker:
            firstImageView.image = image
            selectedFirstImageType = sourceType == .camera ? .live : .printed
        case secondImagePicker:
            secondImageView.image = image
            selectedSecondImageType = sourceType == .camera ? .live : .printed
        default: break
        }
    }
}
