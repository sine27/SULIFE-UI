//
//  AllTaskTVC.swift
//  SuLife
//
//  Created by Sine Feng on 11/23/15.
//  Copyright © 2015 Sine Feng. All rights reserved.
//

import UIKit

class AllTaskTVC: UITableViewController {
    
    // MARK: Properties
    
    @IBOutlet var TodoList: UITableView!
    @IBOutlet weak var mySearchBar: UISearchBar!
    
    var markIndexPath: NSIndexPath? = nil
    
    var resArray : [NSDictionary] = []
    var undoList : [NSDictionary] = []
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
        if (undoList.count == 0) {
            commonMethods.displayAlertMessage("Alert", userMessage: "No task in the list!", sender: self)
        }
    }
    
    // reload data in table
    override func viewWillAppear(animated: Bool) {
        
        activityIndicator()
        
        // because I user append function, the list will be reload withour clearing
        undoList = []
        
        // MARK : post request to server
        
        params = ""
        jsonData = commonMethods.sendRequest(taskURL, postString: params, postMethod: "GET", postHeader: accountToken, accessString: "x-access-token", sender: self)
        
        print("JSON data returned : ", jsonData)
        if (jsonData.objectForKey("message") == nil) {
            stopActivityIndicator()
            return
        }
    
        resArray = jsonData.valueForKey("tasks") as! [NSDictionary]
        for task in resArray {
            if ((task.objectForKey("finished") as! Bool) == false) {
                undoList.append(task)
            }
        }
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TodoList.delegate = self
        TodoList.dataSource = self
    
        // Tab The blank place, close keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    //Text field
    func DismissKeyboard () {
        view.endEditing(true)
    }
    // <<<<<
    
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
        print("SearchText: \(searchText)")
        
        var taskString : [String] = []
        for task in undoList {
            taskString.append(task.valueForKey("title") as! String)
        }
        
        searchResults = taskString.filter({ (text) -> Bool in
            let tmp: NSString = text
            let range = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return range.location != NSNotFound
        })
        
        searchActive = true;
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return number of tasks
        print("search activate: \(searchActive)")
        if(searchActive) {
            print("Search count = \(searchResults.count)")
            return searchResults.count
        }
        return undoList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("allTaskCell", forIndexPath: indexPath) as UITableViewCell
        
        var task : NSDictionary
        print("search activate: \(searchActive)")
        // Configure the cell...
        if(searchActive){
            cell.textLabel?.text = searchResults[indexPath.row]
        } else {
            task = undoList[indexPath.row] as NSDictionary
            cell.textLabel?.text = task.valueForKey("title") as? String
            
            // MARK : get HH:mm >>>>>
            let tt = task.valueForKey("establishTime") as! NSString
            
            cell.detailTextLabel?.text = "\(commonMethods.getFixedDate(tt, styleType: 1))\n\(commonMethods.getFixedDate(tt, styleType: 0))"
            cell.detailTextLabel?.font = UIFont.systemFontOfSize(12.0)
            cell.detailTextLabel?.numberOfLines = 2
            // <<<<<

        }
        return cell
    }
    
    
    // MARK : swipe action
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let markDoneAction = UITableViewRowAction(style: .Normal, title: "Done") { (action: UITableViewRowAction, indexPath: NSIndexPath) -> Void in
            self.markIndexPath = indexPath
            
            let taskToMark = self.undoList[indexPath.row]
            self.markDone(taskToMark)
            NSLog("%@",self.undoList)
            
            self.undoList.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
        
        markDoneAction.backgroundColor = UIColor.greenColor()
        return [markDoneAction]
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if (segue?.identifier == "showAllTaskDetail") {
            let vc = segue?.destinationViewController as! TaskDetailVC
            let indexPath = tableView.indexPathForSelectedRow
            if let index = indexPath {
                
                var task : NSDictionary!
                if (searchActive) {
                    let searchStr = searchResults[index.row]
                    for e in undoList {
                        if ((e.valueForKey("title") as! NSString) == searchStr) {
                            task = e
                            break;
                        }
                    }
                } else {
                    task = undoList[index.row]
                }
                
                let id = task.valueForKey("_id") as! NSString
                let title = task.valueForKey("title") as! NSString
                let detail = task.valueForKey("detail") as! NSString
                let tt = task.valueForKey("establishTime") as! NSString
                let finish = task.objectForKey("finished") as! Bool
                let taskTime = tt.substringToIndex(tt.rangeOfString(".").location - 3).stringByReplacingOccurrencesOfString("T", withString: " ")
                vc.taskDetail = TaskModel(title: title, detail: detail, time: commonMethods.dateFromString(taskTime), finish: finish, id: id)
            }
        }
    }
    
    func markDone (task : NSDictionary) {
        
        let title = task.valueForKey("title") as! NSString
        let detail = task.valueForKey("detail") as! NSString
        let taskTime = task.valueForKey("establishTime") as! NSString
        let finished = true
        
        let edittaskURL = taskURL + "/" + (task.valueForKey("_id") as! String)
        params = "title=\(title)&detail=\(detail)&establishTime=\(taskTime)&finished=\(finished)"
        jsonData = commonMethods.sendRequest(edittaskURL, postString: params, postMethod: "POST", postHeader: accountToken, accessString: "x-access-token", sender: self)
        
        if (jsonData.objectForKey("message") == nil) {
            stopActivityIndicator()
            return
        }
    }
}