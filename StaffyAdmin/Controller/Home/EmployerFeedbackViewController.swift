//
//  EmployerFeedbackViewController.swift
//  StaffyAdmin
//
//  Created by Aidan Miskella on 12/01/2020.
//  Copyright © 2020 Aidan Miskella. All rights reserved.
//

import UIKit
import Cosmos
import GrowingTextView
import Firebase
import FirebaseAuth

class EmployerFeedbackViewController: UIViewController {

    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var starRating: CosmosView!
    
    @IBOutlet weak var commentsTextView: GrowingTextView!
    
    var job: Job!
    var currentReport: Report!
    var currentUser: User!
    var employerStarRating: Double!
    var employerComment: String!
    var signature: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupElements()
        connectOutlets()
    }
    
    func setupElements() {
        
        Utilities.styleTextView(textView: commentsTextView, font: .editProfileText, fontColor: .black)
    }
    
    func connectOutlets() {
        
        if currentReport.employerStarRating != 0.0 {
            
            starRating.isUserInteractionEnabled = false
            commentsTextView.isEditable = false
            starRating.rating = currentReport.employerStarRating
            commentsTextView.text = currentReport.employerComment
            navigationItem.rightBarButtonItem = nil
        }
        
        avatarImageView.layer.borderWidth = 1
        avatarImageView.layer.masksToBounds = false
        avatarImageView.layer.borderColor = UIColor.gray.cgColor
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
        avatarImageView.clipsToBounds = true
        
        CompanyService.observeUserProfile(currentUser.userId    ) { (user) in
            
            ImageService.getImage(withURL: user!.avatarURL!) { (image) in
                
                self.avatarImageView.image = image
            }
        }
    }
    
    @IBAction func submitPressed(_ sender: Any) {

        let batch = Firestore.firestore().batch()
        
        let user_ref = Firestore.firestore().collection(Constants.FirebaseDB.user_ref).document(currentUser.userId)
        let report_ref =  Firestore.firestore().collection(Constants.FirebaseDB.jobs_ref).document(self.job!.jobId).collection(Constants.FirebaseDB.reports_ref).document(self.currentReport.reportId)
        
        batch.updateData([Constants.FirebaseDB.reviewRating: self.starRating.rating + currentUser.reviewRating!,
                          Constants.FirebaseDB.jobs_completed: currentUser.jobsCompleted! + 1], forDocument: user_ref)
        
        batch.updateData([Constants.FirebaseDB.employer_star_rating: self.starRating.rating,
                          Constants.FirebaseDB.employer_comment: self.commentsTextView.text!,
                          Constants.FirebaseDB.report_open: false], forDocument: report_ref)
        
        batch.commit() { err in
            
            if let err = err {
                
                print("Error writing batch \(err)")
            } else {
                
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
}
