//
//  EventDetailVC.swift
//  SuLife
//
//  Created by Sine Feng on 10/16/15.
//  Copyright © 2015 Sine Feng. All rights reserved.
//

import UIKit
import MapKit

class EventDetailVC: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextView!
    @IBOutlet weak var detailTextField: UITextView!
    @IBOutlet weak var startTime: UITextView!
    @IBOutlet weak var endTime: UITextView!
    @IBOutlet weak var location: UITextView!
    @IBOutlet weak var mapLocation: UIButton!

    @IBOutlet weak var shared: UILabel!
    
    var eventDetail : EventModel!
    var eventLocation : LocationModel!
    
    var event:NSDictionary = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextField.userInteractionEnabled = false
        detailTextField.userInteractionEnabled = false
        startTime.userInteractionEnabled = false
        endTime.userInteractionEnabled = false
        location.userInteractionEnabled = false
        
        
        titleTextField.text = eventDetail.title as String
        detailTextField.text = eventDetail.detail as String
        location.text = eventDetail.locationName as String
        if (eventDetail.share == true) {
            shared.text = "Yes"
        } else if (eventDetail.share == false) {
            shared.text = "No"
        }
        
        startTime.text = NSDateFormatter.localizedStringFromDate((eventDetail.startTime), dateStyle: NSDateFormatterStyle.FullStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
        endTime.text = NSDateFormatter.localizedStringFromDate((eventDetail.endTime), dateStyle: NSDateFormatterStyle.FullStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
        
        let lng = eventDetail!.lng
        let lat = eventDetail!.lat
        
        if (lng == 0 || lat == 0) {
            mapLocation.userInteractionEnabled = false
        }
        
        // Do any additional setup after loading the view.
        
    }
    
    
    @IBAction func deleteItem(sender: AnyObject) {
        
        let myAlert = UIAlertController(title: "Delete Event", message: "Are You Sure to Delete This Event? ", preferredStyle: UIAlertControllerStyle.Alert)
        
        myAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
            myAlert .dismissViewControllerAnimated(true, completion: nil)
        }))
        
        myAlert.addAction(UIAlertAction(title: "Delete", style: .Default, handler: { (action: UIAlertAction!) in
            
            /* get data from server */
            NSLog("id ==> %@", (self.eventDetail?.id)!);
            let deleteurl = eventURL + "/" + ((self.eventDetail?.id)! as String)
            
            jsonData = commonMethods.sendRequest(deleteurl, postString: "", postMethod: "DELETE", postHeader: accountToken, accessString: "x-access-token", sender: self)
            
            print("JSON data returned : ", jsonData)
            if (jsonData.objectForKey("message") == nil) {
                // Check if need stopActivityIndicator()
                return
            }
            self.navigationController!.popToRootViewControllerAnimated(true)
        }))
      
        presentViewController(myAlert, animated: true, completion: nil)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if (segue?.identifier == "eventToEditEvent") {
            let viewController = segue?.destinationViewController as! EditEventVC
            let id = eventDetail!.id
            let title = eventDetail!.title
            let detail = eventDetail!.detail
            let startTime = eventDetail!.startTime
            let endTime = eventDetail!.endTime
            let share = eventDetail!.share
            let lng = eventDetail!.lng
            let lat = eventDetail!.lat
            let locationName = eventDetail!.locationName
            viewController.eventDetail = EventModel(title: title, detail: detail, startTime: startTime, endTime: endTime, id: id, share: share, lng: lng, lat: lat, locationName: locationName)
        }
        else if (segue?.identifier == "eventToMap") {
            let viewController = segue?.destinationViewController as! MapDetailVC
            let title = eventDetail!.title
            let lng = eventDetail!.lng
            let lat = eventDetail!.lat
            let loc_coords = CLLocationCoordinate2D(latitude: lat as CLLocationDegrees, longitude: lng as CLLocationDegrees)
            viewController.eventLocation = LocationModel(placeName: title as String, coordinate: loc_coords)
        }
    }
    
}
