//
//  FoldingCell.swift
//  Staffy
//
//  Created by Aidan Miskella on 07/10/2019.
//  Copyright © 2019 Aidan Miskella. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import FoldingCell
import GrowingTextView

protocol JobDelegate {
    
    func manageButtonTapped(job: Job)
}

class DemoCell: FoldingCell {
    
    @IBOutlet weak var foreGroundView: RotatedView!
    
    @IBOutlet weak var foreGroundSideView: UIView!
    
    @IBOutlet weak var foreGroundDay: UILabel!
    
    @IBOutlet weak var foreGroundStartTime: UILabel!
    
    @IBOutlet weak var foreGroundStartDate: UILabel!
    
    @IBOutlet weak var foregroundPostedDate: UILabel!
    
    @IBOutlet weak var foreGroundTitle: UILabel!
    
    @IBOutlet weak var foreGroundJobCompanyName: UILabel!
    
    @IBOutlet weak var foreGroundAddress: UILabel!
    
    @IBOutlet weak var foreGroundExperience: UILabel!
    
    @IBOutlet weak var foreGroundPositions: UILabel!
    
    @IBOutlet weak var foreGroundJobCompanyNameImage: UIImageView!
    
    @IBOutlet weak var foreGroundJobLocationImage: UIImageView!
    
    @IBOutlet weak var foreGroundExperienceImage: UIImageView!
    
    @IBOutlet weak var foreGroundPositionsImage: UIImageView!
    
    @IBOutlet weak var containerViewTopBar: UIView!
    
    @IBOutlet weak var containerViewId: UILabel!
    
    @IBOutlet weak var containerViewJobTitle: UILabel!
    
    @IBOutlet weak var containerViewJobDescription: GrowingTextView!
    
    @IBOutlet weak var containerViewJobCompanyName: UILabel!
    
    @IBOutlet weak var containerViewAddress: UILabel!
    
    @IBOutlet weak var containerViewDates: UILabel!
    
    @IBOutlet weak var containerViewTimes: UILabel!
    
    @IBOutlet weak var containerViewPay: UILabel!
    
    @IBOutlet weak var containerViewCompanyName: UILabel!
    
    @IBOutlet weak var containerViewCompanyEmail: UILabel!
    
    @IBOutlet weak var containerViewCompanyPhone: UILabel!
    
    @IBOutlet weak var containerViewManageButton: UIButton!
    
    @IBOutlet weak var containerViewMenuImage: UIImageView!
    
    @IBOutlet weak var containerViewJobCompanyNameImage: UIImageView!
    
    @IBOutlet weak var containerViewJobLocationImage: UIImageView!
    
    @IBOutlet weak var containerViewDatesImage: UIImageView!
    
    @IBOutlet weak var containerViewTimesImage: UIImageView!
    
    @IBOutlet weak var containerViewPayImage: UIImageView!
    
    @IBOutlet weak var containerViewCompanyNameImage: UIImageView!
    
    @IBOutlet weak var containerViewCompanyEmailImage: UIImageView!
    
    @IBOutlet weak var containerViewCompanyMobileImage: UIImageView!
    
    private var job: Job!
    private var delegate: JobDelegate?
    
    override func awakeFromNib() {
        
        setupUI()
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true
        super.awakeFromNib()
    }
    
    override func animationDuration(_ itemIndex: NSInteger, type _: FoldingCell.AnimationType) -> TimeInterval {
        let durations = [0.26, 0.2, 0.2]
        return durations[itemIndex]
    }
    
    func setupUI() {
    
        Utilities.styleTextView(textView: containerViewJobDescription, font: .editProfilViewText, fontColor: .darkGray)
        Utilities.styleFilledButton(button: containerViewManageButton, font: .largeLoginButton, fontColor: .white, backgroundColor: .lightBlue, cornerRadius: 10.0)
        
        Utilities.styleImage(imageView: containerViewMenuImage, image: "menu", imageColor: .white)
        Utilities.styleImage(imageView: foreGroundJobCompanyNameImage, image: "company", imageColor: .gray)
        Utilities.styleImage(imageView: foreGroundJobLocationImage, image: "pointer", imageColor: .gray)
        Utilities.styleImage(imageView: foreGroundExperienceImage, image: "tick", imageColor: .gray)
        Utilities.styleImage(imageView: foreGroundPositionsImage, image: "users", imageColor: .gray)
        Utilities.styleImage(imageView: containerViewJobCompanyNameImage, image: "company", imageColor: .gray)
        Utilities.styleImage(imageView: containerViewJobLocationImage, image: "pointer", imageColor: .gray)
        Utilities.styleImage(imageView: containerViewDatesImage, image: "calendar", imageColor: .gray)
        Utilities.styleImage(imageView: containerViewTimesImage, image: "clock", imageColor: .gray)
        Utilities.styleImage(imageView: containerViewPayImage, image: "coin", imageColor: .gray)
        Utilities.styleImage(imageView: containerViewCompanyNameImage, image: "company", imageColor: .gray)
        Utilities.styleImage(imageView: containerViewCompanyEmailImage, image: "envelope", imageColor: .gray)
        Utilities.styleImage(imageView: containerViewCompanyMobileImage, image: "phone-handset", imageColor: .gray)
        
        foreGroundSideView.backgroundColor = .lightBlue
        containerViewTopBar.backgroundColor = .lightBlue
    }
    
    func configureCell(job: Job, delegate: JobDelegate) {
        
        self.job = job
        self.delegate = delegate
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(manageButtonTapped))
        containerViewManageButton.addGestureRecognizer(tap)
        
        CompanyService.observeUserProfile(job.companyId) { (company) in
            
            self.foreGroundDay.text = Utilities.dateFormatterWeekDay(job.startDate.dateValue())
            self.foreGroundStartTime.text = job.startTime
            self.foreGroundStartDate.text = Utilities.dateFormatterShortMonth(job.startDate.dateValue())
            self.foregroundPostedDate.text = Utilities.timeAgoSinceDate(job.postedDate.dateValue(), currentDate: Date(), numericDates: true)
            self.foreGroundTitle.text = job.title
            self.foreGroundJobCompanyName.text = job.jobCompanyName
            self.foreGroundAddress.text = job.address
            self.foreGroundExperience.text = job.experince
            self.foreGroundPositions.text = job.positions
            
            self.containerViewId.text = job.jobId
            self.containerViewJobTitle.text = job.title
            self.containerViewJobDescription.text = job.description
            self.containerViewJobCompanyName.text = job.jobCompanyName
            self.containerViewAddress.text = job.address
            self.containerViewDates.text = "\(Utilities.dateFormatterFullMonth(job.startDate.dateValue())) - \(Utilities.dateFormatterFullMonth(job.endDate.dateValue()))"
            self.containerViewTimes.text = "\(job.startTime) - \(job.endTime)"
            self.containerViewPay.text = String(format: "€%.1f0 per hour", job.pay)
            self.containerViewCompanyName.text = company?.companyName
            self.containerViewCompanyEmail.text = job.companyEmail
            self.containerViewCompanyPhone.text = company?.mobile
        }
    }
    
    @objc func manageButtonTapped() {
        
        delegate?.manageButtonTapped(job: job)
    }
}
