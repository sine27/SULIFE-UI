//
//  ToDoListTVC.swift
//  SuLife-Demo2
//
//  Created by Sine Feng on 11/6/15.
//  Copyright © 2015 Sine Feng. All rights reserved.
//

import UIKit

class ToDoListTVC: UITableViewController {
    
    // MARK : prepare for common methods
    
    let commonMethods = CommonMethodCollection()
    var jsonData = NSDictionary()
    var params : String = ""
    
    // MARK: Properties
    
    @IBOutlet var TodoList: UITableView!
    @IBOutlet weak var mySearchBar: UISearchBar!
    
    var markIndexPath: NSIndexPath? = nil
    
    var resArray : [NSDictionary] = []
    var undoList : [NSDictionary] = []
    var searchResults : [String] = []
    var searchActive : Bool = false
    
    // MARK : activity indicator
    
    private var blur = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
    private var spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    
    func activityIndicator(){
        
        blur.frame = CGRectMake(50, 50, 100, 100)
        blur.layer.cornerRadius = 10
        blur.center = self.tableView.center
        blur.clipsToBounds = true
        
        spinner.frame = CGRectMake(0, 0, 50, 50)
        spinner.hidden = false
        spinner.center = self.tableView.center
        spinner.startAnimating()
        
        self.view.addSubview(blur)
        self.view.addSubview(spinner)
    }
    
    override func viewDidAppear(animated: Bool) {
        spinner.stopAnimating()
        blur.removeFromSuperview()
        spinner.removeFromSuperview()
    }
    
    // reload data in table
    override func viewWillAppear(animated: Bool) {
        
        activityIndicator()
        
        // because I user append function, the list will be reload withour clearing
        undoList = []
        
        /* get selected date */
        let date : NSDate = dateSelected != nil ? (dateSelected?.convertedDate())! : NSDate()
        
        /* parse date to proper format */
        let sd = stringFromDate(date).componentsSeparatedByString(" ")
        let taskTime = sd[0] + " 00:00"
        
        
        // MARK : post request to server
        
        params = "title=&detail=&establishTime=\(taskTime)"
        jsonData = commonMethods.sendRequest(taskByDateURL, postString: params, postMethod: "POST", postHeader: accountToken, accessString: "x-access-token", sender: self)
        
        print("JSON data returned : ", jsonData)
        if (jsonData.objectForKey("message") == nil) {
            // Check if need stopActivityIndicator()
            return
        }
        
        resArray = jsonData.valueForKey("Tasks") as! [NSDictionary]
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
        TodoList.delegate = self
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
        let cell = tableView.dequeueReusableCellWithIdentifier("taskCell", forIndexPath: indexPath) as UITableViewCell
        
        var task : NSDictionary
        print("search activate: \(searchActive)")
        // Configure the cell...
        if(searchActive){
            cell.textLabel?.text = searchResults[indexPath.row]
        } else {
            task = undoList[indexPath.row] as NSDictionary
            cell.textLabel?.text = task.valueForKey("title") as? String
        }
        print("Cell Title: \(cell.textLabel?.text)")
        return cell
    }
    
    
    // MARK : swipe action
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let markDoneAction = UITableViewRowAction(style: .Normal, title: "Done") { (action: UITableViewRowAction, indexPath: NSIndexPath) -> Void in
            self.markIndexPath = indexPath
            
            let taskToMark = self.undoList[indexPath.row]
            self.markDone(taskToMark)
            NSLog("%@",self.undoList)
        }
        
        markDoneAction.backgroundColor = UIColor.greenColor()
        return [markDoneAction]
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if (segue?.identifier == "showTaskDetail") {
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
                vc.taskDetail = TaskModel(title: title, detail: detail, time: dateFromString(taskTime), finish: finish, id: id)
            }
        }
        
    }
    
    func dateFromString (str : String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let date = dateFormatter.dateFromString(str)
        return date!
    }
    
    func stringFromDate (date : NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let strDate = dateFormatter.stringFromDate(date)
        return strDate
    }
    
    func markDone (task : NSDictionary) {
        
        let title = task.valueForKey("title") as! NSString
        let detail = task.valueForKey("detail") as! NSString
        let taskTime = task.valueForKey("establishTime") as! NSString
        let finished = true
        
        
        // MARK : post request to server
        let edittaskURL = taskURL + "/" + (task.valueForKey("_id") as! String)
        params = "title=\(title)&detail=\(detail)&establishTime=\(taskTime)&finished=\(finished)"
        jsonData = commonMethods.sendRequest(edittaskURL, postString: params, postMethod: "POST", postHeader: accountToken, accessString: "x-access-token", sender: self)
        
        print("JSON data returned : ", jsonData)
        if (jsonData.objectForKey("message") == nil) {
            // Check if need stopActivityIndicator()
            return
        }
    }
}
