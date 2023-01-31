//
//  RBNetworking.swift
//  RebootApp
//
//  Created by Natheer on 28/01/2023.
//

import Foundation
import UIKit

fileprivate struct RBInternalUserModel: Decodable {
    let active: Bool
    let avatar_url: String
    let created: String
    let description: String
    let email: String
    let followers_count: UInt
    let following_count: UInt
    let full_name: String
    let id: UInt
    let is_admin: Bool
    let last_login: String
    let location: String
    let login: String
    let website: String
}

fileprivate struct RBInternalUserResponse: Decodable {
    let data: [RBInternalUserModel]
    let ok: Bool
}


struct RBNetworking {
    private static let baseURL = URL(string: "https://learn.reboot01.com/git/api/v1")!
    
    static let shared = RBNetworking()
    
    private init() {}
    
    func fetchUsers(_ completion: @escaping (Result<[UserModel], Error>) -> ()) {
        
        var request = URLRequest(url: RBNetworking.baseURL.appendingPathComponent("users/search", isDirectory: false))
        request.addValue("application/json", forHTTPHeaderField: "accept")
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard error == nil else {
                completion(.failure(error ?? URLError(.unknown)))
                return
            }
            
            guard let data = data else {
                completion(.failure(error ?? URLError(.cannotDecodeContentData)))
                return

            }
            
            switch processUserResponse(data: data) {
                case .failure(let error):
                    completion(.failure(error))
                
            case .success(let users):
                completion(.success(users))
            }

        }
        
        task.resume()
    }
    
    func fetchImage(_ urlString: String, completion: @escaping (Result<UIImage, Error>) -> ()){
        guard let url = URL(string: urlString) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            
            guard let image = UIImage(data: data!) else {
                completion(.failure(URLError(.cannotDecodeRawData)))
                return
            }
            completion(.success(image))
            
        }
        
        task.resume()
        
    }
    
    private func processUserResponse(data: Data) -> Result<[UserModel], Error> {
        do {
            let userResponse = try JSONDecoder().decode(RBInternalUserResponse.self, from: data)
            
            if userResponse.ok {
                return.success(internalUsersToPublic(users: userResponse.data))
            }
            return.failure(URLError.badServerResponse as! Error)
        } catch {
            return .failure(error)
        }
                
    }
    
    private func internalUsersToPublic(users: [RBInternalUserModel]) -> [UserModel] {
        return users.map {
            let date = ISO8601DateFormatter().date(from: $0.created) ?? Date(timeIntervalSince1970: 0)
            let lastLogin = ISO8601DateFormatter().date(from: $0.last_login) ?? Date(timeIntervalSince1970: 0)
            
            return UserModel(active: $0.active, avatar_url: $0.avatar_url, created: date, description: $0.description,
                             email: $0.email, followers_count: $0.followers_count, following_count: $0.following_count,
                             full_name: $0.full_name, id: $0.id, is_admin: $0.is_admin, last_login: lastLogin,
                             location: $0.location, login: $0.login, website: $0.website)
            
        }
        
        
    }
}
