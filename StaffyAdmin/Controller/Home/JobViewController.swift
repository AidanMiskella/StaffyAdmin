//
//  JobViewController.swift
//  StaffyAdmin
//
//  Created by Aidan Miskella on 23/11/2019.
//  Copyright © 2019 Aidan Miskella. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SCLAlertView
import Cosmos
import GrowingTextView

class JobViewController: UIViewController {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var companyNameLabel: UILabel!
    
    @IBOutlet weak var companyRating: CosmosView!
    
    @IBOutlet weak var manageButton: UIButton!
    
    @IBOutlet weak var deleteJob: UIButton!
    
    @IBOutlet weak var jobTitleLabel: UILabel!
    
    @IBOutlet weak var jobCompanyNameLabel: UILabel!
    
    @IBOutlet weak var jobLocationLabel: UILabel!
    
    @IBOutlet weak var experienceLabel: UILabel!
    
    @IBOutlet weak var positionsLabel: UILabel!
    
    @IBOutlet weak var datesLabel: UILabel!
    
    @IBOutlet weak var timesLabel: UILabel!
    
    @IBOutlet weak var payLabel: UILabel!
    
    @IBOutlet weak var companyEmailLabel: UILabel!
    
    @IBOutlet weak var companyPhoneLabel: UILabel!
    
    @IBOutlet weak var jobDescriptionTextView: GrowingTextView!
    
    var job: Job?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupElements()
        connectOutlets()
    }
    
    func setupElements() {
        
        Utilities.styleLabel(label: companyNameLabel, font: .largeTitle, fontColor: .black)
        Utilities.styleLabel(label: jobTitleLabel, font: .editProfileText, fontColor: .black)
        Utilities.styleLabel(label: jobCompanyNameLabel, font: .editProfileText, fontColor: .black)
        Utilities.styleLabel(label: jobLocationLabel, font: .editProfileText, fontColor: .black)
        Utilities.styleLabel(label: experienceLabel, font: .editProfileText, fontColor: .black)
        Utilities.styleLabel(label: positionsLabel, font: .editProfileText, fontColor: .black)
        Utilities.styleLabel(label: datesLabel, font: .editProfileText, fontColor: .black)
        Utilities.styleLabel(label: timesLabel, font: .editProfileText, fontColor: .black)
        Utilities.styleLabel(label: payLabel, font: .editProfileText, fontColor: .black)
        Utilities.styleLabel(label: companyEmailLabel, font: .editProfileText, fontColor: .black)
        Utilities.styleLabel(label: companyPhoneLabel, font: .editProfileText, fontColor: .black)
        Utilities.styleFilledButton(button: manageButton, font: .largeLoginButton, fontColor: .white, backgroundColor: .lightBlue, cornerRadius: 10.0)
        Utilities.styleFilledButton(button: deleteJob, font: .largeLoginButton, fontColor: .white, backgroundColor: .red, cornerRadius: 10.0)
        Utilities.styleTextView(textView: jobDescriptionTextView, font: .editProfileText, fontColor: .black)
    }
    
    func connectOutlets() {
        
        guard let currentCompany = CompanyService.currentCompany else { return }
        
        companyRating.isUserInteractionEnabled = false
        
        avatarImageView.layer.borderWidth = 1
        avatarImageView.layer.masksToBounds = false
        avatarImageView.layer.borderColor = UIColor.gray.cgColor
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
        avatarImageView.clipsToBounds = true
        
        ImageService.getImage(withURL: currentCompany.avatarURL!) { (image) in
            
            self.avatarImageView.image = image
        }
        
        guard let positions = job?.positions,
            let startTime = job?.startTime,
            let endTime = job?.endTime,
            let pay = job?.pay else { return }
        
        companyNameLabel.text = job?.companyName
        jobTitleLabel.text = job?.title
        jobCompanyNameLabel.text = job?.jobCompanyName
        jobLocationLabel.text = job?.address
        experienceLabel.text = job?.experince
        positionsLabel.text = "\(positions) positions"
        datesLabel.text = "\(Utilities.dateFormatterShortMonth((job?.startDate.dateValue())!)) - \(Utilities.dateFormatterShortMonth((job?.endDate.dateValue())!))"
        timesLabel.text = "\(startTime) - \(endTime)"
        payLabel.text = "€\(pay)"
        companyEmailLabel.text = job?.companyEmail
        companyPhoneLabel.text = job?.companyPhone
        jobDescriptionTextView.text = job?.description
    }

    @IBAction func manageButtonPressed(_ sender: Any) {
            
        let alert = UIAlertController(title: "Job Options", message: "Manage your job by editing the details, managing the staff or delete the job", preferredStyle: .actionSheet)
        
        let manageAction = UIAlertAction(title: "Manage People", style: .default) { (action) in
            
            self.performSegue(withIdentifier: "goToPeople", sender: self)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(manageAction)
        
        if job?.status == "open" {
            
            let moveToInProgress = UIAlertAction(title: "Start Job", style: .default) { (action) in
                
                if Calendar.current.isDateInTomorrow(self.job!.startDate.dateValue()) || Calendar.current.isDateInToday(self.job!.startDate.dateValue()) {
                    
                    let ref = Firestore.firestore().collection(Constants.FirebaseDB.jobs_ref)
                        .document(self.job!.jobId)
                    
                    ref.updateData([
                        Constants.FirebaseDB.status: "inProgress"
                    ]) { (error) in
                        
                        if let error = error {
                            
                            print("Error updating information \(error)")
                        } else {
                            
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                } else {
                    
                    let alertView = SCLAlertView(appearance: Constants.AlertView.appearance)
                    
                    alertView.addButton("Continue", backgroundColor: .lightBlue, textColor: .white) {
                        
                        alertView.dismiss(animated: true)
                    }
                    
                    alertView.showError("Cannot move job", subTitle: "This job doesn't start until \(Utilities.dateFormatterFullMonth(self.job!.startDate.dateValue())). You can only move this job the day before or day of its start date", animationStyle: .rightToLeft)
                }
            }
            alert.addAction(moveToInProgress)
        } else if job?.status == "inProgress" {
            
            let moveToClosed = UIAlertAction(title: "Close Job", style: .default) { (action) in
                
                let ref = Firestore.firestore().collection(Constants.FirebaseDB.jobs_ref)
                    .document(self.job!.jobId)
                
                ref.updateData([
                    Constants.FirebaseDB.status: "closed"
                ]) { (error) in
                    
                    if let error = error {
                        
                        print("Error updating information \(error)")
                    } else {
                        
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            alert.addAction(moveToClosed)
        }
        
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToEditJob" {
            
            let vc = segue.destination as! JobEditViewController
            vc.job = job
        }
        
        if segue.identifier == "goToPeople" {
            
            let vc = segue.destination as! ManagePeopleViewController
            vc.job = job
        }
    }
}
