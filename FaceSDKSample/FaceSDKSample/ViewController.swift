//
//  ViewController.swift
//  FaceSDKSample
//
//  Created by Vladislav Yakimchik on 29.11.20.
//

import UIKit
import FaceSDK
import Photos

class ViewController: UIViewController {
    
    @IBOutlet weak var firtImageView: UIImageView!
    @IBOutlet weak var secondImageView: UIImageView!
    
    @IBOutlet weak var matchFacesButton: UIButton!
    @IBOutlet weak var livenessButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    
    @IBOutlet weak var similarityLabel: UILabel!
    @IBOutlet weak var livenessLabel: UILabel!
    
    var imagePicker = UIImagePickerController()
    var currentImageView = UIImageView()
    
    var strSimilarity = "Similarity: nil"
    var strLiveness = "Liveness: nil"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGestureFirst = UITapGestureRecognizer(target: self, action: #selector(ViewController.imageTapped(gesture:)))
        firtImageView.addGestureRecognizer(tapGestureFirst)
        firtImageView.isUserInteractionEnabled = true
        
        let tapGestureSecond = UITapGestureRecognizer(target: self, action: #selector(ViewController.imageTapped(gesture:)))
        secondImageView.addGestureRecognizer(tapGestureSecond)
        secondImageView.isUserInteractionEnabled = true
        
        similarityLabel.text = strSimilarity
        livenessLabel.text = strLiveness
        
        Face.service.requestInterceptingDelegate = self
    }
    
    @objc func imageTapped(gesture: UIGestureRecognizer) {
        if (gesture.view as? UIImageView) != nil {
            showActions(controller: self, imageView: (gesture.view as? UIImageView)!)
        }
    }
    
    func showActions(controller: UIViewController, imageView: UIImageView) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {_ in
            self.startFaceCaptureVC(controller: self, imageView: imageView)
        }))
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: {_ in
            self.currentImageView = imageView
            imageView.tag = ImageType.printed.rawValue
            self.pickImage(sourceType: .photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: "Camera shoot", style: .default, handler: {_ in
            self.currentImageView = imageView
            imageView.tag = ImageType.live.rawValue
            self.pickImage(sourceType: .camera)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        if let popoverPresentationController = alert.popoverPresentationController {
            popoverPresentationController.sourceView = view
            popoverPresentationController.sourceRect = CGRect(x: imageView.frame.midX, y: imageView.frame.midY, width: 0, height: 0)
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func startFaceCaptureVC(controller: UIViewController, imageView: UIImageView) {
        let configuration = FaceCaptureConfiguration {
            $0.cameraPosition = .front
            $0.cameraSwitchEnabled = true
        }
        
        Face.service.presentCaptureViewController(from: controller, animated: true, configuration: configuration, onCapture: { (faceCaptureResponse: FaceCaptureResponse?) in
            if let faceCaptureResponse = faceCaptureResponse {
                if let image = faceCaptureResponse.image {
                    imageView.image = image.image
                    imageView.tag = ImageType.live.rawValue
                }
                
                print(faceCaptureResponse)
            }
        }, completion: nil)
    }
    
    @IBAction func startMatchFaces(sender: UIButton) {
        var matchRequestImages = [Image]()

        if firtImageView.image != nil && secondImageView.image != nil {
            let firstImageType = ImageType(rawValue: firtImageView.tag) ?? .printed
            let firstImage = Image(image: firtImageView.image!, type: firstImageType)
            matchRequestImages.append(firstImage)

            let secondImageType = ImageType(rawValue: secondImageView.tag) ?? .printed
            let secondImage = Image(image: secondImageView.image!, type: secondImageType)
            matchRequestImages.append(secondImage)
            
            let request = MatchFacesRequest(images: matchRequestImages)
            
            self.similarityLabel.text = "Processing..."
            self.matchFacesButton.isEnabled = false
            self.livenessButton.isEnabled = false
            self.clearButton.isEnabled = false
            
            Face.service.matchFaces(request, completion: { (response: MatchFacesResponse?) in
                self.matchFacesButton.isEnabled = true
                self.livenessButton.isEnabled = true
                self.clearButton.isEnabled = true
                
                if let response = response {
                    if let matchedFaces = response.matchedFaces.first {
                        let similarity = "Similarity: " + String(format: "%.2f", Double(truncating: matchedFaces.similarity) * 100) + "%"
                        self.similarityLabel.text = similarity
                    } else {
                        self.similarityLabel.text = "Similarity: error"
                    }
                    print(response)
                } else {
                    let alert = UIAlertController(title: "No response", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    print("No response")
                }
            })

        } else {
            let alert = UIAlertController(title: "Having both images are compulsory", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func startLiveness(sender: UIButton) {
        let configuration = LivenessConfiguration {
            $0.cameraPosition = .front
            $0.cameraSwitchEnabled = true
        }
                
        Face.service.startLiveness(from: self, animated: true, configuration: configuration) { (livenessResponse: LivenessResponse?) in
            if let livenessResponse = livenessResponse {
                self.firtImageView.image = livenessResponse.image
                self.firtImageView.tag = ImageType.live.rawValue
                
                let livenessStatus = livenessResponse.liveness == .passed ? "Liveness: passed" : "Liveness: unknown"
                self.livenessLabel.text = livenessStatus
                self.similarityLabel.text = "Similarity: nil"
                
                print(livenessResponse)
            } else {
                print("No response")
            }
        } completion: {
            print("Liveness completed")
        }
    }
    
    @IBAction func clear(sender: UIButton) {
        self.firtImageView.image = nil
        self.secondImageView.image = nil
        self.similarityLabel.text = strSimilarity
        self.livenessLabel.text = strLiveness
    }
    
    func pickImage(sourceType: UIImagePickerController.SourceType) {
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
                  DispatchQueue.main.async {
                    self.imagePicker.delegate = self
                    self.imagePicker.sourceType = sourceType;
                    self.imagePicker.allowsEditing = false
                    self.imagePicker.navigationBar.tintColor = .black
                    self.present(self.imagePicker, animated: true, completion: nil)
                  }
                }
            case .denied:
                let message = NSLocalizedString("Application doesn't have permission to use the camera, please change privacy settings", comment: "Alert message when the user has denied access to the gallery")
                let alertController = UIAlertController(title: NSLocalizedString("Gallery Unavailable", comment: "Alert eror title"), message: message, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert manager, OK button tittle"), style: .cancel, handler: nil))
                alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"), style: .default, handler: { action in
                    if #available(iOS 10.0, *) {
                        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
                        UIApplication.shared.open(settingsURL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
                    }
                }))
                self.present(alertController, animated: true, completion: nil)
                print("PHPhotoLibrary status: denied")
                break
            case .notDetermined:
                print("PHPhotoLibrary status: notDetermined")
            case .restricted:
                print("PHPhotoLibrary status: restricted")
            case .limited:
                print("PHPhotoLibrary status: Limited")
            @unknown default:
                fatalError()
            }
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        if let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            self.dismiss(animated: true, completion: {
                self.currentImageView.image = image
            })
        } else {
            self.dismiss(animated: true, completion: nil)
            print("Something went wrong")
        }
    }
}

fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}

fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}

extension ViewController: URLRequestInterceptingDelegate {
    
    func interceptorPrepare(_ request: URLRequest) -> URLRequest? {
        var request = request
        
        request.addValue("123", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
}
