//
//  NameEditViewController.swift
//  Staffy
//
//  Created by Aidan Miskella on 26/09/2019.
//  Copyright © 2019 Aidan Miskella. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class NameEditViewController: UIViewController {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    
    @IBOutlet weak var firstNameImage: UIImageView!
    
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var lastNameImage: UIImageView!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        placeholders()
    }
    
    func setupUI() {

        Utilities.styleTextField(textfield: firstNameTextField, font: .editProfileText, fontColor: .black, padding: 40.0)
        Utilities.styleTextField(textfield: lastNameTextField, font: .editProfileText, fontColor: .black, padding: 40.0)
        Utilities.styleFilledButton(button: saveButton, font: .largeLoginButton, fontColor: .white, backgroundColor: .lightBlue, cornerRadius: 10.0)
        Utilities.styleImage(imageView: firstNameImage, image: "userSmall", imageColor: .lightGray)
        Utilities.styleImage(imageView: lastNameImage, image: "userSmall", imageColor: .lightGray)
        
        errorLabel.alpha = 0
        Utilities.styleLabel(label: errorLabel, font: .loginError, fontColor: .red)
    }
    
    func placeholders() {
        
        guard let currentCompany = CompanyService.currentCompany else { return }
        
        firstNameTextField.placeholder = currentCompany.firstName
        lastNameTextField.placeholder = currentCompany.lastName
    }
    
    @IBAction func saveButtonDidPress(_ sender: Any) {
        
        guard let currentCompany = CompanyService.currentCompany else { return }
        
        var newFirstName = currentCompany.firstName
        var newLastName = currentCompany.lastName
        
        if firstNameTextField.text == "" || lastNameTextField.text == "" {
            
            errorLabel.alpha = 1
            errorLabel.text = "Please fill in all fields."
        } else {
        
            if firstNameTextField.text != "" {
                
                newFirstName = firstNameTextField.text!
            }
            
            if lastNameTextField.text != "" {
                
                newLastName = lastNameTextField.text!
            }
            
            let ref = Firestore.firestore().collection(Constants.FirebaseDB.company_ref)
                .document(Auth.auth().currentUser!.uid)
            
            ref.updateData([
                Constants.FirebaseDB.first_name: newFirstName,
                Constants.FirebaseDB.last_name: newLastName
            ]) { (error) in
                
                if let error = error {
                    
                    print("Error updating information \(error)")
                } else {
                    
                    currentCompany.firstName = newFirstName
                    currentCompany.lastName = newLastName
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}
