//
//  DetectFacesItem.swift
//  BasicSample
//
//  Created by Serge Rylko on 25.08.22.
//  Copyright © 2022 Regula. All rights reserved.
//

import Foundation
import FaceSDK
import UIKit

class DetectFacesItem: CatalogItem {
    
    override init() {
        super.init()
        title = "Face Detection"
        itemDescription = "Analyzes images, recognizes faces in them, and returns cropped and aligned portraits of the detected people"
        category = .basic
    }
    
    override func onItemSelected(from viewController: UIViewController) {
        let example = DetectFacesViewController()
        viewController.show(example, sender: nil)
    }
}

class DetectFacesViewController: UIViewController, UINavigationControllerDelegate {
    
    private class DetectionModel {
        let image: UIImage
        var detectedImages = [DetectionScenario: [UIImage]]()
        var detailImage: ((UIImage) -> Void)?
        
        init(image: UIImage) {
            self.image = image
        }
    }
    
    private enum DetectionScenario: String, CaseIterable {
        case cropCentralFace = "Crop central face"
        case cropAllFaces = "Crop all faces"
        case customScenario1 = "Custom scenario 1"
        case customScenario2 = "Custom scenario 2"
    }
    
    private var selectedScenario: DetectionScenario = .cropCentralFace
    
    private var models: [DetectionModel] = [
        .init(image: .init(named: "detect_face1.jpeg")!),
        .init(image: .init(named: "detect_face2.jpeg")!),
        .init(image: .init(named: "detect_face3.jpeg")!),
        .init(image: .init(named: "detect_face4.jpeg")!),
    ]
    
    private var selectedModelIndex: Int = 0
    
    private let contentView = UIView()
    
    private lazy var controlsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.spacing = 5
        stack.addArrangedSubview(UIView())
        stack.addArrangedSubview(scenariosStackView)
        stack.addArrangedSubview(buttonsStackView)
        return stack
    }()

    private lazy var buttonsStackView: UIStackView = {
        let buttonStack = UIStackView()
        buttonStack.axis = .vertical
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 5
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.addArrangedSubview(pickPhotoButton)
        stack.addArrangedSubview(resultsButton)
        buttonStack.addArrangedSubview(stack)
        buttonStack.addArrangedSubview(sendButton)
        return buttonStack
    }()
    
    private lazy var galleryView: GalleryView = {
        let images = models.map { $0.image }
        let galleryView = GalleryView(images: images)
        galleryView.delegate = self
        return galleryView
    }()
    
    private lazy var scenariosStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 5.0
        
        for (index, scenario) in DetectionScenario.allCases.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(scenario.rawValue, for: .normal)
            button.tag = index
            button.addTarget(self, action: #selector(didPressScenarioButton(_:)), for: .touchUpInside)
            button.tintColor = .windsor
            stackView.addArrangedSubview(button)
        }
        return stackView
    }()
    
    private lazy var resultsButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(didPressResults(_:)), for: .touchUpInside)
        button.setTitle("See Results", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.backgroundColor = .white
        button.setTitleColor(.windsor, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        button.layer.cornerRadius = 5
        button.clipsToBounds = false
        return button
    }()
    
    private lazy var pickPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(didPressPickPhoto(_:)), for: .touchUpInside)
        button.setTitle("Pick Photo", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.backgroundColor = .white
        button.setTitleColor(.windsor, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        button.layer.cornerRadius = 5
        button.clipsToBounds = false
        return button
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(didPressSendButton(_:)), for: .touchUpInside)
        button.setTitle("Detect Faces", for: .normal)
        button.setTitle("Loading ...", for: .disabled)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.backgroundColor = .windsor
        button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        button.layer.cornerRadius = 5
        button.clipsToBounds = false
        return button
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .whiteLarge)
        indicator.hidesWhenStopped = true
        indicator.color = .black
        return indicator
    }()
    
    private lazy var imagePicker: ImagePicker = ImagePicker(presenter: self, delegate: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Detect Faces"
        view.backgroundColor = .white
        view.addSubview(contentView)
        contentView.addSubview(activityIndicator)
        contentView.addSubview(galleryView)
        contentView.addSubview(controlsStackView)
        
        setupConstraints()
        updateScenarioSelection()
    }

    private func sendDetectFacesRequest() {
        let model = models[selectedModelIndex]
        let image = model.image
        
        let request: DetectFacesRequest
        
        switch selectedScenario {
        case .cropCentralFace:
            request = DetectFacesRequest.cropCentralFace(for: image)
        case .cropAllFaces:
            request = DetectFacesRequest.cropAllFacesRequest(for: image)
        case .customScenario1:
            let outputImageParams = OutputImageParams()
            outputImageParams.crop = .init(type: .ratio4x5)
            let config = DetectFacesConfiguration()
            config.onlyCentralFace = true
            config.outputImageParams = outputImageParams
            request = DetectFacesRequest(image: image, configuration: config)
        case .customScenario2:
            let outputImageParams = OutputImageParams()
            let preferredSize = CGSize(width: 500, height: 600)
            outputImageParams.crop = .init(type: .ratio2x3, size: preferredSize, padColor: .black, returnOriginalRect: true)
            let config = DetectFacesConfiguration()
            config.onlyCentralFace = false
            config.outputImageParams = outputImageParams
            request = DetectFacesRequest(image: image, configuration: config)
        }
        
        showLoadingActivity()
        
        FaceSDK.service.detectFaces(by: request) { [weak self] response in
            guard let self = self else { return }
            self.hideLoadingActivity()

            if let error = response.error {
                print(error)
            } else {
                self.updateSuccessResults(for: model, scenario: self.selectedScenario, response: response)
            }
        }
    }
    
    private func updateSuccessResults(for model: DetectionModel, scenario: DetectionScenario, response: DetectFacesResponse) {
        let detectedImages = response.allDetections?.compactMap({ $0.crop })
        model.detectedImages[scenario] = detectedImages
        updateResultsLabel()
        
        if let detections = response.allDetections {
            showFacemarks(for: model, detections: detections)
        }
    }
    
    @objc private func didPressSendButton(_ sender: Any) {
        sendDetectFacesRequest()
    }
    
    @objc private func didPressScenarioButton(_ sender: UIButton) {
        selectedScenario = DetectionScenario.allCases[sender.tag]
        updateScenarioSelection()
        sendDetectFacesRequest()
    }
    
    @objc private func didPressResults(_ sender: Any) {
        guard let images = models[selectedModelIndex].detectedImages[selectedScenario] else { return }
        let imageVC = ImagesPreviewViewController(images: images)
        navigationController?.pushViewController(imageVC, animated: true)
    }
    
    @objc private func didPressPickPhoto( _ sender: Any) {
        imagePicker.presentPickerActions(from: galleryView)
    }
    
    private func updateScenarioSelection() {
        guard
            let buttons = scenariosStackView.arrangedSubviews as? [UIButton],
            let scenarioIndex = DetectionScenario.allCases.firstIndex(of: selectedScenario)
        else { return }
        
        buttons.forEach { button in
            button.isSelected = button.tag == scenarioIndex
        }
        
        updateResultsLabel()
    }
    
    private func updateResultsLabel() {
        let model = models[selectedModelIndex]
        let detectedFaceImages = model.detectedImages[selectedScenario]
        let toHideButton: Bool
        let text: String
        
        if detectedFaceImages == nil {
            text = ""
            toHideButton = true
        } else if detectedFaceImages?.isEmpty == true {
            text = "No Face Images"
            toHideButton = false
        } else {
            text = "See Face Images (\(detectedFaceImages?.count ?? 0))"
            toHideButton = false
        }
        resultsButton.isHidden = toHideButton
        resultsButton.setTitle(text, for: .normal)
    }
    
    private func showFacemarks(for model: DetectionModel,  detections: [DetectFaceResult]) {
        guard detections.isEmpty == false else { return }
        let image = model.image
        // scale lines and points according target view size
        var scale = image.size.width / galleryView.bounds.width
        if image.size.height > image.size.width {
            scale = image.size.height / galleryView.bounds.height
        }
        let lineWidth = 2 * scale
        let pointSize = 2 * scale
        
        let imageWithDetectionMarks = detections.reduce(image) { resultImage, detection in
            return ImageHelper.drawFaceDetection(onImage: resultImage,
                                                 detection: detection,
                                                 color: .green,
                                                 lineWidth: lineWidth,
                                                 pointSize: pointSize) ?? image
        }
        model.detailImage?(imageWithDetectionMarks)
    }
    
    private func showLoadingActivity() {
        sendButton.isEnabled = false
        galleryView.isUserInteractionEnabled = false
        scenariosStackView.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingActivity() {
        sendButton.isEnabled = true
        galleryView.isUserInteractionEnabled = true
        scenariosStackView.isUserInteractionEnabled = true
        activityIndicator.stopAnimating()
    }
    
    private func setupConstraints() {
        [contentView,
         activityIndicator,
         galleryView,
         controlsStackView].forEach({ $0.translatesAutoresizingMaskIntoConstraints = false })
        
        let pickerHeight: NSLayoutConstraint
        let contentWidth: NSLayoutConstraint
        if UIDevice.current.userInterfaceIdiom == .phone {
            contentWidth = contentView.widthAnchor.constraint(equalTo: view.widthAnchor)
            pickerHeight = galleryView.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.75)
        } else {
            contentWidth = contentView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6)
            pickerHeight = galleryView.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.6)
        }
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            contentWidth,
            
            galleryView.topAnchor.constraint(equalTo: contentView.topAnchor),
            galleryView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            galleryView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            pickerHeight,

            controlsStackView.topAnchor.constraint(equalTo: galleryView.bottomAnchor),
            controlsStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            controlsStackView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.75),
            controlsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,constant: -20),

            activityIndicator.centerXAnchor.constraint(equalTo: controlsStackView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: controlsStackView.centerYAnchor)
        ])
    }
}

extension DetectFacesViewController: ImagePickerDelegate {
    func didPickImage(delegate: ImagePicker, image: UIImage, sourceType: UIImagePickerController.SourceType) {
        let model = DetectionModel(image: image)
        models.append(model)
        galleryView.images = models.map { $0.image }
        galleryView.selectedIndex = models.count - 1
    }
}

extension DetectFacesViewController: GalleryViewDelegate {
    func didSelectImage(gallery: GalleryView, image: UIImage, selectedImageIndex: Int, detailImageSetter: ((UIImage) -> Void)?) {
        selectedModelIndex = selectedImageIndex
        models[selectedModelIndex].detailImage = detailImageSetter
        updateResultsLabel()
    }
}
