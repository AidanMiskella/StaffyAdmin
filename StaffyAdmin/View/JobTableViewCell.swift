//
//  JobTableViewCell.swift
//  StaffyAdmin
//
//  Created by Aidan Miskella on 23/11/2019.
//  Copyright © 2019 Aidan Miskella. All rights reserved.
//

import UIKit
import Cosmos
import FirebaseAuth

class JobTableViewCell: UITableViewCell {
    
    @IBOutlet weak var companyImageView: UIImageView!
    
    @IBOutlet weak var companyStarRating: CosmosView!
    
    @IBOutlet weak var jobTitleLabel: UILabel!
    
    @IBOutlet weak var jobCompanyNameLabel: UILabel!
    
    @IBOutlet weak var jobLocationLabel: UILabel!
    
    @IBOutlet weak var jobPostedTimeLabel: UILabel!
    
    func setCell(job: Job) {
        
        guard let currentCompany = CompanyService.currentCompany else { return }
        
        Utilities.styleLabel(label: jobTitleLabel, font: .jobCellTitle, fontColor: .black)
        Utilities.styleLabel(label: jobCompanyNameLabel, font: .jobCellInfo, fontColor: .black)
        Utilities.styleLabel(label: jobLocationLabel, font: .jobCellInfo, fontColor: .black)
        Utilities.styleLabel(label: jobPostedTimeLabel, font: .jobCellPoseted, fontColor: .black)

        companyStarRating.isUserInteractionEnabled = false

        companyImageView.layer.borderWidth = 1
        companyImageView.layer.masksToBounds = false
        companyImageView.layer.borderColor = UIColor.gray.cgColor
        companyImageView.layer.cornerRadius = companyImageView.frame.height / 2
        companyImageView.clipsToBounds = true

        ImageService.getImage(withURL: currentCompany.avatarURL!) { (image) in

            self.companyImageView.image = image
        }

        companyStarRating.rating = currentCompany.reviewRating!
        jobTitleLabel.text = job.title
        jobCompanyNameLabel.text = job.jobCompanyName
        jobLocationLabel.text = job.address
        jobPostedTimeLabel.text = Utilities.timeAgoSinceDate(job.postedDate.dateValue(), currentDate: Date(), numericDates: true)
    }
}

