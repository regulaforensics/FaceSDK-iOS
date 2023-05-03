//
//  ImageQualityResultsViewController.swift
//  Catalog
//
//  Created by Deposhe on 31.08.22.
//  Copyright © 2022 Regula. All rights reserved.
//

import UIKit
import FaceSDK

class QualityResultsViewController: UIViewController {

    private struct Section {
        let group: ImageQualityGroup
        let results: [ImageQualityResult]
    }
    
    private let carouselView = CarouselView()
    private let tableView = UITableView(frame: .zero, style: .grouped)
   
    private let originalImage: UIImage
    private let detections: [DetectFaceResult]
    private var selectedDetection: DetectFaceResult? {
        didSet { updateSelection(oldValue: oldValue) }
    }
    private var sections: [Section] = []
    
    init(detections: [DetectFaceResult], originalImage: UIImage) {
        let sortedDetections = detections.sorted(by: { result1, result2 in
            let qualityScore1 = result1.quality?.filter({ $0.status == .true }).count ?? 0
            let qualityScore2 = result2.quality?.filter({ $0.status == .true }).count ?? 0
            return qualityScore1 < qualityScore2
        })
        self.detections = sortedDetections
        self.originalImage = originalImage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Face Image Quality Results"
        view.backgroundColor = .white
        
        carouselView.images = detections.map({ $0.crop ?? UIImage(named: "person_placeholder") ?? UIImage() })
        carouselView.delegate = self
        view.addSubview(carouselView)
        
        tableView.allowsSelection = false
        tableView.dataSource = self
        tableView.estimatedRowHeight = UITableView.automaticDimension
        view.addSubview(tableView)
        
        let resultBarButton = UIBarButtonItem(title: "Detections", style: .plain, target: self, action: #selector(didPressResultsButton(_:)))
        navigationItem.setRightBarButton(resultBarButton, animated: true)
        
        setupConstraints()
        selectedDetection = detections.first
    }
    
    @IBAction private func didPressResultsButton(_ sender: Any) {
        let detectedFacesImages = detections.compactMap({ $0.crop })
        guard !detectedFacesImages.isEmpty else { return }

        let previewVC = ImagesPreviewViewController(images: detectedFacesImages)
        navigationController?.pushViewController(previewVC, animated: true)
    }
    
    private func updateSelection(oldValue: DetectFaceResult?) {
        guard selectedDetection != oldValue else { return }
        sections = groupAndSortQualityResults()
        tableView.reloadData()
    }
    
    private func groupDescription(for group: ImageQualityGroup) -> String {
        switch group {
        case .imageСharacteristics: return "Image characteristics"
        case .headSizeAndPosition:  return "Head size and position"
        case .faceQuality:          return "Face quality"
        case .eyesCharacteristics:  return "Eyes characteristics"
        case .shadowsAndLightning:  return "Shadows and lightning"
        case .poseAndExpression:    return "Pose and expression"
        case .headOcclusion:        return "Head occlusion"
        case .background:           return "Background"
        @unknown default:
            return "unknown"
        }
    }
    
    private func statusDescription(for status: ImageQualityResult.Status) -> String {
        switch status {
        case .true: return "✅"
        case .false: return "⛔️"
        case .undetermined: return "⚠️"
        @unknown default:
            return "unknown"
        }
    }
    
    private func footerDescription(for section: Int) -> String {
        let section = sections[section]
        let groupDescription = groupDescription(for: section.group)
        let results = section.results
        let succededQualitiesCount = results.filter({ $0.status != .false }).count
        let allQualitiesCount = results.count
        let badge = succededQualitiesCount == allQualitiesCount ? " " : "⛔️"
        let sectionScore = "\(badge) \(succededQualitiesCount)/\(allQualitiesCount)"
        return "\(groupDescription) \(sectionScore)"
    }
    
    private func resultDescription(for result: ImageQualityResult) -> String {
        "VALUE: \(result.value) \nEXPECTED RANGE: [\(result.range.min):\(result.range.max)]"
    }
    
    private func groupAndSortQualityResults() -> [Section] {
        let qualities = selectedDetection?.quality ?? []
        let groupedResults = Dictionary(grouping: qualities, by: { $0.group })
        var sections = groupedResults.keys.map { group -> Section in
            let qualityResults = groupedResults[group] ?? []
            let sortedResults = qualityResults.sorted(by: { $0.status.rawValue < $1.status.rawValue })
            return Section(group: group, results: sortedResults)
        }
        
        sections.sort { section1, section2 in
            section1.group.rawValue > section2.group.rawValue
        }
 
        sections.sort { section1, section2 in
            let failures1 = section1.results.filter { $0.status != .true }.count
            let failures2 = section2.results.filter { $0.status != .true }.count
            return failures1 >= failures2// || section1.group.rawValue < section2.group.rawValue
        }
        return sections
    }
  
    private func setupConstraints() {
        [carouselView, tableView].forEach({ $0.translatesAutoresizingMaskIntoConstraints = false })
        
        NSLayoutConstraint.activate([
            carouselView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            carouselView.leftAnchor.constraint(equalTo: view.leftAnchor),
            carouselView.rightAnchor.constraint(equalTo: view.rightAnchor),
            carouselView.heightAnchor.constraint(equalToConstant: 200),
            
            tableView.topAnchor.constraint(equalTo: carouselView.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}

extension QualityResultsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseID") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "reuseID")
        let item = sections[indexPath.section].results[indexPath.row]
        let status = statusDescription(for: item.status)
        let range = resultDescription(for: item)
        cell.textLabel?.text = "\(status) \(item.name.rawValue)"
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.text = range
        cell.detailTextLabel?.numberOfLines = 0
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        footerDescription(for: section)
    }
}

extension QualityResultsViewController: CarouselViewDelegate {
    
    func didSelectImage(delegate: CarouselView, atIndex index: Int) {
        selectedDetection = detections[index]
    }
}
