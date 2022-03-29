//
//  UdacityClient.swift
//  On the Mapp
//
//  Created by Simon Wells on 2020/11/20.
//

import Foundation

class UdacityClient {
    
    struct Auth {
        static var sessionId: String?
        static var key = ""
        static var firstName = ""
        static var lastName = ""
        static var objectId = ""
        static var uniqueKey = ""
    }
    
    enum Endpoints {
        
        static let base = "https://onthemap-api.udacity.com/v1"
         
        case udacitySignUp
        case login
        case addStudentLocation
        case gettingStudentLocations
        case updateStudentLocation
        case getLoggedInUserProfile
        case logout
        
        var stringValue: String {
            switch self {
            case .udacitySignUp:
                return "https://auth.udacity.com/sign-up"
            case .login:
                return Endpoints.base + "/session"
            case .addStudentLocation:
                return Endpoints.base + "/StudentLocation" + Auth.objectId
            case .gettingStudentLocations:
                return Endpoints.base + "/StudentLocation?limit=100&order=-updatedAt"
            case .updateStudentLocation:
                return Endpoints.base + "/StudentLocation/8ZExGR5uX8"
            case .logout:
                return Endpoints.base + "/session"
            case .getLoggedInUserProfile:
                return Endpoints.base + "/users/" + Auth.key
            }
        }
        var url: URL {
        return URL(string: stringValue)!
        }
    }

    
    class func login (username: String, password: String, completion: @escaping(Bool, Error?) -> Void) {
        let body = LoginRequest(udacity: Udacity(username: username, password: password))
        RequestHelpers.taskForPOSTRequest(url: UdacityClient.Endpoints.login.url, apiType: "Udacity", responseType: LoginResponse.self, body: body, httpMethod: "POST") { (response, error) in
            if let response = response {
                Auth.sessionId = response.session.id
                Auth.key = response.account.key
                getLoggedInUserProfile(completion: { (success, error) in
                    if success {
                        print ("Logged in user's profile.")
                        
                    }
            })
            completion(true, nil)
            } else {
                completion (false, nil)
            }
        }
    
    }
        
    
    class func getStudentsLocation(completion: @escaping ([StudentInformation]?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: Endpoints.gettingStudentLocations.url) { data, response, error in

            guard let data = data else {
                DispatchQueue.main.async {
                    completion (nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            
            do{
                let response = try
                    decoder.decode(StudentLocation.self, from: data)
                DispatchQueue.main.async {
                    completion(response.results, nil)
                }
            } catch {
            
                DispatchQueue.main.async {
                    completion (nil, error)
                }
            }
        }
        task.resume()
    }
    

    class func addStudentLocation(information: StudentInformation, completion: @escaping (Bool, Error?) -> Void) {
        var request = URLRequest(url: Endpoints.addStudentLocation.url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let requestObject = try! JSONEncoder().encode(information)
        request.httpBody = requestObject
        let session = URLSession.shared
        let task = session.dataTask(with: request) {data, response, error in
            if error != nil {
                completion (false, error)
                return
            }
            print (String(data: data!, encoding: .utf8)!)
            completion(true, nil)
            
        }
        task.resume()
}
    
    class func updateStudentLocation(information: StudentInformation, completion: @escaping (Bool, Error?) -> Void) {
            var request = URLRequest(url: Endpoints.gettingStudentLocations.url)
            request.httpMethod = "PUT"
            request.addValue("application/json", forHTTPHeaderField: "accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let requestObject = try! JSONEncoder().encode(information)
            request.httpBody = requestObject
            let session = URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
                if error != nil {
                    completion (false, error)
                    return
                }
                print (String(data: data!, encoding: .utf8)!)
        }
            task.resume()
    }
    
    class func logout(completion: @escaping (Bool, Error?) -> Void) {
        var request = URLRequest(url: Endpoints.logout.url)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
            completion (false, error) 
            return
    }
        let range = 5..<data!.count
            let newData = data?.subdata(in: range)
            print (String(data: newData!, encoding: .utf8)!)
            Auth.sessionId = ""
            completion(false, error)
        }
        
        task.resume()
            
        
}
    
    class func getLoggedInUserProfile(completion: @escaping (Bool, Error?) -> Void) {
        RequestHelpers.taskForGetRequest(url: Endpoints.getLoggedInUserProfile.url, apiType: "Udacity", responseType: UserProfile.self) { (response, error ) in
            if let response = response {
            print ("First Name : \(response.firstName) && Last Name : \(response.lastName) && Full Name: \(response.nickname)")
                Auth.firstName = response.firstName
                Auth.lastName = response.lastName
                completion (true, nil)
                
            } else {
                print ("Failed to get user's profile")
                completion (false, error)
            }
        
    }
    }
    
    class StudentsData: NSObject {
        
        var students = [StudentInformation]()
        
        class func sharedInstance() -> StudentsData {
            struct Singleton {
                static var sharedInstance = StudentsData()
            }
            return Singleton.sharedInstance
        }
    }
}
