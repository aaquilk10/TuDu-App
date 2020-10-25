//
//  Notifications.swift
//  TuDu
//
//  Created by Aaquil Khan on 12/01/19.
//  Copyright © 2019 Aaquil Khan. All rights reserved.
//

import UIKit
import Foundation
import UserNotifications
import CoreData

class Notifications: UIViewController {
    
    // MARK: Properties
    var resultController: NSFetchedResultsController<TuDu>!
    let coreDataStack = CoreDataStack()
    
    var tuduArray = [String]()
    var prioritiesArray = [String]()
    
    // MARK: Retreiving the data sorted by priority in TuDus DataModel
    func retreiveData () {
        
        self.refresh()
        
        // Request
        let request: NSFetchRequest<TuDu> = TuDu.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "priority", ascending: true)
        
        // Initialize
        request.sortDescriptors = [sortDescriptor]
        resultController = NSFetchedResultsController(fetchRequest: request,
                                                      managedObjectContext: coreDataStack.managedContext,
                                                      sectionNameKeyPath: nil,
                                                      cacheName: nil)
        
        // Fetch the data
        do { try resultController.performFetch() }
        catch { print("Perform Fetch Error: \(error)") }
        
        let number = resultController.sections?[0].numberOfObjects
        
        if number != 0 && number != nil {
            
            for x in 0...(number!-1) {
                
                let tuduCurrentArray = resultController.fetchedObjects
                let tudu = tuduCurrentArray![x].title!
                let priority = tuduCurrentArray![x].priority
                
                tuduArray.append(tudu)
                
                if priority == 0 {
                    prioritiesArray.append("!")
                }
                else if priority == 1 {
                    prioritiesArray.append("!!")
                }
                else {
                    prioritiesArray.append("!!!")
                }
                
            }
            
        }
        
    }
    
    func notify () {
        
        let content = UNMutableNotificationContent()
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        
        if tuduArray.count != 0 {
        
            for x in 0...tuduArray.count-1 {
                
                if prioritiesArray[x] == "!" {
                    content.title = prioritiesArray[x] + "   " + tuduArray[x]
                }
                else if prioritiesArray[x] == "!!" {
                    content.title = prioritiesArray[x] + "  " + tuduArray[x]
                }
                else {
                    content.title = prioritiesArray[x] + " " + tuduArray[x]
                }
                
                let uuid = UUID().uuidString
                
                let request = UNNotificationRequest(identifier: uuid, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                
            }
            
            UIApplication.shared.applicationIconBadgeNumber = tuduArray.count
            
        }
        
        else if tuduArray.count == 0 {
            
            UIApplication.shared.applicationIconBadgeNumber = 0
            
        }
        
        self.refresh()
        
    }
    
    func refresh () {
    
        tuduArray.removeAll()
        prioritiesArray.removeAll()
        
    }
    
}
