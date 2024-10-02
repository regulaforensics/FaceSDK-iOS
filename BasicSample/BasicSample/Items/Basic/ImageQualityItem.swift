//
//  ImageQualityItem.swift
//  BasicSample
//
//  Created by Serge Rylko on 26.08.22.
//  Copyright © 2022 Regula. All rights reserved.
//

import Foundation
import FaceSDK
import UIKit

class ImageQualityItem: CatalogItem {
    
    override init() {
        super.init()
        title = "Face Image Quality"
        itemDescription = "Checks whether a photo portrait meets certain standards"
        category = .basic
    }
    
    override func onItemSelected(from viewController: UIViewController) {
        let example = ImageQualityViewController()
        viewController.show(example, sender: nil)
    }
}

class ImageQualityViewController: UIViewController {
    
    private class QualityDetectionModel {
        let image: UIImage
        var detectedImages = [ImageQualityScenario: [UIImage]]()
        var detections = [ImageQualityScenario: [DetectFaceResult]]()
        var detailImage: ((UIImage) -> Void)?
        
        init(image: UIImage) {
            self.image = image
        }
    }
    
    private enum ImageQualityScenario: String, CaseIterable {
        case qualityICAO = "Quality ICAO"
        case qualityVisaUSA = "Quality Visa USA"
        case qualityVisaShengen = "Quality Visa Shengen"
        case customScenario = "Custom scenario"
    }
    
    private var selectedScenario: ImageQualityScenario = .qualityICAO
    
    private var models: [QualityDetectionModel] = [
        .init(image: .init(named: "face_image_quality1.jpeg")!),
        .init(image: .init(named: "face_image_quality2.jpeg")!),
        .init(image: .init(named: "face_image_quality3.jpeg")!),
        .init(image: .init(named: "face_image_quality4.jpeg")!),
    ]
    private var selectedModelIndex = 0
    
    private let contentView = UIView()
    
    private lazy var controlsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.spacing = 5
        stack.addArrangedSubview(complianceLabel)
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
    
    private lazy var resultsButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(didPressResults(_:)), for: .touchUpInside)
        button.setTitle("See Results", for: .normal)
        button.setTitle("Loading ...", for: .disabled)
        button.titleLabel?.lineBreakMode = .byTruncatingTail
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
        button.setTitle("Loading ...", for: .disabled)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.backgroundColor = .white
        button.setTitleColor(.windsor, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        button.layer.cornerRadius = 5
        button.clipsToBounds = false
        return button
    }()
    
    private lazy var galleryView: GalleryView = {
        let images = models.map { $0.image }
        let galleryView = GalleryView(images: images)
        galleryView.delegate = self
        return galleryView
    }()
    
    private lazy var complianceLabel: UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = false
        label.textColor = .windsor
        label.textAlignment = .center
        label.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        return label
    }()
    
    private lazy var scenariosStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 5.0

        for (index, scenario) in ImageQualityScenario.allCases.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(scenario.rawValue, for: .normal)
            button.tag = index
            button.addTarget(self, action: #selector(didPressScenarioButton(_:)), for: .touchUpInside)
            button.tintColor = .windsor
            stackView.addArrangedSubview(button)
        }
        return stackView
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(didPressSendButton(_:)), for: .touchUpInside)
        button.setTitle("Detect Face Image Quality", for: .normal)
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
        title = "Face Image Quality"
        view.backgroundColor = .white
        
        view.addSubview(contentView)
        contentView.addSubview(galleryView)
        contentView.addSubview(controlsStackView)
        contentView.addSubview(activityIndicator)

        setupConstraints()
        updateScenarioSelection()
    }

    private func sendDetectFacesRequest() {
        let model = models[selectedModelIndex]
        let image = model.image
        
        let request: DetectFacesRequest
        
        switch selectedScenario {
        case .qualityICAO:
            request = DetectFacesRequest.qualityICAORequest(for: image)
        case .qualityVisaUSA:
            request = DetectFacesRequest.qualityVisaUSARequest(for: image)
        case .qualityVisaShengen:
            request = DetectFacesRequest.qualityVisaSchengenRequest(for: image)
        case .customScenario:
            let config = DetectFacesConfiguration()
            config.onlyCentralFace = false
            config.customQuality = [
                ImageQualityGroup.Image.imageHeight(withRange: [600, 800]),
                ImageQualityGroup.Image.imageWidth(withRange: [800, 1000]),
                ImageQualityGroup.FaceImage.blurLevel(),
                ImageQualityGroup.HeadOcclusion.headphones().withCustomRange([0.0, 0.1]),
                ImageQualityGroup.HeadOcclusion.headCovering().withCustomRange([0.0, 0.1]),
                ImageQualityGroup.Background.backgroundColorMatch(with: .white)
            ]
            let outputImageParams = OutputImageParams()
            outputImageParams.backgroundColor = .white
            outputImageParams.crop = .init(type: .ratio4x5)
            config.outputImageParams = outputImageParams
            
            request = DetectFacesRequest(image: image, configuration: config)
        }
        
        showLoadingActivity()
        
        FaceSDK.service.detectFaces(by: request) { [weak self] response in
            guard let self = self else { return }
            self.hideLoadingActivity()
            
            if let error = response.error {
                print(error.localizedDescription)
            } else {
                self.updateSuccessResults(for: model, scenario: self.selectedScenario, response: response)
            }
        }
    }
    
    private func updateSuccessResults(for model: QualityDetectionModel, scenario: ImageQualityScenario, response: DetectFacesResponse) {
        let detections = response.allDetections
        let detectedImages = detections?.compactMap({ $0.crop })
        model.detectedImages[scenario] = detectedImages
        model.detections[scenario] = detections
        updateResultsLabel()
        updateComplianceStatusLabel()
        
        if let detections = response.allDetections {
            showFacemarks(for: model, detections: detections)
        }
    }
    
    @objc private func didPressSendButton(_ sender: Any) {
        sendDetectFacesRequest()
    }
    
    @objc private func didPressScenarioButton(_ sender: UIButton) {
        selectedScenario = ImageQualityScenario.allCases[sender.tag]
        updateScenarioSelection()
    }
    
    @objc private func didPressResults(_ sender: Any) {
        let model = models[selectedModelIndex]
        guard let detections = model.detections[selectedScenario] else { return }
        let qualityVC = QualityResultsViewController(detections: detections, originalImage: model.image)
        navigationController?.pushViewController(qualityVC, animated: true)
    }
    
    private func updateScenarioSelection() {
        guard let scenarioIndex = ImageQualityScenario.allCases.firstIndex(of: selectedScenario) else { return }
        
        let buttons = scenariosStackView.arrangedSubviews.compactMap { $0 as? UIButton }
            
        buttons.forEach { button in
            button.isSelected = button.tag == scenarioIndex
        }
        
        updateResultsLabel()
        updateComplianceStatusLabel()
    }
    
    @objc private func didPressPickPhoto(_ sender: Any) {
        imagePicker.presentPickerActions(from: galleryView)
    }
    
    private func updateComplianceStatusLabel() {
        let model = models[selectedModelIndex]
        let detections = model.detections[selectedScenario]
        
        let text: String
        
        if detections == nil {
           text = "  "
        } else {
            let isCompliant = detections?.allSatisfy({ $0.isQualityCompliant }) == true
            text = isCompliant ? "✅ COMPLIANT" : "🚫 NON-COMPLIANT "
        }
        complianceLabel.text = text
    }
    
    private func updateResultsLabel() {
        let model = models[selectedModelIndex]
        let detections = model.detections[selectedScenario]
        let qualityResults = detections?
            .compactMap({ $0.quality })
            .flatMap({ $0 })
        
        let toHideButton: Bool
        let text: String
        
        if qualityResults == nil {
            text = ""
            toHideButton = true
        } else if qualityResults?.isEmpty == true {
            text = "No Quality Results"
            toHideButton = false
        } else {
            text = "Quality Results (\(qualityResults?.count ?? 0))"
            toHideButton = false
        }
        resultsButton.isHidden = toHideButton
        resultsButton.setTitle(text, for: .normal)
    }
    
    private func showFacemarks(for model: QualityDetectionModel,  detections: [DetectFaceResult]) {
        guard detections.isEmpty == false else { return }
        let image = model.image
        // scale lines and points according target view size
        let scale = image.size.width / galleryView.bounds.width
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

            controlsStackView.topAnchor.constraint(equalTo: galleryView.bottomAnchor, constant: 10),
            controlsStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            controlsStackView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.75),
            controlsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,constant: -20),

            activityIndicator.centerXAnchor.constraint(equalTo: controlsStackView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: controlsStackView.centerYAnchor)
        ])
    }
}

extension ImageQualityViewController: ImagePickerDelegate {
    func didPickImage(delegate: ImagePicker, image: UIImage, sourceType: UIImagePickerController.SourceType) {
        let model = QualityDetectionModel(image: image)
        models.append(model)
        galleryView.images = models.map { $0.image }
        galleryView.selectedIndex = models.count - 1
    }
}

extension ImageQualityViewController: GalleryViewDelegate {
    func didSelectImage(gallery: GalleryView, image: UIImage, selectedImageIndex: Int, detailImageSetter: ((UIImage) -> Void)?) {
        selectedModelIndex = selectedImageIndex
        models[selectedModelIndex].detailImage = detailImageSetter
        updateResultsLabel()
        updateComplianceStatusLabel()
    }
}
