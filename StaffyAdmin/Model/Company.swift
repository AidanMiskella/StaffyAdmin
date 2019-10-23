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
    var reviewRating: Float?
    var mobile: String?
    var address: String?
    var dateProfileCreated: String
    var jobsCreated: [Any]?
    
    init(userId: String,
         companyName: String,
         firstName: String,
         lastName: String,
         avatarURL: URL,
         bio: String?,
         reviewRating: Float?,
         mobile: String?,
         address: String?,
         dateProfileCreated: String,
         jobsCreated: [Any]?) {
        
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
        self.jobsCreated = jobsCreated
    }
}

