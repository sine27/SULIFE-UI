//
//  ContactVC.swift
//  SuLife
//
//  Created by Sine Feng on 10/18/15.
//  Copyright © 2015 Sine Feng. All rights reserved.
//

import UIKit

class ContactVC: UITableViewController, UISearchBarDelegate {
    
    // MARK : prepare for common methods
    
    let commonMethods = CommonMethodCollection()
    var jsonData = NSDictionary()
    var params : String = ""
    
    @IBOutlet weak var contactList: UITableView!
    @IBOutlet weak var mySearchBar: UISearchBar!
    
    var contactsInit : [NSDictionary] = []
    var contacts : [NSDictionary] = []
    
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        stopActivityIndicator()
    }
    
    // <<<<<
    override func viewDidAppear(animated: Bool) {
        spinner.stopAnimating()
        blur.removeFromSuperview()
        spinner.removeFromSuperview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        activityIndicator()
        
        contactsInit = []
        contacts = []
        
        // MARK : post request to server
        
        params = ""
        jsonData = commonMethods.sendRequest(getContactsURL, postString: params, postMethod: "GET", postHeader: accountToken, accessString: "x-access-token", sender: self)
        
        print("JSON data returned : ", jsonData)
        if (jsonData.objectForKey("message") == nil) {
            // Check if need stopActivityIndicator()
            return
        }
        
        contactsInit = jsonData.valueForKey("relationships") as! [NSDictionary]
        
        for contact in contactsInit {
            let contactID = contact.valueForKey("userid2") as! NSString
            contacts.append(getContactsProfileInformation(contactID))
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

    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
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
    
    // Sine:
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        print("SearchText: \(searchText)")
        
        var contactString : [String] = []
        for contact in contacts {
            let fullname = (contact.valueForKey("firstname") as? String)! + " " + (contact.valueForKey("lastname") as? String)!
            contactString.append(fullname)
        }
        
        searchResults = contactString.filter({ (text) -> Bool in
            let tmp: NSString = text
            let range = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return range.location != NSNotFound
        })
        
        if (contactString.count == 0) {
            searchActive = false
        } else {
            searchActive = true
        }
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return number of contacts
        print("search activate: \(searchActive)")
        if(searchActive) {
            print("Search count = \(searchResults.count)")
            return searchResults.count
        }
        print("Countacts Count: \(contacts.count)")
        return contacts.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("contactsCell", forIndexPath: indexPath) as UITableViewCell
        
        var contact : NSDictionary
        
        print("search activate: \(searchActive)")
        // Configure the cell...
        if(searchActive){
            cell.textLabel?.text = searchResults[indexPath.row]
        } else {
            contact = contacts[indexPath.row] as NSDictionary
            let fullname = (contact.valueForKey("firstname") as? String)! + " " + (contact.valueForKey("lastname") as? String)!
            cell.textLabel?.text = fullname
            print(fullname)
        }
        print("Cell Title: \(cell.textLabel?.text)")
        return cell
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if (segue?.identifier == "showContactsDetail") {
            let vc = segue?.destinationViewController as! ContactDetailVC
            let indexPath = tableView.indexPathForSelectedRow
            if let index = indexPath {
                
                var contact : NSDictionary!
                if (searchActive) {
                    let searchStr = searchResults[index.row]
                    for e in contacts {
                        if ((e.valueForKey("title") as! NSString) == searchStr) {
                            contact = e
                            break;
                        }
                    }
                } else {
                    contact = contacts[index.row]
                }

                let firstname = contact.valueForKey("firstname") as! NSString
                let lastname = contact.valueForKey("lastname") as! NSString
                let email = contact.valueForKey("email") as! NSString
                let userid = contact.valueForKey("userid") as! NSString
                vc.contactDetail = ContactsModel(firstName: firstname, lastName: lastname, email: email, id: userid)
            }
        }
    }
    
    
    
    func getContactsProfileInformation (contactID : NSString) -> NSDictionary {
        // MARK : get contacts profile
        
        var result = NSDictionary()
        let postString = ""
        let getUserInform = getUserInformation + "/" + (contactID as String)
        
        let contactsProfileUrl:NSURL = NSURL(string: getUserInform)!
        let request:NSMutableURLRequest = NSMutableURLRequest(URL: contactsProfileUrl)
        request.HTTPMethod = "get"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        request.setValue(accountToken, forHTTPHeaderField: "x-access-token")
        
        var reponseError: NSError?
        var response: NSURLResponse?
        
        var urlData: NSData?
        
        do {
            urlData = try NSURLConnection.sendSynchronousRequest(request, returningResponse:&response)
        } catch let error as NSError {
            reponseError = error
            urlData = nil
        }
        
        if ( urlData != nil ) {
            let res = response as! NSHTTPURLResponse!;
            
            if(res == nil){
                NSLog("No Response!");
            }
            
            let responseData:NSString = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
            
            NSLog("Response ==> %@", responseData);
            
            var error: NSError?
            
            do {
                if let jsonResult = try NSJSONSerialization.JSONObjectWithData(urlData!, options: []) as? NSDictionary {
                    
                    let success: NSString = jsonResult["message"] as! NSString
                    NSLog(success as String)
                    if (success != "OK! Event followed") {
                        NSLog("Get Contacts Information Failed")
                        
                    } else {
                        // Return information
                        NSLog("SUCCESS : Contacts Information")
                        result = jsonResult["profile"] as! NSDictionary
                    }
                }
            } catch {
                print(error)
            }
            
        } else {
            let myAlert = UIAlertController(title: "Connection failed!", message: "urlData Equals to NULL!", preferredStyle: UIAlertControllerStyle.Alert)
            
            if let error = reponseError {
                myAlert.message = (error.localizedDescription)
            }
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            myAlert.addAction(okAction)
            self.presentViewController(myAlert, animated:true, completion:nil)
        }


        return result
    }
}
