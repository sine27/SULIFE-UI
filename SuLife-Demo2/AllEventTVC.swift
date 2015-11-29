//
//  AllEventTVC.swift
//  SuLife
//
//  Created by Sine Feng on 11/23/15.
//  Copyright © 2015 Sine Feng. All rights reserved.
//

import UIKit

class AllEventTVC: UITableViewController {

    // MARK: Properties
    
    @IBOutlet weak var EventList: UITableView!
    @IBOutlet weak var mySearchBar: UISearchBar!
    
    var resArray : [NSDictionary] = []
    var searchResults : [String] = []
    var searchActive : Bool = false

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

    
    override func viewDidAppear(animated: Bool) {
        stopActivityIndicator()
        if (resArray.count == 0) {
            commonMethods.displayAlertMessage("Alert", userMessage: "No task in the list currently!", sender: self)
        }
    }
    
    // reload data in table
    override func viewWillAppear(animated: Bool) {
        activityIndicator()
        
        jsonData = commonMethods.sendRequest(eventURL, postString: "", postMethod: "GET", postHeader: accountToken, accessString: "x-access-token", sender: self)

        if (jsonData.objectForKey("message") == nil) {
            // Check if need stopActivityIndicator()
            return
        }
        
        resArray = jsonData.valueForKey("Events") as! [NSDictionary]
        
        self.tableView.reloadData()

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //tableView.registerClass(ItemTableViewCell.self, forCellReuseIdentifier: "Cell")
        
        EventList.delegate = self
        EventList.dataSource = self
        EventList.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
        self.tableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
        mySearchBar.text = ""
        mySearchBar.resignFirstResponder()
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        var eventString : [String] = []
        for event in resArray {
            eventString.append(event.valueForKey("title") as! String)
        }
        
        searchResults = eventString.filter({ (text) -> Bool in
            let tmp: NSString = text
            let range = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return range.location != NSNotFound
        })
        
        searchActive = true;
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return number of events
        if(searchActive) {
            return searchResults.count
        }
        return resArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("allEventCell", forIndexPath: indexPath) as UITableViewCell
        
        var event : NSDictionary
        // Configure the cell...
        if(searchActive){
            cell.textLabel?.text = searchResults[indexPath.row]
        } else {
            event = resArray[indexPath.row] as NSDictionary
            cell.textLabel?.text = event.valueForKey("title") as? String
        }
        return cell
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if (segue?.identifier == "showAllEventDetail") {
            let vc = segue?.destinationViewController as! EventDetailVC
            let indexPath = tableView.indexPathForSelectedRow
            if let index = indexPath {
                var event : NSDictionary!
                if (searchActive) {
                    let searchStr = searchResults[index.row]
                    for e in resArray {
                        if (e.valueForKey("title") as? NSString == searchStr) {
                            event = e
                            break;
                        }
                    }
                } else {
                    event = resArray[index.row]
                }
                let id = event.valueForKey("_id") as! NSString
                let title = event.valueForKey("title") as! NSString
                let detail = event.valueForKey("detail") as! NSString
                let st = event.valueForKey("starttime") as! NSString
                let et = event.valueForKey("endtime") as! NSString
                let share = event.valueForKey("share") as! Bool
                let locationName = event.valueForKey("locationName") as! NSString
                let lng = event.valueForKey("location")!.valueForKey("coordinates")![0] as! NSNumber
                let lat = event.valueForKey("location")!.valueForKey("coordinates")![1] as! NSNumber
                let startTime = st.substringToIndex(st.rangeOfString(".").location - 3).stringByReplacingOccurrencesOfString("T", withString: " ")
                let endTime = et.substringToIndex(et.rangeOfString(".").location - 3).stringByReplacingOccurrencesOfString("T", withString: " ")
                NSLog("detail ==> %@", detail);
                NSLog("st ==> %@", st);
                NSLog("et ==> %@", et);
                vc.eventDetail = EventModel(title: title, detail: detail, startTime: commonMethods.dateFromString(startTime), endTime: commonMethods.dateFromString(endTime), id: id, share: share, lng: lng, lat: lat, locationName: locationName)
            }
        }
    }
}
