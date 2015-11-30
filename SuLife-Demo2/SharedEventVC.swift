//
//  SharedEventVC.swift
//  SuLife-Demo2
//
//  Created by Sine Feng on 11/21/15.
//  Copyright © 2015 Sine Feng. All rights reserved.
//

import UIKit
import MapKit

class SharedEventVC: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextView!
    @IBOutlet weak var detailTextField: UITextView!
    @IBOutlet weak var startTime: UITextView!
    @IBOutlet weak var endTime: UITextView!
    @IBOutlet weak var location: UITextView!
    @IBOutlet weak var mapLocation: UIButton!
    
    
    var eventDetail : EventModel?
    var eventLocation : LocationModel!
    
    var event:NSDictionary = NSDictionary()
    
    // MARK : Activity indicator >>>>>
    private var blur = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
    private var spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    
    func activityIndicator() {
        
        blur.frame = CGRectMake(30, 30, 60, 60)
        blur.layer.cornerRadius = 10
        blur.center = self.view.center
        blur.clipsToBounds = true
        
        spinner.frame = CGRectMake(0, 0, 50, 50)
        spinner.hidden = false
        spinner.center = self.view.center
        spinner.startAnimating()
        
        self.view.addSubview(blur)
        self.view.addSubview(spinner)
    }
    
    func stopActivityIndicator() {
        spinner.stopAnimating()
        spinner.removeFromSuperview()
        blur.removeFromSuperview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextField.userInteractionEnabled = false
        detailTextField.userInteractionEnabled = false
        startTime.userInteractionEnabled = false
        endTime.userInteractionEnabled = false
        location.userInteractionEnabled = false
        
        titleTextField.text = eventDetail?.title as? String
        detailTextField.text = eventDetail?.detail as? String
        location.text = eventDetail?.locationName as? String
        
        startTime.text = NSDateFormatter.localizedStringFromDate((eventDetail?.startTime)!, dateStyle: NSDateFormatterStyle.FullStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
        endTime.text = NSDateFormatter.localizedStringFromDate((eventDetail?.endTime)!, dateStyle: NSDateFormatterStyle.FullStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
        
        let lng = eventDetail!.lng
        let lat = eventDetail!.lat
        
        if (lng == 0 || lat == 0) {
            mapLocation.userInteractionEnabled = false
        }
        
        // Do any additional setup after loading the view.
        
    }
    
    
    @IBAction func joinEventTapped(sender: UIButton) {
        
        activityIndicator()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            // Get title and detail from input
            let eventTitle = self.titleTextField.text!
            let eventDetail = self.detailTextField.text!
            let eventLocation = self.location.text!
            let lng = self.eventDetail!.lng as NSNumber
            let lat = self.eventDetail!.lat as NSNumber
            let shareOrNot = true
            
            // Get date from input and convert format
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            let startDate = dateFormatter.stringFromDate(self.eventDetail!.startTime)
            let endDate = dateFormatter.stringFromDate(self.eventDetail!.endTime)
            
            // MARK : post request to server
            
            params = "title=\(eventTitle)&detail=\(eventDetail)&starttime=\(startDate)&endtime=\(endDate)&share=\(shareOrNot)&locationName=\(eventLocation)&lng=\(lng)&lat=\(lat)"
            jsonData = commonMethods.sendRequest(eventURL, postString: params, postMethod: "POST", postHeader: accountToken, accessString: "x-access-token", sender: self)
            print("JSON data returned : ", jsonData)
            if (jsonData.objectForKey("message") == nil) {
                dispatch_async(dispatch_get_main_queue(), {
                    self.stopActivityIndicator()
                })
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                
                let myAlert = UIAlertController(title: "Add New Event Successfully!", message: "This event is in your event list!", preferredStyle: UIAlertControllerStyle.Alert)
                myAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in
                    self.navigationController?.popViewControllerAnimated(true)
                }))
                self.presentViewController(myAlert, animated:true, completion:nil)
                self.stopActivityIndicator()
            })
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        if (segue?.identifier == "sharedEventToMap") {
            let viewController = segue?.destinationViewController as! MapDetailVC
            let title = eventDetail!.title
            let lng = eventDetail!.lng
            let lat = eventDetail!.lat
            let loc_coords = CLLocationCoordinate2D(latitude: lat as CLLocationDegrees, longitude: lng as CLLocationDegrees)
            viewController.eventLocation = LocationModel(placeName: title as String, coordinate: loc_coords)
        }
    }
}
