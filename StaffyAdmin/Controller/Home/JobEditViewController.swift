//
//  JobEditViewController.swift
//  StaffyAdmin
//
//  Created by Aidan Miskella on 23/10/2019.
//  Copyright © 2019 Aidan Miskella. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import GrowingTextView

class JobEditViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

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
    
    var job: Job?
    
    var newTitle: String?
    var newDescription: String?
    var newJobCompanyName: String?
    var newAddress: String?
    var newStartDate: Timestamp?
    var newEndDate: Timestamp?
    var newStartTime: String?
    var newEndTime: String?
    var newExperience: String?
    var newPositions: String?
    var newPay: Float?
    
    var startDate: Date!
    var endDate: Date!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupUI()
        placeholders()
        pickUpArray()
        pickUpDate()
        pickUpTime()
        
        payLabel.text = String(format: "€%.1f0 per hour", paySlider.value)
        
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
    
    func placeholders() {
        
        titleTextField.placeholder = job?.title
        descriptionTextView.text = job?.description
        jobCompanyNameTextField.placeholder = job?.jobCompanyName
        startDateTextField.placeholder = Utilities.dateFormatterFullMonth((job?.startDate.dateValue())!)
        endDateTextField.placeholder = Utilities.dateFormatterFullMonth((job?.endDate.dateValue())!)
        startTimeTextField.placeholder = job?.startTime
        endTimeTextField.placeholder = job?.endTime
        experienceTextField.placeholder = job?.experince
        positionsTextField.placeholder = job?.positions
        paySlider.setValue(job!.pay, animated: true)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        if titleTextField.text != "" {
            
            newTitle = titleTextField.text
        } else {
            
            newTitle = job?.title
        }
        
        if descriptionTextView.text != nil {
            
            newDescription = descriptionTextView.text
        } else {
            
            errorLabel.text = "Please enter a job description."
        }
        
        if jobCompanyNameTextField.text != "" {
            
            newJobCompanyName = jobCompanyNameTextField.text
        } else {
            
            newJobCompanyName = job?.jobCompanyName
        }
        
        if startDateTextField.text != "" {
            
            newStartDate = Timestamp(date: startDate)
        } else {
            
            newStartDate = job?.startDate
        }
        
        if endDateTextField.text != "" {
            
            newEndDate = Timestamp(date: endDate)
        } else {
            
            newEndDate = job?.endDate
        }
        
        if startTimeTextField.text != "" {
            
            newStartTime = startTimeTextField.text
        } else {
            
            newStartTime = job?.startTime
        }
        
        if endTimeTextField.text != "" {
            
            newEndTime = endTimeTextField.text
        } else {
            
            newEndTime = job?.endTime
        }
        
        if experienceTextField.text != "" {
            
            newExperience = experienceTextField.text
        } else {
            
            newExperience = job?.experince
        }
        
        if positionsTextField.text != "" {
            
            newPositions = positionsTextField.text
        } else {
            
            newPositions = job?.positions
        }
        
        newPay = paySlider.value
        
        if (address1TextField.text != "" && address3TextField.text != "" && address4TextField.text != "") {
            
            if address2TextField.text == "" {
                
                newAddress = "\(address1TextField.text!), \(address3TextField.text!), \(address4TextField.text!)"
            } else {
                
                newAddress = "\(address1TextField.text!), \(address2TextField.text!), \(address3TextField.text!), \(address4TextField.text!)"
            }
            
            updateJob()
        } else {
            
            if (address1TextField.text == "" && address2TextField.text == "" && address3TextField.text == "" && address4TextField.text == "") {
                
                newAddress = job?.address
                updateJob()
            } else {
                
                errorLabel.alpha = 1
                errorLabel.text = "Please provide a full address."
            }
        }
    }
    
    func updateJob() {
        
        let ref = Firestore.firestore().collection(Constants.FirebaseDB.jobs_ref)
            .document(job!.jobId)
        
        ref.updateData([
            Constants.FirebaseDB.title: newTitle!,
            Constants.FirebaseDB.job_company_name: newJobCompanyName!,
            Constants.FirebaseDB.address: newAddress!,
            Constants.FirebaseDB.experience: newExperience!,
            Constants.FirebaseDB.positions: newPositions!,
            Constants.FirebaseDB.start_date: newStartDate!,
            Constants.FirebaseDB.end_date: newEndDate!,
            Constants.FirebaseDB.start_time: newStartTime!,
            Constants.FirebaseDB.end_time: newEndTime!,
            Constants.FirebaseDB.description: newDescription!,
            Constants.FirebaseDB.pay: newPay!
        ]) { (error) in
            if let error = error {
                
                debugPrint("Error adding document: \(error)")
            } else {
                
                self.navigationController?.popViewController(animated: true)
            }
        }
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
