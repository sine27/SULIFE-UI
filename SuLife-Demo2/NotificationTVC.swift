//
//  NotificationTVC.swift
//  SuLife-Demo2
//
//  Created by Sine Feng on 11/13/15.
//  Copyright © 2015 Sine Feng. All rights reserved.
//

import UIKit

class NotificationTVC: UITableViewController {
    
    // MARK : prepare for common methods
    
    let commonMethods = CommonMethodCollection()
    var jsonData = NSDictionary()
    var params : String = ""
    
    @IBOutlet weak var notificationList: UITableView!
    
    var resArrayNotification : [NSDictionary] = []
    var senders : [NSDictionary] = []
    var mailids : [NSString] = []
    
    // MARK : Activity indicator >>>>>
    private var blur = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
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
    
    // <<<<<
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stopActivityIndicator()
        notificationList.delegate = self
        notificationList.dataSource = self
        notificationList.delegate = self
        
        if (senders.count == 0) {
            commonMethods.displayAlertMessage("Alert", userMessage: "You have no notification currently!", sender: self)
        }
    }

    override func viewWillAppear(animated: Bool) {
        
        activityIndicator()
        
        // initialize vars because append used
        
        senders = []
        mailids = []
        resArrayNotification = []
        
        // MARK : post request to server
        
        params = ""
        jsonData = commonMethods.sendRequest(NotificationURL, postString: params, postMethod: "GET", postHeader: accountToken, accessString: "x-access-token", sender: self)
        
        print("JSON data returned : ", jsonData)
        if (jsonData.objectForKey("message") == nil) {
            stopActivityIndicator()
            return
        }
        
        resArrayNotification = jsonData.objectForKey("Mails") as! [NSDictionary]
        for notification in resArrayNotification {
            if ((notification.valueForKey("issuedetail") as? NSString) == "friend request") {
                let solved : Bool = (notification.objectForKey("solved") as! Bool)
                if ( solved == true ) {
                    continue
                }
                
                let relationshipID = (notification.valueForKey("_id") as? NSString)!
                let senderID = (notification.valueForKey("sender") as? NSString)!

                let sender : NSDictionary = getContactsProfileInformation(senderID)
                if (sender.objectForKey("message") == nil) {
                    stopActivityIndicator()
                    commonMethods.displayAlertMessage("Data Error", userMessage: "No such contact!", sender: self)
                    return
                }
                
                senders.append(sender)
                mailids.append(relationshipID)
            }
        }
        
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return number of contacts
        return senders.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("notificationCell", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...
        var sender : NSDictionary
        sender = senders[indexPath.row] as NSDictionary
        let fullname = (sender.valueForKey("firstname") as? String)! + " " + (sender.valueForKey("lastname") as? String)!
        cell.textLabel?.text = fullname
        return cell
    }
    
    
   override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
    
        stopActivityIndicator()

        if (segue?.identifier == "notificationDetail") {
            let vc = segue?.destinationViewController as! NotificationDetailVC
            let indexPath = tableView.indexPathForSelectedRow
            if let index = indexPath {
                let sender : NSDictionary = senders[index.row]
                let relationshipID : NSString = mailids[index.row]
                // let isFriend : Bool = solveds[index.row]
                
                let firstname = sender.valueForKey("firstname") as! NSString
                let lastname = sender.valueForKey("lastname") as! NSString
                let email = sender.valueForKey("email") as! NSString
                let requestOwnerID = sender.valueForKey("userid") as! NSString

                vc.senderDetail = NotificationModel(firstName: firstname, lastName: lastname, email: email, requestOwnerID: requestOwnerID, relationshipID: relationshipID)
            }
        }
    }
    
    // MARK : get contacts profile
    
    func getContactsProfileInformation (contactID : NSString) -> NSDictionary {
        
        // MARK : post request to server
        
        params = ""
        let getUserInformationURL = getUserInformation + "/" + (contactID as String)
        jsonData = commonMethods.sendRequest(getUserInformationURL, postString: params, postMethod: "GET", postHeader: accountToken, accessString: "x-access-token", sender: self)
        
        print("JSON data returned : ", jsonData)
        return jsonData
    }
}
