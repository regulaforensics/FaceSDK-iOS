//
//  EnrollVerifyViewController.swift
//  EnrollVerifySample
//
//  Created by Dmitry Evglevsky on 10.09.2026.
//

import FaceSDK
import UIKit

class EnrollVerifyViewController: UIViewController {
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var initializationLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var livenessImageView: UIImageView!
    @IBOutlet weak var enrollLabel: UILabel!
    @IBOutlet weak var personIdLabel: UILabel!
    @IBOutlet weak var personNameLabel: UILabel!
    @IBOutlet weak var clearDataButton: UIButton!
    @IBOutlet weak var verificationInfoLabel: UILabel!
    @IBOutlet weak var verifyLabel: UILabel!
    @IBOutlet weak var matchLabel: UILabel!
    
    var enrollmentResponse: EnrollmentResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FaceSDK.service.initialize { success, error in
            self.activityIndicatorView.stopAnimating()
            if error == nil {
                self.initializationLabel.isHidden = true
                self.contentView.isHidden = false
            } else {
                self.initializationLabel.text = error?.localizedDescription
            }
        }
        
        showEnrollUI(false)
        showVerifyUI(false)
        self.clearDataButton.isHidden = true
    }
    
    @IBAction func enrollButtonPressed(_ sender: UIButton) {
        let person = PersonDatabase.Person()
        
        let enrollmentConfiguration = EnrollmentConfiguration {
            $0.person = person
        }
        
        FaceSDK.service.startEnrollment(from: self, animated: true, configuration: enrollmentConfiguration) { livenessResponse, enrollmentResponse in
            if livenessResponse.error != nil {
                self.errorMessageLabel.text = livenessResponse.error?.localizedDescription
            }
            
            if livenessResponse.image != nil {
                self.livenessImageView.image = livenessResponse.image
            }
            
            if let enrollment = enrollmentResponse {
                self.enrollmentResponse = enrollment
                self.enrollLabel.text = enrollment.enrolled ? "Enrolled: true" : "Enrolled: false"
                
                if enrollment.person != nil {
                    self.personIdLabel.text = "Person ID: \(enrollment.person!.itemId ?? "n/a")"
                    self.personNameLabel.text = "Person name: \(enrollment.person!.name)"
                }
                
                self.clearDataButton.isHidden = false
                self.showEnrollUI(true)
            }
        } completion: {
            
        }
    }
    
    @IBAction func verifyButtonPressed(_ sender: UIButton) {
        guard let enrollmentResponse else { return }
        
        let verifyConfiguration = VerificationConfiguration {
            $0.personId = enrollmentResponse.person?.itemId
        }
        
        FaceSDK.service.startVerification(from: self, animated: true, configuration: verifyConfiguration) { livenessResponse, verificationResponse in
            if livenessResponse.error != nil {
                self.errorMessageLabel.text = livenessResponse.error?.localizedDescription
            }
            
            if livenessResponse.image != nil {
                self.livenessImageView.image = livenessResponse.image
            }
            
            if let verification = verificationResponse {
                self.verifyLabel.text = verification.verified ? "Verified: true" : "Verified: false"
                
                if let match = verification.match {
                    self.matchLabel.text = "Similarity: \(match.similarity?.stringValue ?? "n/a")"
                }
                
                self.clearDataButton.isHidden = false
                self.showVerifyUI(true)
            }
        } completion: {
            
        }
    }
    
    func showEnrollUI(_ show: Bool) {
        self.enrollLabel.isHidden = !show
        self.personIdLabel.isHidden = !show
        self.personNameLabel.isHidden = !show
    }
    
    func showVerifyUI(_ show: Bool) {
        self.verificationInfoLabel.isHidden = !show
        self.verifyLabel.isHidden = !show
        self.matchLabel.isHidden = !show
    }
    
    @IBAction func clearButtonPressed(_ sender: UIButton) {
        self.enrollmentResponse = nil
        
        self.livenessImageView.image = nil
        self.enrollLabel.text = ""
        self.personIdLabel.text = ""
        self.personNameLabel.text = ""
        self.verifyLabel.text = ""
        self.matchLabel.text = ""
        self.errorMessageLabel.text = ""
        
        showEnrollUI(false)
        showVerifyUI(false)
        self.clearDataButton.isHidden = true
    }
}

