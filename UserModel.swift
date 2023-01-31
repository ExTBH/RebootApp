//
//  UserModel.swift
//  RebootApp
//
//  Created by Natheer on 28/01/2023.
//

import Foundation


struct UserModel: Decodable {
    let active: Bool
    let avatar_url: String
    let created: Date
    let description: String
    let email: String
    let followers_count: UInt
    let following_count: UInt
    let full_name: String
    let id: UInt
    let is_admin: Bool
    let last_login: Date
    let location: String
    let login: String
    let website: String
}
