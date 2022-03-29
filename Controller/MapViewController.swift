//
//  MapViewController.swift
//  On the Mapp
//
//  Created by Simon Wells on 2020/11/20.
//

import Foundation
import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    

    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet weak var pinDrop: UIBarButtonItem!
    @IBOutlet weak var refresh: UIBarButtonItem!
    @IBOutlet weak var logOut: UIBarButtonItem!
    
    
    override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(animated)
            self.refresh
    }

   /* TMDBClient.getWatchlist() { movies, error in*/
    
    var locations = [StudentInformation]()
    var studentInformation: StudentInformation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateRequest()
        UdacityClient.getStudentsLocation() {locations, error in
        var annotations = [MKPointAnnotation]()
        
        for loc in locations! {
            
            let lat = CLLocationDegrees(loc.latitude!)
            let long = CLLocationDegrees(loc.longitude!)
            
            let coordinate = CLLocationCoordinate2D (latitude: lat, longitude: long)
            
            let first = loc.firstName
            let last = loc.lastName
            let mediaURL = loc.mediaURL
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            annotations.append(annotation)
        }
                
        self.mapView.addAnnotations(annotations)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(true)
    }

    func updateRequest() {
        if !mapView.annotations.isEmpty {
            mapView.removeAnnotations(mapView.annotations)
        }
    }
    
    /*
   UdacityClient.updateStudentLocation (string: String, bool: Bool);, completion: (Bool, Error?) in {
            self.locations = results as [StudentInformation]
            self.setup()
            
            }
    */
  
    
  
    @IBAction func refresh(_ sender: Any) {
        func getStudentPins() {
      }
    }
                                            
    @IBAction func logOut(_ sender: Any) {
        UdacityClient.logout { (results, error)  in
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    }
    
    
    @IBAction func addLocation(_ sender: Any) {
    performSegue(withIdentifier: "addLocation", sender: sender)
          }
    

     
    func getStudentPins (completion: @escaping ([StudentInformation], Error?) -> Void ) {
        
    
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
    
    
    //Map view delegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .blue
            pinView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
        }
    
    func mapView(_ _mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let open = view.annotation?.subtitle {
                openLink(open ?? "")
            }
        }
    }
    
    
    func extractCoordinates(location: Location) -> CLLocationCoordinate2D? {
        if let lat = location.latitude, let lon = location.longitude {
            return CLLocationCoordinate2DMake(lat, lon)
        }
        return nil
    }

    
    func setup () {
       var annotations = [MKPointAnnotation]()
        mapView.removeAnnotations(annotations)
        annotations.removeAll()
        
            for data in locations {
                    let lat = CLLocationDegrees(data.latitude ?? 0.0)
                    let long = CLLocationDegrees(data.longitude ?? 0.0)
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    let firstName = data.firstName
                    let lastName = data.lastName
                    let mediaURL = data.mediaURL
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = "\(firstName) \(lastName)"
                    annotation.subtitle = mediaURL
                    annotations.append(annotation)
                }
                mapView.addAnnotations(annotations)
    
    
    }
}
