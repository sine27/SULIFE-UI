//
//  MapVC.swift
//  SuLife
//
//  Created by Sine Feng on 10/15/15.
//  Copyright © 2015 Sine Feng. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate  {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.mapView.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        mapView.showsUserLocation = true
        initialLocation = locationManager.location!
        
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
        
        let date : NSDate = dateSelected != nil ? (dateSelected?.convertedDate())! : NSDate()
        
        // parse date to proper format 
        
        let sd = commonMethods.stringFromDate(date).componentsSeparatedByString(" ")
        let sdTime = sd[0] + " 00:01"
        let edTime = sd[0] + " 23:59"
        
        // MARK : post request to server
        
        params = "title=&detail=&locationName=&lng=&lat=&starttime=\(sdTime)&endtime=\(edTime)"
        jsonData = commonMethods.sendRequest(eventByDateURL, postString: params, postMethod: "POST", postHeader: accountToken, accessString: "x-access-token", sender: self)
        
        print("JSON data returned : ", jsonData)
        if (jsonData.objectForKey("message") == nil) {
            // Check if need stopActivityIndicator()
            return
        }
        
        resArray = jsonData.valueForKey("Events") as! [NSDictionary]
        for event in resArray {
            addPinToMapView(event.valueForKey("title") as! String,
                latitude: event.valueForKey("location")!.valueForKey("coordinates")![1] as! CLLocationDegrees,
                longitude: event.valueForKey("location")!.valueForKey("coordinates")![0] as! CLLocationDegrees)
        }
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
            
            for annotationPin in resArray {
                if (annotation.coordinate.latitude == (annotationPin.valueForKey("location")!.valueForKey("coordinates")![1] as! CLLocationDegrees) && annotation.coordinate.longitude == (annotationPin.valueForKey("location")!.valueForKey("coordinates")![0] as! CLLocationDegrees)) {

                    let rightButton: AnyObject! = UIButton(type: UIButtonType.InfoLight)
                    rightButton.titleForState(UIControlState.Normal)
                    
                    pinView!.rightCalloutAccessoryView = rightButton as? UIView
                }
            }
        }
        else {
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            performSegueWithIdentifier("mapToDetail", sender: view)
        }
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
        
        for event in resArray {
            addPinToMapView(event.valueForKey("title") as! String,
                latitude: event.valueForKey("location")!.valueForKey("coordinates")![1] as! CLLocationDegrees,
                longitude: event.valueForKey("location")!.valueForKey("coordinates")![0] as! CLLocationDegrees)
        }
        
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

    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if (segue?.identifier == "mapToDetail") {
            let vc = segue?.destinationViewController as! EventDetailVC
            
            for event in resArray {
                if ( (sender as! MKAnnotationView).annotation!.coordinate.longitude == (event.valueForKey("location")!.valueForKey("coordinates")![0] as! CLLocationDegrees) &&
                    (sender as! MKAnnotationView).annotation!.coordinate.latitude == (event.valueForKey("location")!.valueForKey("coordinates")![1] as! CLLocationDegrees)) {
                    print("Sucess")
                    selectEvent = event
                    break
                }
            }
            
            let id = selectEvent!.valueForKey("_id") as! NSString
            let title = selectEvent!.valueForKey("title") as! NSString
            let detail = selectEvent!.valueForKey("detail") as! NSString
            let st = selectEvent!.valueForKey("starttime") as! NSString
            let et = selectEvent!.valueForKey("endtime") as! NSString
            let share = selectEvent!.valueForKey("share") as! Bool
            let locationName = selectEvent!.valueForKey("locationName") as! NSString
            let lng = selectEvent!.valueForKey("location")!.valueForKey("coordinates")![0] as! NSNumber
            let lat = selectEvent!.valueForKey("location")!.valueForKey("coordinates")![1] as! NSNumber
            let startTime = st.substringToIndex(st.rangeOfString(".").location - 3).stringByReplacingOccurrencesOfString("T", withString: " ")
            let endTime = et.substringToIndex(et.rangeOfString(".").location - 3).stringByReplacingOccurrencesOfString("T", withString: " ")
            NSLog("detail ==> %@", detail);
            NSLog("st ==> %@", st);
            NSLog("et ==> %@", et);
            vc.eventDetail = EventModel(title: title, detail: detail, startTime: commonMethods.dateFromString(startTime), endTime: commonMethods.dateFromString(endTime), id: id, share: share, lng: lng, lat: lat, locationName: locationName)
        }
    }
}
