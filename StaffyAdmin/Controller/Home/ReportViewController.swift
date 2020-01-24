//
//  ReportViewController.swift
//  StaffyAdmin
//
//  Created by Aidan Miskella on 09/01/2020.
//  Copyright © 2020 Aidan Miskella. All rights reserved.
//

import UIKit
import SCLAlertView
import Firebase
import FirebaseAuth
import FirebaseFirestore

class ReportViewController: UIViewController {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var statusImageView: UIImageView!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var currentTime: UILabel!
    
    @IBOutlet weak var clockingButton: UIButton!
    
    @IBOutlet weak var breakButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    private var timer = Timer()
    
    var job: Job!
    var currentUser: User!
    
    var currentReport: Report!
    var reports = [Report]()
    var clockingMessages = [String]()
    
    private var report_ref: CollectionReference!
    private var clockingsListener: ListenerRegistration!
    private var loginHandle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        connectOutlets()
        setupElements()
        getCurrentTime()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        report_ref = Firestore.firestore().collection(Constants.FirebaseDB.jobs_ref).document(job!.jobId).collection(Constants.FirebaseDB.reports_ref)
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
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if clockingsListener != nil {
            
            clockingsListener.remove()
        }
    }
    
    func setupElements() {
        
        Utilities.styleLabel(label: nameLabel, font: .reportNameTitle, fontColor: .black)
        Utilities.styleLabel(label: currentTime, font: .largeTime, fontColor: .black)
        Utilities.styleLabel(label: statusLabel, font: .reportClockingStatus, fontColor: .black)
        Utilities.styleFilledButton(button: clockingButton, font: .largeLoginButton, fontColor: .white, backgroundColor: .lightBlue, cornerRadius: 10.0)
        Utilities.styleFilledButton(button: breakButton, font: .largeLoginButton, fontColor: .white, backgroundColor: .lightBlue, cornerRadius: 10.0)
    }
    
    func connectOutlets() {
        
        avatarImageView.layer.borderWidth = 1
        avatarImageView.layer.masksToBounds = false
        avatarImageView.layer.borderColor = UIColor.gray.cgColor
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
        avatarImageView.clipsToBounds = true
        
        clockingButton.isEnabled = false
        breakButton.isEnabled = false
        clockingButton.tintColor = .gray
        breakButton.tintColor = .gray
        
        CompanyService.observeUserProfile(currentUser.userId, completion: { (user) in
            
            ImageService.getImage(withURL: user!.avatarURL!) { (image) in
                
                self.avatarImageView.image = image
            }
        })
        
        nameLabel.text = "\(currentUser.firstName) \( currentUser.lastName)"
    }
    
    func setListener() {
        
        clockingsListener = report_ref
            .whereField(Constants.FirebaseDB.user_id, isEqualTo: currentUser.userId)
            .addSnapshotListener({ (snapshot, error) in
                
                if let error = error {
                    
                    debugPrint("Error fetching docs: \(error)")
                } else {
                    
                    self.reports.removeAll()
                    self.reports = Report.parseData(snapshot: snapshot)
                    self.currentReport = self.reports[0]
                    self.statusLabel.text = self.self.currentReport.reportStatus
                    self.clockingMessages = self.currentReport.clockingMessages.reversed()
                    self.tableView.reloadData()
                }
            })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToEmployerFeedback" {
            
            let vc = segue.destination as! EmployerSignatureViewController
            vc.job = job
            vc.currentReport = currentReport
            vc.currentUser = currentUser
        }
    }
    
    @IBAction func nextButton(_ sender: Any) {
        
        if currentReport.reportOpen == false {
            
            performSegue(withIdentifier: "goToEmployerFeedback", sender: self)
        } else {
            
            let alertView = SCLAlertView(appearance: Constants.AlertView.appearance)
            
            alertView.addButton("Continue", backgroundColor: .lightBlue, textColor: .white) {
                
                alertView.dismiss(animated: true)
            }
            
            alertView.showWarning("Job not complete", subTitle: "You cannot fully review an employee report until it is completed by providing a employer signature and employee feedback.", animationStyle: .rightToLeft)
        }
    }
    
    private func getCurrentTime() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:#selector(self.currentTimer), userInfo: nil, repeats: true)
    }
    
    @objc func currentTimer() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        currentTime.text = formatter.string(from: Date())
    }
}

extension ReportViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return clockingMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let clocking = clockingMessages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "reportCell") as! ReportTableViewCell
        
        cell.setCell(currentReport: currentReport, clocking: clocking)
        
        return cell
    }
}
