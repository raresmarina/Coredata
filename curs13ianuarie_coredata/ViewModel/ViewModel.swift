import Foundation

protocol ViewModelDelegate: AnyObject {
    func personsLoaded(person: [Person])
    func personsLoadedWithFailre(error: Error)
}

class ViewModel {
    
    private let coreDataManger = CoreDataManager.shared
    
    weak var delegate: ViewModelDelegate?
    var persons: [Person]?
    
    func loadPersons() {
        let persons = coreDataManger.getPersons()
        self.persons = persons
        delegate?.personsLoaded(person: persons)
    }
    func getPerson(id: String)-> Person?{
        let person = coreDataManger.getPerson(id: id)
        return person
         
    }
    func addPerson(person: Person) {
        coreDataManger.addPerson(person: person)
        loadPersons()
    }
    
    func deleteAll() {
        coreDataManger.deleteAllPersons()
        loadPersons()
    }
    
    func deletePerson(id: String){
        coreDataManger.deletePerson(id: id)
        
    }
    
    func updatePerson(id: String, name: String, age: Int)-> Person?{
        let person = coreDataManger.editPerson(personIdForEdit: id, newName: name, newAge: age)
        return person
    }
}
