//
//  AddJobViewController.swift
//  StaffyAdmin
//
//  Created by Aidan Miskella on 15/10/2019.
//  Copyright © 2019 Aidan Miskella. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import GrowingTextView

class AddJobViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var descriptionTextView: GrowingTextView!
    
    @IBOutlet weak var jobCompanyNameTextField: UITextField!
    
    @IBOutlet weak var address1TextField: UITextField!
    
    @IBOutlet weak var address2TextField: UITextField!
    
    @IBOutlet weak var address3TextField: UITextField!
    
    @IBOutlet weak var address4TextField: UITextField!
    
    @IBOutlet weak var experienceTextField: UITextField!
    
    @IBOutlet weak var positionsTextField: UITextField!
    
    @IBOutlet weak var startDateTextField: UITextField!
    
    @IBOutlet weak var endDateTextField: UITextField!
    
    @IBOutlet weak var startTimeTextField: UITextField!
    
    @IBOutlet weak var endTimeTextField: UITextField!
    
    @IBOutlet weak var paySlider: UISlider!
    
    @IBOutlet weak var payLabel: UILabel!
    
    @IBOutlet weak var titleImage: UIImageView!
    
    @IBOutlet weak var jobCompanyNameImage: UIImageView!
    
    @IBOutlet weak var address1Image: UIImageView!
    
    @IBOutlet weak var address2Image: UIImageView!
    
    @IBOutlet weak var address3Image: UIImageView!
    
    @IBOutlet weak var address4Image: UIImageView!
    
    @IBOutlet weak var startDateImage: UIImageView!
    
    @IBOutlet weak var endDateImage: UIImageView!
    
    @IBOutlet weak var startTimeImage: UIImageView!
    
    @IBOutlet weak var endTimeImage: UIImageView!
    
    @IBOutlet weak var positionImage: UIImageView!
    
    @IBOutlet weak var experienceImage: UIImageView!
 
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var saveButton: UIButton!
    
    var pickerView: UIPickerView!
    var datePickerView: UIDatePicker!
    var timePickerView: UIDatePicker!
    
    var startDate: Date!
    var endDate: Date!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        pickUpArray()
        pickUpDate()
        pickUpTime()
        
        payLabel.text = "€10.00 per hour"
        
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        
        address4TextField.delegate = self
        experienceTextField.delegate = self
        positionsTextField.delegate = self
        
        startDateTextField.delegate = self
        endDateTextField.delegate = self
        startTimeTextField.delegate = self
        endTimeTextField.delegate = self
    }
    
    func setupUI() {
        
        errorLabel.alpha = 0
        
        descriptionTextView.text = "Job Description"

        Utilities.styleTextField(textfield: titleTextField, font: .editProfileText, fontColor: .black, padding: 40.0)
        Utilities.styleTextView(textView: descriptionTextView, font: .editProfileText, fontColor: .darkGray)
        Utilities.styleTextField(textfield: jobCompanyNameTextField, font: .editProfileText, fontColor: .black, padding: 40.0)
        Utilities.styleTextField(textfield: address1TextField, font: .editProfileText, fontColor: .black, padding: 40.0)
        Utilities.styleTextField(textfield: address2TextField, font: .editProfileText, fontColor: .black, padding: 40.0)
        Utilities.styleTextField(textfield: address3TextField, font: .editProfileText, fontColor: .black, padding: 40.0)
        Utilities.styleTextField(textfield: address4TextField, font: .editProfileText, fontColor: .black, padding: 40.0)
        Utilities.styleTextField(textfield: startDateTextField, font: .editProfileText, fontColor: .black, padding: 40.0)
        Utilities.styleTextField(textfield: startTimeTextField, font: .editProfileText, fontColor: .black, padding: 40.0)
        Utilities.styleTextField(textfield: endDateTextField, font: .editProfileText, fontColor: .black, padding: 40.0)
        Utilities.styleTextField(textfield: endTimeTextField, font: .editProfileText, fontColor: .black, padding: 40.0)
        Utilities.styleTextField(textfield: experienceTextField, font: .editProfileText, fontColor: .black, padding: 40.0)
        Utilities.styleTextField(textfield: positionsTextField, font: .editProfileText, fontColor: .black, padding: 40.0)
        Utilities.styleLabel(label: payLabel, font: .editProfileText, fontColor: .black)
        
        Utilities.styleImage(imageView: titleImage, image: "title", imageColor: .lightGray)
        Utilities.styleImage(imageView: jobCompanyNameImage, image: "company", imageColor: .lightGray)
        Utilities.styleImage(imageView: address1Image, image: "pointer", imageColor: .lightGray)
        Utilities.styleImage(imageView: address2Image, image: "pointer", imageColor: .lightGray)
        Utilities.styleImage(imageView: address3Image, image: "pointer", imageColor: .lightGray)
        Utilities.styleImage(imageView: address4Image, image: "pointer", imageColor: .lightGray)
        Utilities.styleImage(imageView: startDateImage, image: "calendar", imageColor: .lightGray)
        Utilities.styleImage(imageView: endDateImage, image: "calendar", imageColor: .lightGray)
        Utilities.styleImage(imageView: startTimeImage, image: "clock", imageColor: .lightGray)
        Utilities.styleImage(imageView: endTimeImage, image: "clock", imageColor: .lightGray)
        Utilities.styleImage(imageView: experienceImage, image: "user", imageColor: .lightGray)
        Utilities.styleImage(imageView: positionImage, image: "users", imageColor: .lightGray)
        
        Utilities.styleLabel(label: errorLabel, font: .loginError, fontColor: .red)
        Utilities.styleFilledButton(button: saveButton, font: .largeLoginButton, fontColor: .white, backgroundColor: .lightBlue, cornerRadius: 10.0)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        let error = validateFields()
        
        if error != nil {
            
            errorLabel.alpha = 1
            errorLabel.text = error
        } else {
            
            guard let currentCompany = CompanyService.currentCompany else { return }
            
            Firestore.firestore().collection(Constants.FirebaseDB.jobs_ref).addDocument(data: [
                
                Constants.FirebaseDB.jobs_ref: currentCompany.userId,
                Constants.FirebaseDB.title: titleTextField.text!,
                Constants.FirebaseDB.job_company_name: jobCompanyNameTextField.text!,
                Constants.FirebaseDB.company_name: currentCompany.companyName,
                Constants.FirebaseDB.address:getAddress(),
                Constants.FirebaseDB.experience: experienceTextField.text!,
                Constants.FirebaseDB.positions: positionsTextField.text!,
                Constants.FirebaseDB.posted_date: Date(),
                Constants.FirebaseDB.start_date: startDate!,
                Constants.FirebaseDB.end_date: endDateTextField.text!,
                Constants.FirebaseDB.start_time: startTimeTextField.text!,
                Constants.FirebaseDB.end_time: endTimeTextField.text!,
                Constants.FirebaseDB.description: descriptionTextView.text!,
                Constants.FirebaseDB.pay: paySlider.value,
                Constants.FirebaseDB.company_email: Auth.auth().currentUser?.email ?? "",
                Constants.FirebaseDB.company_phone: currentCompany.mobile!
                
            ]) { (error) in
                if let error = error {
                    
                    debugPrint("Error adding document: \(error)")
                } else {
                    
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    func validateFields() -> String? {
        
        let error: String
        
        if titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            jobCompanyNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            descriptionTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            address1TextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            address3TextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            address4TextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            startDateTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            startTimeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            endDateTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            endTimeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            positionsTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            experienceTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            error = "Please fill in all fields."
            return error
        }
        
        return nil
    }
    
    func getAddress() -> String {
        
        var fullAddress: String
        
        if address2TextField.text == "" {
            
            fullAddress = "\(address1TextField.text!), \(address3TextField.text!), \(address4TextField.text!)"
        } else {
            
            fullAddress = "\(address1TextField.text!), \(address2TextField.text!), \(address3TextField.text!), \(address4TextField.text!)"
        }
        
        return fullAddress
    }

    @IBAction func sliderValueChanged(_ sender: UISlider) {
        
        let currentValue = Float(sender.value)
        
        DispatchQueue.main.async {
            
            self.payLabel.text = String(format: "€%.1f0 per hour", currentValue)
        }
    }
    
    func pickUpArray() {
        
        self.pickerView = UIPickerView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 300))
        self.pickerView.backgroundColor = UIColor.white
        
        address4TextField.inputView = self.pickerView
        experienceTextField.inputView = self.pickerView
        positionsTextField.inputView = self.pickerView
        
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = .lightBlue
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        address4TextField.inputAccessoryView = toolBar
        experienceTextField.inputAccessoryView = toolBar
        positionsTextField.inputAccessoryView = toolBar
    }
    
    func pickUpDate() {
        
        self.datePickerView = UIDatePicker(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 300))
        self.datePickerView.backgroundColor = UIColor.white
        self.datePickerView.datePickerMode = .date
        
        startDateTextField.inputView = self.datePickerView
        endDateTextField.inputView = self.datePickerView
        
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = .lightBlue
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        startDateTextField.inputAccessoryView = toolBar
        endDateTextField.inputAccessoryView = toolBar
    }
    
    func pickUpTime() {

        self.timePickerView = UIDatePicker(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 300))
        self.timePickerView.datePickerMode = .time
        self.timePickerView.backgroundColor = UIColor.white

        self.startTimeTextField.inputView = self.timePickerView
        self.endTimeTextField.inputView = self.timePickerView

        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = .lightBlue
        toolBar.sizeToFit()

        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true

        startTimeTextField.inputAccessoryView = toolBar
        endTimeTextField.inputAccessoryView = toolBar
    }
    
    @objc func doneClick() {
        
        if address4TextField.isFirstResponder{
            
            let itemselected = Constants.Arrays.countyArray[self.pickerView.selectedRow(inComponent: 0)]
            address4TextField.text = itemselected
            address4TextField.resignFirstResponder()
        }
        
        if experienceTextField.isFirstResponder{
            
            let itemselected = Constants.Arrays.experienceArray[self.pickerView.selectedRow(inComponent: 0)]
            experienceTextField.text = itemselected
            experienceTextField.resignFirstResponder()
        }
        
        if positionsTextField.isFirstResponder{
            
            let itemselected = Constants.Arrays.positionsArray[self.pickerView.selectedRow(inComponent: 0)]
            positionsTextField.text = itemselected
            positionsTextField.resignFirstResponder()
        }
        
        if startDateTextField.isFirstResponder{
            
            let formatter = DateFormatter()
            startDate = datePickerView.date
            formatter.dateFormat = "dd MMMM yyyy"
            startDateTextField.text = formatter.string(from: startDate)
            startDateTextField.resignFirstResponder()
        }
        
        if endDateTextField.isFirstResponder{
            
            let formatter = DateFormatter()
            endDate = datePickerView.date
            formatter.dateFormat = "dd MMMM yyyy"
            endDateTextField.text = formatter.string(from: datePickerView.date)
            endDateTextField.resignFirstResponder()
        }
        
        if startTimeTextField.isFirstResponder{
            
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm a"
            startTimeTextField.text = formatter.string(from: timePickerView.date)
            startTimeTextField.resignFirstResponder()
        }
        
        if endTimeTextField.isFirstResponder{
            
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm a"
            endTimeTextField.text = formatter.string(from: timePickerView.date)
            endTimeTextField.resignFirstResponder()
        }
    }
    
    @objc func cancelClick() {
        
        if address4TextField.isFirstResponder{
            
            address4TextField.resignFirstResponder()
        }
        
        if experienceTextField.isFirstResponder{
            
            experienceTextField.resignFirstResponder()
        }
        
        if positionsTextField.isFirstResponder{
            
            positionsTextField.resignFirstResponder()
        }
        
        if startDateTextField.isFirstResponder{
            
            startDateTextField.resignFirstResponder()
        }
        
        if endDateTextField.isFirstResponder{
            
            endDateTextField.resignFirstResponder()
        }
        
        if startTimeTextField.isFirstResponder{
            
            startTimeTextField.resignFirstResponder()
        }
        
        if endTimeTextField.isFirstResponder{
            
            endTimeTextField.resignFirstResponder()
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        self.pickerView?.reloadAllComponents()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        return false
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if address4TextField.isFirstResponder{
            
            return Constants.Arrays.countyArray.count
        }
        
        if experienceTextField.isFirstResponder{
            
            return Constants.Arrays.experienceArray.count
        }
        
        if positionsTextField.isFirstResponder{
            
            return Constants.Arrays.positionsArray.count
        }
        
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if address4TextField.isFirstResponder{
            
            return Constants.Arrays.countyArray[row]
        }
        
        if experienceTextField.isFirstResponder{
            
            return Constants.Arrays.experienceArray[row]
        }
        
        if positionsTextField.isFirstResponder{
            
            return Constants.Arrays.positionsArray[row]
        }
        
        return nil
    }
}
