//
//  StudentsData.swift
//  On the Mapp
//
//  Created by Simon Wells on 2021/9/24.
//

import UIKit

class StudentsData: NSObject {
                
    var students = [StudentLocations]()
    //[StudentLocations] ()

    class func sharedInstance() -> StudentsData {
        struct Singleton {
            static var SharedInstance = StudentsData()
        }
        return Singleton.SharedInstance
        }
    }

