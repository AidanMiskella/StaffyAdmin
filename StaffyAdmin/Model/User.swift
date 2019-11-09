//
//  User.swift
//  Staffy
//
//  Created by Aidan Miskella on 19/09/2019.
//  Copyright © 2019 Aidan Miskella. All rights reserved.
//

import Foundation
import Firebase

class User {
    
    var userId: String
    var email: String
    var firstName: String
    var lastName: String
    var avatarURL: URL?
    var bio: String?
    var reviewRating: Double?
    var mobile: String?
    var documents: [Any]?
    var address: String?
    var gender: String?
    var dateOfBirth: String?
    var dateProfileCreated: String
    var jobsApplied: [String]?
    var jobsAccepted: [String]?
    
    init(userId: String,
         email: String,
         firstName: String,
         lastName: String,
         avatarURL: URL,
         bio: String?,
         reviewRating: Double?,
         mobile: String?,
         documents: [Any]?,
         address: String?,
         gender: String?,
         dateOfBirth: String?,
         dateProfileCreated: String,
         jobsApplied: [String]?,
         jobsAccepted: [String]?) {
        
        self.userId = userId
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.avatarURL = avatarURL
        self.bio = bio
        self.reviewRating = reviewRating
        self.mobile = mobile
        self.documents = documents
        self.address = address
        self.gender = gender
        self.dateOfBirth = dateOfBirth
        self.dateProfileCreated = dateProfileCreated
        self.jobsApplied = jobsApplied
        self.jobsAccepted = jobsAccepted
    }
    
    class func parseData(snapshot: QuerySnapshot?) -> [User] {
        
        var users = [User]()
        
        guard let snap = snapshot else { return users }
        for document in snap.documents {
            
            let data = document.data()
            if let userId = data[Constants.FirebaseDB.user_id] as? String,
            let email = data[Constants.FirebaseDB.email] as? String,
            let firstName = data[Constants.FirebaseDB.first_name] as? String,
            let lastName = data[Constants.FirebaseDB.last_name] as? String,
            let avatarURL = data[Constants.FirebaseDB.avatar_url] as? String,
            let bio = data[Constants.FirebaseDB.bio] as? String,
            let reviewRating = data[Constants.FirebaseDB.reviewRating] as? Double,
            let mobile = data[Constants.FirebaseDB.mobile] as? String,
            let documents = data[Constants.FirebaseDB.documents] as? [Any],
            let address = data[Constants.FirebaseDB.address] as? String,
            let gender = data[Constants.FirebaseDB.gender] as? String,
            let dateOfBirth = data[Constants.FirebaseDB.dob] as? String,
            let dateProfileCreated = data[Constants.FirebaseDB.date_created] as? String,
            let jobsApplied = data[Constants.FirebaseDB.jobs_applied] as? [String],
            let jobsAccepted = data[Constants.FirebaseDB.jobs_accepted] as? [String],
            let url = URL(string: avatarURL) {
            
                let newUser = User(userId: userId, email: email, firstName: firstName, lastName: lastName, avatarURL: url, bio: bio, reviewRating: reviewRating, mobile: mobile, documents: documents, address: address, gender: gender, dateOfBirth: dateOfBirth, dateProfileCreated: dateProfileCreated, jobsApplied: jobsApplied, jobsAccepted: jobsAccepted)
            
                users.append(newUser)
            }
        }
        
        return users
    }
}
