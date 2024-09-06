//
//  TwitterUser.swift
//  Twitter-Clone
//
//  Created by Mehmet Ali ÇELEBİ on 6.09.2024.
//

import Foundation
import FirebaseAuth

struct TwitterUser: Codable {
    let id: String
    let displayName: String = ""
    let username: String = ""
    let followersCount: Int = 0
    let followingCount: Int = 0
    let createdOn: Date = Date()
    var bio: String = ""
    var avatarPath: String = ""
    var isUserOnboarded: Bool = false
    
    init(from user: User) {
        self.id = user.uid
    }
}
