//
//  Company.swift
//  StaffyAdmin
//
//  Created by Aidan Miskella on 14/10/2019.
//  Copyright © 2019 Aidan Miskella. All rights reserved.
//

import Foundation

class Company {
    
    var userId: String
    var companyName: String
    var firstName: String
    var lastName: String
    var avatarURL: URL?
    var bio: String?
    var reviewRating: Double?
    var mobile: String?
    var address: String?
    var dateProfileCreated: String
    var jobsCompleted: Int
    
    init(userId: String,
         companyName: String,
         firstName: String,
         lastName: String,
         avatarURL: URL,
         bio: String?,
         reviewRating: Double?,
         mobile: String?,
         address: String?,
         dateProfileCreated: String,
         jobsCompleted: Int) {
        
        self.userId = userId
        self.companyName = companyName
        self.firstName = firstName
        self.lastName = lastName
        self.avatarURL = avatarURL
        self.bio = bio
        self.reviewRating = reviewRating
        self.mobile = mobile
        self.address = address
        self.dateProfileCreated = dateProfileCreated
        self.jobsCompleted = jobsCompleted
    }
}

