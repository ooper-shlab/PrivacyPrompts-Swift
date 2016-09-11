//
//  APLPrivacyDetailViewController.swift
//  PrivacyPrompts
//
//  Translated by OOPer in cooperation with shlab.jp, on 2016/1/23.
//
//
/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 View controller that handles checking and requesting access to the users private data classes.
 */

import UIKit

typealias CheckAccessBlock = ()->Void
typealias RequestAccessBlock = ()->Void

@objc(APLPrivacyDetailViewController)
class APLPrivacyDetailViewController: UITableViewController {
    
    var checkBlock: CheckAccessBlock?
    var requestBlock: RequestAccessBlock?
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.checkBlock != nil && self.requestBlock != nil {
            return 2
        }
        
        if self.checkBlock != nil || self.requestBlock != nil {
            return 1
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActionCell", for: indexPath)
        
        let num = tableView.numberOfRows(inSection: (indexPath as NSIndexPath).section)
        if num == 2 {
            if (indexPath as NSIndexPath).row == 0 {
                cell.textLabel?.text = NSLocalizedString("CHECK_ACCESS", comment: "")
            } else if (indexPath as NSIndexPath).row == 1 {
                cell.textLabel?.text = NSLocalizedString("REQUEST_ACCESS", comment: "")
            }
        } else if num == 1 {
            if self.checkBlock != nil {
                cell.textLabel?.text = NSLocalizedString("CHECK_ACCESS", comment: "")
            } else if self.requestBlock != nil {
                cell.textLabel?.text = NSLocalizedString("REQUEST_ACCESS", comment: "")
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rowsInSection = tableView.numberOfRows(inSection: (indexPath as NSIndexPath).section)
        if rowsInSection == 2 {
            if (indexPath as NSIndexPath).row == 0 {
                self.checkBlock?()
            }
            if (indexPath as NSIndexPath).row == 1 {
                self.requestBlock?()
            }
        } else if rowsInSection == 1 {
            if self.checkBlock != nil {
                self.checkBlock!()
            } else {
                self.requestBlock?()
            }
        }
    }
    
}
