//
//  ManageStaffTableViewCell.swift
//  StaffyAdmin
//
//  Created by Aidan Miskella on 20/01/2020.
//  Copyright © 2020 Aidan Miskella. All rights reserved.
//

import UIKit
import Cosmos
import Firebase
import FirebaseAuth

protocol UserCellDelegate {
    
    func profileButtonTapped(user: User)
    
    func moreButtonTapped(user: User)
}

class ManageStaffCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var ratingView: CosmosView!
    
    @IBOutlet weak var moreImageButton: UIImageView!
    
    @IBOutlet weak var clockingStatusImageView: UIImageView!
    
    @IBOutlet weak var clockingStatusLabel: UILabel!
    
    private var user: User!
    private var delegate: UserCellDelegate?
    
    func setCell(user: User, userReport: Report, delegate: UserCellDelegate) {
        
        Utilities.styleLabel(label: nameLabel, font: .profileTableData, fontColor: .black)
        Utilities.styleLabel(label: clockingStatusLabel, font: .profileTableData, fontColor: .black)
        Utilities.styleImage(imageView: moreImageButton, image: "more", imageColor: .darkGray)
        Utilities.styleImage(imageView: clockingStatusImageView, image: "dot", imageColor: .darkGray)
        
        self.user = user
        self.delegate = delegate
        
        let profileImageTap = UITapGestureRecognizer(target: self, action: #selector(avatarImageViewPressed))
        avatarImageView.addGestureRecognizer(profileImageTap)
        
        moreImageButton.isUserInteractionEnabled = true
        
        let moreButtonTap = UITapGestureRecognizer(target: self, action: #selector(moreButtonPressed))
        moreImageButton.addGestureRecognizer(moreButtonTap)
        
        avatarImageView.layer.borderWidth = 1
        avatarImageView.layer.masksToBounds = false
        avatarImageView.layer.borderColor = UIColor.gray.cgColor
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
        avatarImageView.clipsToBounds = true
        avatarImageView.isUserInteractionEnabled = true
        
        clockingStatusImageView.layer.borderWidth = 1
        clockingStatusImageView.layer.masksToBounds = false
        clockingStatusImageView.layer.borderColor = UIColor.gray.cgColor
        clockingStatusImageView.layer.cornerRadius = clockingStatusImageView.frame.height / 2
        clockingStatusImageView.clipsToBounds = true
        
        ImageService.getImage(withURL: user.avatarURL!) { (image) in
            
            self.avatarImageView.image = image
        }
        
        nameLabel.text = "\(user.firstName) \(user.lastName)"
        clockingStatusLabel.text = userReport.reportStatus
        clockingStatusImageView.tintColor = getStatusColor(userReport: userReport)
        ratingView.rating = (user.reviewRating! / Double(user.jobsCompleted!))
    }
    
    func getStatusColor(userReport: Report) -> UIColor {
        
        var color: UIColor
        
        if userReport.reportOpen == true {
        
            if userReport.reportStatus == "Not clocked in" {
                
                color = .orange
            } else if userReport.reportStatus == "Clocked in" {
                
                color = .green
            } else if userReport.reportStatus == "Clocked out" {
                
                color = .red
            } else {
                
                color = .yellow
            }
        } else {
            
            clockingStatusLabel.text = Constants.Report.reportComlpete
            color = .lightBlue
        }
        
        return color
    }
    
    @objc func moreButtonPressed() {
        
        delegate?.moreButtonTapped(user: user)
    }
    
    @objc func avatarImageViewPressed() {
        
        delegate?.profileButtonTapped(user: user)
    }
}

