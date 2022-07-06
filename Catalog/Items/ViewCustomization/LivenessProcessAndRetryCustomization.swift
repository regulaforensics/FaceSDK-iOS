//
//  LivenessProcessAndRetryCustomization.swift
//  Catalog
//
//  Created by Dmitry Evglevsky on 7.06.22.
//  Copyright © 2022 Regula. All rights reserved.
//

import FaceSDK

final class LivenessCustomProcessingAndRetryScreensItem: CatalogItem {
    final class RetryContentView: LivenessRetryContentView {
        let customTryAgainStatus = UILabel()
        let customCheckConditionsLabel = UILabel()
        let customConditionsLabel = UILabel()
        let customCloseButton = UIButton()
        let customRetryButton = UIButton()
        
        override var tryAgainStatus: UILabel? { return customTryAgainStatus }
        override var checkConditionsLabel: UILabel? { return customCheckConditionsLabel }
        override var conditionsLabel: UILabel? { return customConditionsLabel }
        override var closeButton: UIButton? { return customCloseButton }
        override var retryButton: UIButton? { return customRetryButton }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            customTryAgainStatus.textColor = .red
            customTryAgainStatus.textAlignment = .center
            customTryAgainStatus.font = UIFont.systemFont(ofSize: 22)
            
            customCheckConditionsLabel.textColor = .systemBlue
            customCheckConditionsLabel.textAlignment = .center
            customCheckConditionsLabel.font = UIFont.systemFont(ofSize: 18)
            
            customConditionsLabel.textColor = .magenta
            customConditionsLabel.textAlignment = .center
            customConditionsLabel.font = UIFont.systemFont(ofSize: 12)
            
            customRetryButton.layer.cornerRadius = 32
            customRetryButton.backgroundColor = UIColor.systemBlue
            customRetryButton.setTitleColor(.white, for: .normal)
            customRetryButton.setTitle("RETRY", for: .normal)
            customRetryButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .light)
            
            customCloseButton.layer.cornerRadius = 32
            customCloseButton.backgroundColor = UIColor.clear
            customCloseButton.setTitleColor(.systemBlue, for: .normal)
            customCloseButton.setTitle("CANCEL", for: .normal)
            customCloseButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .light)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func setupConstraints() {
            // Don't call super.setupConstraints()
            
            if let tryAgainStatus = tryAgainStatus {
                tryAgainStatus.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    tryAgainStatus.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
                    tryAgainStatus.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
                    tryAgainStatus.topAnchor.constraint(equalTo: self.topAnchor, constant: 25)
                ])
            }
            
            if let checkConditionsLabel = checkConditionsLabel, let tryAgainStatus = tryAgainStatus {
                checkConditionsLabel.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    checkConditionsLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
                    checkConditionsLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
                    checkConditionsLabel.topAnchor.constraint(equalTo: tryAgainStatus.bottomAnchor, constant: 50)
                ])
            }
            
            if let conditionsLabel = conditionsLabel, let checkConditionsLabel = checkConditionsLabel {
                conditionsLabel.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    conditionsLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
                    conditionsLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
                    conditionsLabel.topAnchor.constraint(equalTo: checkConditionsLabel.bottomAnchor, constant: 24)
                ])
            }
            
            if let closeButton = closeButton {
                closeButton.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    closeButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20),
                    closeButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 32),
                    closeButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -32),
                    closeButton.heightAnchor.constraint(equalToConstant: 64)
                ])
            }
            
            if let retryButton = retryButton, let closeButton = closeButton {
                retryButton.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    retryButton.bottomAnchor.constraint(equalTo: closeButton.topAnchor, constant: -20),
                    retryButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 32),
                    retryButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -32),
                    retryButton.heightAnchor.constraint(equalToConstant: 64)
                ])
            }
        }
    }

    final class ProcessingContentView: LivenessProcessingContentView {
        let customCloseButton = UIButton()
        let customProcessingStatusLabel = UILabel()
        let customActivityIndicator = UIActivityIndicatorView()

        override var closeButton: UIButton? { return customCloseButton }
        override var processingStatusLabel: UILabel? { return customProcessingStatusLabel }
        override var activityIndicator: UIActivityIndicatorView? { return customActivityIndicator }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            customProcessingStatusLabel.textColor = .systemBlue
            customProcessingStatusLabel.textAlignment = .center
            customProcessingStatusLabel.font = UIFont.systemFont(ofSize: 22)
            
            customCloseButton.layer.cornerRadius = 32
            customCloseButton.backgroundColor = .systemBlue
            customCloseButton.setTitleColor(.white, for: .normal)
            customCloseButton.setTitle("CANCEL", for: .normal)
            customCloseButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .light)
            
            customActivityIndicator.color = .magenta
            customActivityIndicator.startAnimating()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func setupConstraints() {
            // Don't call super.setupConstraints()
            
            if let activityIndicator = activityIndicator {
                activityIndicator.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                    activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor)
                ])
            }
            
            if let processingStatusLabel = processingStatusLabel {
                processingStatusLabel.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    processingStatusLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
                    processingStatusLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
                    processingStatusLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 50)
                ])
            }

            if let closeButton = closeButton {
                closeButton.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    closeButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20),
                    closeButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 32),
                    closeButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -32),
                    closeButton.heightAnchor.constraint(equalToConstant: 64)
                ])
            }
        }
    }

    override init() {
        super.init()

        title = "Custom Liveness Process & Retry Screens"
        itemDescription = "Overriden ProcessingContentView & RetryContentView layout"
        category = .viewCustomization
    }

    override func onItemSelected(from viewController: UIViewController) {
        let configuration = LivenessConfiguration {
            $0.registerClass(ProcessingContentView.self, forBaseClass: LivenessProcessingContentView.self)
            $0.registerClass(RetryContentView.self, forBaseClass: LivenessRetryContentView.self)
        }

        FaceSDK.service.startLiveness(
            from: viewController,
            animated: true,
            configuration: configuration,
            onLiveness: { [weak self, weak viewController] response in
                guard let self = self, let viewController = viewController else { return }
                self.showLivenessResult(response, from: viewController)
            },
            completion: nil
        )
    }
}

