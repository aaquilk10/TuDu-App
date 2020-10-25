//
//  TuDuTableViewController.swift
//  TuDu
//
//  Created by Aaquil Khan on 02/01/19.
//  Copyright © 2019 Aaquil Khan. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class TuDuTableViewController: UITableViewController {
    
    // MARK: Properties
    var resultController: NSFetchedResultsController<TuDu>!
    let coreDataStack = CoreDataStack()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Notification authorization
        self.authorization()
        
        // Requesting the data in DataModel
        let request: NSFetchRequest<TuDu> = TuDu.fetchRequest()
        let oldSortDescriptor = NSSortDescriptor(key: "priority", ascending: true)
        let sortDescriptor = oldSortDescriptor.reversedSortDescriptor as! NSSortDescriptor
        
        // Initialize
        request.sortDescriptors = [sortDescriptor]
        resultController = NSFetchedResultsController(fetchRequest: request,
                                                      managedObjectContext: coreDataStack.managedContext,
                                                      sectionNameKeyPath: nil,
                                                      cacheName: nil)
        
        resultController.delegate = self
        
        // Fetch the data
        do { try resultController.performFetch() }
        catch { print("Perform Fetch Error: \(error)") }
        
        // Uncomment the following line to preserve selection between presentations
        //self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.leftBarButtonItem = self.editButtonItem
    }
    
    // Ask for permission to show notifications
    func authorization () {
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge]) { (granted, error) in
            
            if !granted {
                let title = "Notifications"
                let message = "Please allow us to send notifications so that you can get all your TuDus in the notification center"
                self.showAlert(title, message)
            }
            
        }
        
    }
    
    // Method for showing the alert if permission to send notification is denied
    func showAlert (_ title: String, _ message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertActionDeny = UIAlertAction(title: "Deny", style: .default, handler: nil)
        let alertActionAllow = UIAlertAction(title: "Allow", style: .default) { (self) in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }
        
        alert.addAction(alertActionDeny)
        alert.addAction(alertActionAllow)
        
        alert.preferredAction = alertActionAllow
        
        present(alert, animated: true, completion: nil)
        
    }

    // MARK:  tableView data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return resultController.sections?[section].numberOfObjects ?? 0
    }

    // MARK: cell data source
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TuDuCell", for: indexPath)

        // Configure the cell
        let tudu = resultController.object(at: indexPath)
        cell.textLabel?.text = tudu.title

        return cell
    }
    
    // MARK: tableView delegate
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(style: .destructive, title: "Done") { (action, view, completion) in
            
            // TODO: delete TuDu
            let tudu = self.resultController.object(at: indexPath)
            self.resultController.managedObjectContext.delete(tudu)
            
            do {
                try self.resultController.managedObjectContext.save()
                completion(true)
            }
            catch {
                print("Delete Failed, Error: \(error)")
                completion(false)
            }
        }
        
        action.image = UIImage(named: "check")
        action.backgroundColor = UIColor(red: 0.0, green: 224.0/255.0, blue: 37.0/255.0, alpha: 1.0)
        
        return UISwipeActionsConfiguration(actions: [action])
        
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(style: .destructive, title: "Done") { (action, view, completion) in
            
            // TODO: delete TuDu
            let tudu = self.resultController.object(at: indexPath)
            self.resultController.managedObjectContext.delete(tudu)
            
            do {
                try self.resultController.managedObjectContext.save()
                completion(true)
            }
            catch {
                print("Delete Failed, Error: \(error)")
                completion(false)
            }
        }
        
        action.image = UIImage(named: "check")
        action.backgroundColor = UIColor(red: 0.0, green: 224.0/255.0, blue: 37.0/255.0, alpha: 1.0)
        
        return UISwipeActionsConfiguration(actions: [action])
        
    }
    
    // If user selects a row from tableView
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "ShowAddTudu", sender: tableView.cellForRow(at: indexPath))
        
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        if let _ = sender as? UIBarButtonItem, let vc = segue.destination as? AddTuDuViewController{
            vc.managedContext = resultController.managedObjectContext
        }
        
        if let cell = sender as? UITableViewCell, let vc = segue.destination as? AddTuDuViewController{
            vc.managedContext = resultController.managedObjectContext
            
            if let indexPath = tableView.indexPath(for: cell) {
                let tudu = resultController.object(at: indexPath)
                vc.tudu = tudu
            }
        }
        
    }

}

extension TuDuTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        tableView.beginUpdates()
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        tableView.endUpdates()
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
     
        switch type {
            
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
            
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            
        case.update:
            
            tableView.reloadData()
            
        default:
            
            tableView.reloadData()
            
            break
            
        }
        
    }
    
}
