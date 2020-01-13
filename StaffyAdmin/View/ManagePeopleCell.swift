//
//  ManagePeopleCell.swift
//  StaffyAdmin
//
//  Created by Aidan Miskella on 04/11/2019.
//  Copyright © 2019 Aidan Miskella. All rights reserved.
//

import UIKit
import Cosmos

protocol UserCellDelegate {
    
    func profileButtonTapped(user: User)
    
    func moreButtonTapped(user: User)
}

class ManagePeopleCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var ratingView: CosmosView!

    @IBOutlet weak var moreImageButton: UIImageView!
    
    private var user: User!
    private var delegate: UserCellDelegate?
    
    func setCell(user: User, delegate: UserCellDelegate) {
        
        Utilities.styleLabel(label: nameLabel, font: .profileTableData, fontColor: .black)
        Utilities.styleImage(imageView: moreImageButton, image: "more", imageColor: .darkGray)
        
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
        
        ImageService.getImage(withURL: user.avatarURL!) { (image) in
            
            self.avatarImageView.image = image
        }
        
        nameLabel.text = "\(user.firstName) \(user.lastName)"
        ratingView.rating = user.reviewRating!
    }
    
    func removeOptionsButton(job: Job, selectedSegment: String) {
        
        if job.status == "inProgress" || job.status == "closed" {
            
            if selectedSegment == "APPLICANTS"{
                
                moreImageButton.isHidden = true
            } else {
                
                moreImageButton.isHidden = false
            }
        }
    }
    
    @objc func moreButtonPressed() {
        
        delegate?.moreButtonTapped(user: user)
    }
    
    @objc func avatarImageViewPressed() {
        
        delegate?.profileButtonTapped(user: user)
    }
}
