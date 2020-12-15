//
//  ViewController.swift
//  SeeFood
//
//  Created by Rohan Parkes on 20/8/19.
//  Copyright © 2019 Rohan Parkes. All rights reserved.
//

import UIKit
import VisualRecognitionV3
import RestKit
import SVProgressHUD
import Social

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topBarImageView: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    
    let apiKey = "o8Dy4b3Z-EJ0SgVUf-AxA6_HVoq_v1NhU0aFg5k9p1zV"
    let version = "2019-08-20"
    let imagePicker = UIImagePickerController()
    var classificationResults: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shareButton.isHidden = true
        imagePicker.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = ""
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        navigationItem.title = ""
        cameraButton.isEnabled = false
        SVProgressHUD.show()
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = image
            
            imagePicker.dismiss(animated: true, completion: nil)
            
            let imageData = image.jpegData(compressionQuality: 0.01)
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsURL.appendingPathComponent("tempImage.jpg")
            
            try? imageData?.write(to: fileURL)
            
            let jpgImage = UIImage(contentsOfFile: fileURL.path)!
            
            let visualRecognition = VisualRecognition(version: version, apiKey: apiKey)
            print("Service URL is: \(visualRecognition.serviceURL)")
            
            visualRecognition.classify(image: jpgImage) { (classifiedImages, error) in
                
                let classes = classifiedImages?.result?.images.first!.classifiers.first!.classes
                
                self.classificationResults = []
                
                for index in 0..<classes!.count {
                    self.classificationResults.append(classes![index].className)
                }
                
                print(self.classificationResults)
                
                DispatchQueue.main.async {
                    self.cameraButton.isEnabled = true
                    SVProgressHUD.dismiss()
                    self.shareButton.isHidden = false
                }
                
                if self.classificationResults.contains("hotdog") {
                    DispatchQueue.main.sync {
                        self.navigationItem.title = "Hotdog!"
                        self.navigationController?.navigationBar.barTintColor = UIColor.green
                        self.navigationController?.navigationBar.isTranslucent = false
                        self.topBarImageView.image = UIImage(named: "hotdog")
                    }
                } else {
                    DispatchQueue.main.async {
                        self.navigationItem.title = "Not Hotdog!"
                        self.navigationController?.navigationBar.barTintColor = UIColor.red
                        self.navigationController?.navigationBar.isTranslucent = false
                        self.topBarImageView.image = UIImage(named: "not-hotdog")
                    }
                }
            }
            
        } else {
            print("There was an error picking the image.")
        }
        
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func shareTapped(_ sender: UIButton) {
        
        if SLComposeViewController.isAvailable(forServiceType:SLServiceTypeTwitter) {
            let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            vc?.setInitialText("My food is \(navigationItem.title!)")
            vc?.add(UIImage(named: "hotdogBackground"))
            present(vc!, animated: true, completion: nil)
        } else {
            self.navigationItem.title = "Please log into Twitter"
        }
    }
    
}

