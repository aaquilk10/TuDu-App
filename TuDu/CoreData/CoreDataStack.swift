//
//  CareDataStack.swift
//  TuDu
//
//  Created by Aaquil Khan on 07/01/19.
//  Copyright © 2019 Aaquil Khan. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    var container: NSPersistentContainer {
        
        let container = NSPersistentContainer(name: "TuDus")
        container.loadPersistentStores { (description, error) in
            guard error == nil else {
                print("Error: \(error!)")
                return
            }
        }
        return container
        
    }
    
    var managedContext: NSManagedObjectContext {
        return container.viewContext
    }
    
}
