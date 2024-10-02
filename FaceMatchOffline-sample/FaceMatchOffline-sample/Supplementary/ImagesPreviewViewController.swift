//
//  ImagesPreviewViewController.swift
//  BasicSample
//
//  Created by Pavel Kondrashkov on 5/21/21.
//  Copyright © 2021 Regula. All rights reserved.
//

import UIKit

final class ImagesPreviewViewController: UIViewController {
    private let images: [UIImage]

    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()

    private lazy var nextButton: UIButton = {
        let view = UIButton(type: .system)
        view.setTitle("Next", for: .normal)
        view.setTitleColor(.white, for: .normal)
        view.backgroundColor = .systemBlue
        view.contentEdgeInsets = UIEdgeInsets(top: 5, left: 16, bottom: 6, right: 16)
        view.layer.cornerRadius = 5
        view.clipsToBounds = false
        view.addTarget(self, action: #selector(self.handleNextButtonPress), for: .touchUpInside)
        return view
    }()

    private var currentImageIndex = -1

    init(images: [UIImage]) {
        self.images = images
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = UIView()
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }

        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
          imageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])

        view.addSubview(nextButton)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
          nextButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -40),
        ])

        nextButton.isHidden = images.count < 2
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = nextImage()
    }

    private func nextImage() -> UIImage? {
        guard !images.isEmpty else { return nil }
        currentImageIndex += 1
        currentImageIndex %= images.count

        self.navigationItem.title = "image: \(currentImageIndex + 1)"

        guard images.indices.contains(currentImageIndex) else { return nil }
        return images[currentImageIndex]
    }

    @objc func handleNextButtonPress() {
        imageView.image = nextImage()
    }
}
