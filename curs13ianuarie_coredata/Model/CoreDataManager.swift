import Foundation
import CoreData
import UIKit
import Combine

/*

 var a = 10
 lazy var b = 2 * a
 
 lazy var c: Int = {
     let date = Date()
     let day = Calendar.current.component(.day, from: date)
     if day % 2 == 0 {
         return 10
     } else {
         return 11
     }
 }()
 */

class CoreDataManager {
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "curs13ianuarie_coredata")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    static let shared = CoreDataManager()
    
//    private var cancellable: AnyCancellable? // necesar pentru subscriptia facuta prin Combine
    
    private init() {
        
//        cancellable = NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
//            .sink { [weak self] _ in
//                self?.saveContext()
//            } // echivalent pt observer-ul de mai jos
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(saveContext),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        // NOTE: cand folositi un observer, mare grija sa il stergeti atunci cand nu mai e nevoie de el.
    }
    
    func addPerson(person: Person) {
        let personEntity = PersonEntity(context: persistentContainer.viewContext)
        personEntity.id = person.id
        personEntity.name = person.name
        personEntity.age = Int64(person.age)
    }
    
    private func getPersonEntities() -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PersonEntity")
        do {
            return try persistentContainer.viewContext.fetch(fetchRequest) as! [NSManagedObject]
        } catch {
            return []
        }
    }
    
    func getPersons() -> [Person] {
        let managedObjects = getPersonEntities()
        let persons = managedObjects.map { managedObject in
            Person(
                id: managedObject.value(forKey: "id") as! String,
                name: managedObject.value(forKey: "name") as! String,
                age: Int(managedObject.value(forKey: "age") as! Int64)
            )
        }
        return persons
    }
    
    func getPerson(id: String) -> Person? {
        return getPersons().first { person in
            person.id == id
        }
        
        /*
        getPersons().first { person in
            return person.id == id
        }
        
        getPersons().first {$0.id == id}
         */
    }
    
    func editPerson(
        personIdForEdit: String,
        newName: String,
        newAge: Int
    ) -> Person? {
        
        if let object = getPersonEntities().first(where: {
            ($0.value(forKey: "id") as? String) == personIdForEdit
        }) {
            object.setValue(newName, forKey: "name")
            object.setValue(newAge, forKey: "age")
            saveContext()
            return Person(
                id: personIdForEdit,
                name: object.value(forKey: "name") as! String,
                age: Int(object.value(forKey: "age") as! Int64)
            )
        }
        
        return nil
    }
    
    func deletePerson(id: String) {
        let objects = getPersonEntities()
        if let objectForDelete = objects.first (where: { object in
            (object.value(forKey: "id") as? String) == id
        }) {
            persistentContainer.viewContext.delete(objectForDelete)
        }
    }
    
    func deleteAllPersons() {
        let objects = getPersonEntities()
        objects.forEach { object in
            persistentContainer.viewContext.delete(object)
        }
    }
    
    @objc
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    deinit { // NOTE: REDUNDANT pt ca clasa este un singleton si se va dealoca in momentul in care aplicatia este inchisa
        NotificationCenter.default.removeObserver(self)
    }
}
