//
//  LoginRequest.swift
//  On the Mapp
//
//  Created by Simon Wells on 2020/11/20.
//

import Foundation

struct Udacity: Codable {
    
        let username: String
        let password: String
        
        enum CodingKeys: String, CodingKey {
            case username
            case password
        }
    }
    
    struct LoginRequest: Codable {
        let udacity: Udacity 
        
        enum CodingKeys: String, CodingKey{
            case udacity
    }
}
