//
//  EmployerFeedbackViewController.swift
//  StaffyAdmin
//
//  Created by Aidan Miskella on 09/01/2020.
//  Copyright © 2020 Aidan Miskella. All rights reserved.
//

import UIKit
import GrowingTextView
import Cosmos
import SignaturePad
import SCLAlertView
import Firebase
import FirebaseAuth

class EmployerSignatureViewController: UIViewController, SignaturePadDelegate {
    
    @IBOutlet weak var signatureEmployerName: UITextField!
    
    @IBOutlet weak var signatureEmployerNameImage: UIImageView!
    
    @IBOutlet weak var signatureEmployerPosition: UITextField!
    
    @IBOutlet weak var signatureEmployerPositionImage: UIImageView!
    
    @IBOutlet weak var signaturePadView: SignaturePad!
    
    var job: Job!
    var currentReport: Report!
    var currentUser: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        connectOutlets()
        signaturePadView.delegate = self
    }
    
    func connectOutlets() {
            
        signaturePadView.isUserInteractionEnabled = false
        
        Utilities.styleTextField(textfield: signatureEmployerName, font: .editProfileText, fontColor: .black, padding: 40.0)
        Utilities.styleTextField(textfield: signatureEmployerPosition, font: .editProfileText, fontColor: .black, padding: 40.0)
        Utilities.styleImage(imageView: signatureEmployerNameImage, image: "userSmall", imageColor: .lightGray)
        Utilities.styleImage(imageView: signatureEmployerPositionImage, image: "userSmall", imageColor: .lightGray)
        
        signatureEmployerName.text = currentReport.signatureEmployerName
        signatureEmployerPosition.text = currentReport.signatureEmployerPosition
        
        signatureEmployerName.isEnabled = false
        signatureEmployerPosition.isEnabled = false
        ImageService.downloadImage(withURL: currentReport.signatureURL!) { (image) in
            
            self.signaturePadView.setSignature(_image: image!)
        }
    }
    
    func didStart() {
        
    }
    
    func didFinish() {
        
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        
        performSegue(withIdentifier: "goToEmployerFeedback", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToEmployerFeedback" {
            
            let vc = segue.destination as! EmployerFeedbackViewController
            vc.job = job
            vc.currentUser = currentUser
            vc.currentReport = currentReport
        }
    }
}
