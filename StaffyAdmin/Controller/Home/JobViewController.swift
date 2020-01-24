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
import MessageUI

class JobViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
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
    var currentJob = [Job]()
    
    private var jobs_ref: CollectionReference!
    private var jobsListener: ListenerRegistration!
    private var loginHandle: AuthStateDidChangeListenerHandle?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupElements()
        connectOutlets()
        
        jobs_ref = Firestore.firestore().collection(Constants.FirebaseDB.jobs_ref)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        loginHandle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            
            if user != nil {
                
                CompanyService.observeCompanyProfile(user!.uid, completion: { (user) in
                    
                    CompanyService.currentCompany = user
                    self.setListener()
                })
            } else {
                
                CompanyService.currentCompany = nil
                
                let storyboard = UIStoryboard(name: "Login", bundle: nil)
                let loginVC = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.loginViewController)
                self.present(loginVC, animated: true, completion: nil)
            }
        })
    }
    
    func setListener() {
        
        jobsListener = jobs_ref
            .whereField(Constants.FirebaseDB.job_id, isEqualTo: job!.jobId)
            .addSnapshotListener { (snapshot, error) in
                if let error = error {
                    
                    debugPrint("Error fetching docs: \(error)")
                } else {
                    
                    self.currentJob = Job.parseData(snapshot: snapshot)
                    self.job = self.currentJob[0]
                    self.updateUI()
                }
        }
    }
    
    func setupElements() {
        
        Utilities.styleLabel(label: companyNameLabel, font: .jobViewTitle, fontColor: .black)
        Utilities.styleLabel(label: jobTitleLabel, font: .editProfileText, fontColor: .black)
        Utilities.styleLabel(label: jobCompanyNameLabel, font: .editProfileText, fontColor: .black)
        Utilities.styleLabel(label: jobLocationLabel, font: .editProfileText, fontColor: .black)
        Utilities.styleLabel(label: experienceLabel, font: .editProfileText, fontColor: .black)
        Utilities.styleLabel(label: positionsLabel, font: .editProfileText, fontColor: .black)
        Utilities.styleLabel(label: datesLabel, font: .editProfileText, fontColor: .black)
        Utilities.styleLabel(label: timesLabel, font: .editProfileText, fontColor: .black)
        Utilities.styleLabel(label: payLabel, font: .editProfileText, fontColor: .black)
        Utilities.styleLabel(label: companyEmailLabel, font: .jobViewContactText, fontColor: .black)
        Utilities.styleLabel(label: companyPhoneLabel, font: .jobViewContactText, fontColor: .black)
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
        
        companyRating.rating = (currentCompany.reviewRating! / Double(currentCompany.jobsCompleted))
        
        ImageService.getImage(withURL: currentCompany.avatarURL!) { (image) in
            
            self.avatarImageView.image = image
        }
        
        updateUI()
    }
    
    func updateUI() {
        
        guard let positions = job?.positions,
            let startTime = job?.startTime,
            let endTime = job?.endTime,
            let pay = job?.pay else { return }
        
        companyNameLabel.text = job?.companyName
        jobTitleLabel.text = job?.title
        jobCompanyNameLabel.text = job?.jobCompanyName
        jobLocationLabel.text = job?.address
        experienceLabel.text = job?.experince
        positionsLabel.text = "\(positions) position(s)"
        datesLabel.text = "\(Utilities.dateFormatterShortMonth((job?.startDate.dateValue())!)) - \(Utilities.dateFormatterShortMonth((job?.endDate.dateValue())!))"
        timesLabel.text = "\(startTime) - \(endTime)"
        payLabel.text = String(format: "€%.1f0 per hour", pay)
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
        
        alert.addAction(manageAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func deleteJob(_ sender: Any) {
        
        Firestore.firestore().collection(Constants.FirebaseDB.jobs_ref).document(job!.jobId).delete { (error) in
            
            if let err = error {
                
                print(err.localizedDescription)
            } else {
                
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
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
