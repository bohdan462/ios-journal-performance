//
//  CoreDataImporter.swift
//  JournalCoreData
//
//  Created by Andrew R Madsen on 9/10/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataImporter {
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    //One of the func that takes a lot of time, something about closure
    func sync(entries: [EntryRepresentation], completion: @escaping (Error?) -> Void = { _ in }) {
        print("Start Syncing")
        self.context.perform {
            let identifiers = entries.compactMap({$0.identifier})
            let fetchedEntries = self.fetchEntriesFromPersistentStore(with: identifiers, in: self.context)
            let entriesDictionary = self.saveToDictionary(entries: fetchedEntries)
            for entryRep in entries {
                guard let identifier = entryRep.identifier else { continue }
                
                if let entry = entriesDictionary[identifier] {
                    if entry != entryRep {
                        print("Updates existing Entry")
                        self.update(entry: entry, with: entryRep)
                    }
                } else {
                    print("Creates new Entry")
                    _ = Entry(entryRepresentation: entryRep, context: self.context)
                }
            }
            
            print("Done Syncing")
            completion(nil)
        }
        
    }
    
    private func saveToDictionary(entries: [Entry]) -> [String: Entry] {
        var entryDictionary = [String: Entry]()
        
        for entry in entries {
            entryDictionary[entry.identifier!] = entry
        }
        return entryDictionary
    }
    
    private func update(entry: Entry, with entryRep: EntryRepresentation) {
        entry.title = entryRep.title
        entry.bodyText = entryRep.bodyText
        entry.mood = entryRep.mood
        entry.timestamp = entryRep.timestamp
        entry.identifier = entryRep.identifier
    }
    
    //second func that tales a lot of time, Check predicate
    private func fetchEntriesFromPersistentStore(with identifiers: [String], in context: NSManagedObjectContext) -> [Entry] {
        
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiers)
        var entries: [Entry] = []
        do {
            entries = try context.fetch(fetchRequest)
        } catch {
            NSLog("Error fetching entries: \(error)")
        }
        return entries
    }
    
    //    private func fetchSingleEntryFromPersistentStore(with identifier: String?, in context: NSManagedObjectContext) -> Entry? {
    //
    //        guard let identifier = identifier else { return nil }
    //
    //        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
    //        fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier) //Something with predicate
    //
    //        var result: Entry? = nil
    //        do {
    //            result = try context.fetch(fetchRequest).first
    //        } catch {
    //            NSLog("Error fetching single entry: \(error)")
    //        }
    //        return result
    //    }
    
    let context: NSManagedObjectContext
}
