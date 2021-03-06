// Copyright (C) 2003-2015 eXo Platform SAS.
//
// This is free software; you can redistribute it and/or modify it
// under the terms of the GNU Lesser General Public License as
// published by the Free Software Foundation; either version 3 of
// the License, or (at your option) any later version.
//
// This software is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this software; if not, write to the Free
// Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
// 02110-1301 USA, or see the FSF site: http://www.fsf.org.

import UIKit

class SettingViewController: UITableViewController {
    
    let kTableHeaderViewIdentifier:String = "table-header"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerNib(UINib(nibName: "TableHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: kTableHeaderViewIdentifier)
        self.tableView.backgroundColor = UIColor.whiteColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if (segue.identifier == "EditServerSegue") {
            let indexPath = self.tableView.indexPathForSelectedRow
            let server:Server = ServerManager.sharedInstance.serverList![(indexPath?.row)!]
                    as! Server
            let serverEditVC:ServerEditViewController =  segue.destinationViewController as! ServerEditViewController
            serverEditVC.server = server
        }
    }


    
    /*
    // MARK: - Table View Datasource & Delegate
    */
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        // List Servers & About Sections
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            // List Servers Section
            if (ServerManager.sharedInstance.serverList != nil &&
                ServerManager.sharedInstance.serverList.count > 0) {
                return ServerManager.sharedInstance.serverList!.count
            } else {
                // If there's no server, we display the NoServerCell
                return 1;
            }
        }
        // About Section --> Application Version Row.
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Config.kTableHeaderHeight
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return Config.kTableCellHeight
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            if (ServerManager.sharedInstance.serverList.count > 0) {
                // A cell that displays the server at the specified position
                let srvcell = tableView.dequeueReusableCellWithIdentifier("ServerCell", forIndexPath: indexPath)
                srvcell.textLabel?.text = (ServerManager.sharedInstance.serverList?[indexPath.row] as! Server).serverURL.stringURLWithoutProtocol()
                return srvcell
            } else {
                // A cell that displays a label "Connect your intranet" and directs to the input server screen
                let ctacell = tableView.dequeueReusableCellWithIdentifier("NoServerCell", forIndexPath: indexPath)
                ctacell.textLabel?.text = NSLocalizedString("Setting.Title.AddServer", comment: "")
                ctacell.textLabel?.font = UIFont.boldSystemFontOfSize(16)
                return ctacell
            }
        }
        // About Section 
        let abtcell = tableView.dequeueReusableCellWithIdentifier("AboutCell", forIndexPath: indexPath)
        abtcell.textLabel?.text = NSLocalizedString("Setting.Title.ApplicationVersion",comment:"")
        let version: AnyObject? = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]
        abtcell.detailTextLabel?.text = version as? String
        return abtcell

    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView:TableHeaderView = tableView.dequeueReusableHeaderFooterViewWithIdentifier(kTableHeaderViewIdentifier) as! TableHeaderView
        if (section == 0) {
            if (ServerManager.sharedInstance.serverList.count > 0) {
                // Title: My intranets
                headerView.title.text =  NSLocalizedString("Setting.Title.Server",comment:"")
            } else {
                // Title: No intranet
                headerView.title.text = NSLocalizedString("Setting.Title.NoServer", comment: "")
            }
        } else {
            headerView.title.text =  NSLocalizedString("Setting.Title.About",comment:"")
        }
        return headerView
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Can only edit server rows (not the NoServerCell) in the servers section (0)
        return (indexPath.section == 0 && ServerManager.sharedInstance.serverList.count > 0 )
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            self.deleteServer(indexPath)
        }
    }
    
    func deleteServer(indexPath: NSIndexPath) {
        let alertController = UIAlertController(title: NSLocalizedString("Setting.Title.DeleteServer", comment: ""), message: NSLocalizedString("Setting.Message.DeleteServer", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("Word.Cancel", comment: ""), style: UIAlertActionStyle.Cancel) {
            (cancelAction) -> Void in
        }
        alertController.addAction(cancelAction)
        let confirmAction = UIAlertAction(title: NSLocalizedString("Word.OK", comment: ""), style: UIAlertActionStyle.Destructive) { (confirmAction) -> Void in
            let server:Server = (ServerManager.sharedInstance.serverList?[indexPath.row])! as! Server
            ServerManager.sharedInstance.removeServer(server)
            self.tableView.reloadData()
        }
        alertController.addAction(confirmAction)
        self.presentViewController(alertController, animated: false, completion: nil)
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.reloadData()
    }

}
