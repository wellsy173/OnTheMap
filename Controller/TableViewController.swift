//
//  TableViewController.swift
//  On the Mapp
//
//  Created by Simon Wells on 2020/11/20.
//

import Foundation
import UIKit

class TableViewController: UITableViewController {
    
    
    
    @IBOutlet var namesTableView: UITableView!
    
    var students = [StudentInformation]()
    var indicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {        indicator = UIActivityIndicatorView (style: UIActivityIndicatorView.Style.medium)
        self.view.addSubview(indicator)
        indicator.bringSubviewToFront(self.view)
        indicator.center = self.view.center
        super.viewDidLoad()
       

        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
        getStudentsList()
        
    }

    @IBAction func logOut(_ sender: Any) {
        UdacityClient.logout { (results, error)  in
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    }

    
    
    @IBAction func addLocation(_ sender: Any) {
        performSegue(withIdentifier: "addLocation1", sender: sender)
              }
    
    func backAction () -> Void {
        self.navigationController?.popViewController(animated: true)
    }

    func getStudentsList() {
        UdacityClient.getStudentsLocation() {students, error in
            StudentModel.student = students!
            self.tableView.reloadData()
       // UdacityClient.addStudentLocation(information: student) {  success, error in

    }
    }
            
    
    
    //Table View//
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentModel.student.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentTableViewCell", for: indexPath)
        let student = StudentModel.student[indexPath.row]
        cell.textLabel?.text = "\(student.firstName)" + " " + "\(student.lastName)"
        cell.detailTextLabel?.text = "\(student.mediaURL ?? "")"
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexpath: IndexPath) {
        let student = StudentModel.student[indexpath.row]
        openLink(student.mediaURL ?? "")
    }
    
        func showActivityIndicator() {
            indicator.isHidden = false
            indicator.startAnimating()
        }
        
        func hideActivityIndicator() {
            indicator.isHidden = true
            indicator.stopAnimating()
        }
    
    @IBAction func refresh(_ sender: UIBarButtonItem) {
       
    }
    /*
    func getStudentLists (completion: @escaping ([StudentInformation], Error?) -> Void ) {

        let session = URLSession.shared
        let url = UdacityClient.Endpoints.gettingStudentLocations.url
        let task = session.dataTask(with: url) { data, response, error in
            
            guard let data = data else {
                DispatchQueue.main.async {
                    
                    completion ([], error)
                }
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                print (String(data: data, encoding: .utf8) ?? "")
            let requestObject = try
                decoder.decode(StudentLocations.self, from: data)
            DispatchQueue.main.async {
                self.tableView.reloadData()
                StudentModel.student = requestObject.results
                completion(requestObject.results, nil)
            }
        } catch {
            
            DispatchQueue.main.async {
                completion([], error)
                print (error.localizedDescription)
            }
        }
    }
    task.resume()
            }
        */
}
