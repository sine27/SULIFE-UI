
//
//  MapDetailVC.swift
//  SuLife
//
//  Created by Sine Feng on 11/24/15.
//  Copyright © 2015 Sine Feng. All rights reserved.
//

import UIKit
import MapKit

class MapDetailVC: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate {

    // MARK : prepare for common methods
    
    let commonMethods = CommonMethodCollection()
    var jsonData = NSDictionary()
    var params : String = ""
    
    let locationManager = CLLocationManager()
    var initialLocation = CLLocation()
    var newCoord : CLLocationCoordinate2D!
    
    var placeNameForEvent : String?
    var coordinateForEvent: CLLocationCoordinate2D?
    
    @IBOutlet var mapView: MKMapView!
    
    var searchController:UISearchController!
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    
    var resArray : [NSDictionary] = []
    
    var selectEvent : NSDictionary?
    
    var eventLocation : LocationModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        mapView.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        mapView.showsUserLocation = true
        
        initialLocation = CLLocation( latitude: (eventLocation.coordinate.latitude as CLLocationDegrees), longitude: (eventLocation.coordinate.longitude as CLLocationDegrees))
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(initialLocation.coordinate, 4000, 4000)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // TODO : event location
        /* get selected date */
        
        if self.mapView.annotations.count != 0 {
            for annotationShouldRemove in self.mapView.annotations {
                self.mapView.removeAnnotation(annotationShouldRemove)
            }
        }
        
        addPinToMapView(eventLocation.placeName, latitude : eventLocation.coordinate.latitude as CLLocationDegrees, longitude: eventLocation.coordinate.longitude as CLLocationDegrees)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Location Delegate Methods
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations.last
        
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
        
        self.mapView.setRegion(region, animated: true)
        
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
    {
        print("Error: " + error.localizedDescription)
    }
    
    func addPinToMapView(title: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        print(latitude)
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let annotation = MyAnnotation(coordinate: location, title: title)
        
        mapView.addAnnotation(annotation)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if pinView == nil {
            
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
        }
        else {
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    
    @IBAction func showSearchBar(sender: AnyObject) {
        self.mapView.delegate = self
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.delegate = self
        presentViewController(searchController, animated: true, completion: nil)
        
    }
    
    //MARK: UISearchBar Delegate
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        searchBar.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
        if self.mapView.annotations.count != 0 {
            for annotationPin in self.mapView.annotations {
                self.mapView.removeAnnotation(annotationPin)
            }
        }
        
        addPinToMapView(eventLocation.placeName, latitude : eventLocation.coordinate.latitude as CLLocationDegrees, longitude: eventLocation.coordinate.longitude as CLLocationDegrees)
        
        
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        
        let span = MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
        localSearchRequest.region = MKCoordinateRegion(center: initialLocation.coordinate, span: span)
        
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.startWithCompletionHandler ({ (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil{
                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                return
            }
            
            for item in localSearchResponse!.mapItems {
                self.addPinToMapView(item.name!, latitude: item.placemark.location!.coordinate.latitude, longitude: item.placemark.location!.coordinate.longitude)
                if (item == localSearchResponse!.mapItems.first) {
                    let center = CLLocationCoordinate2D(latitude: item.placemark.location!.coordinate.latitude, longitude: item.placemark.location!.coordinate.longitude)
                    let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
                    
                    self.mapView.setRegion(region, animated: true)
                }
            }
        })
    }
    
    @IBAction func currentLocationTapped(sender: UIButton) {
        let location = mapView.userLocation
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
        
        self.mapView.setRegion(region, animated: true)
        
        self.locationManager.stopUpdatingLocation()
    }
}
