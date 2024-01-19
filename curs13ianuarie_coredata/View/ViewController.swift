import UIKit

class ViewController: UIViewController {
    
    @IBOutlet private weak var deleteAllButton: UIButton!
    @IBOutlet private weak var addButton: UIButton!
    @IBOutlet private weak var personsTableView: UITableView!
    
    private let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addButton.layer.cornerRadius = 10
        deleteAllButton.layer.cornerRadius = 10
        personsTableView.dataSource = self
        viewModel.delegate = self
        viewModel.loadPersons()
    }
    
    private func showMessage(
        title: String,
        message: String
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let dismissAction = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(dismissAction)
        present(alert, animated: true)
    }
    
    private func showError(string: String) {
        showMessage(
            title: "Error",
            message: string
        )
    }
    private func removeRow(row: Int){
        viewModel.persons?.remove(at: row)
    }
    
    private func validateAndAddPerson(
        name: String,
        age: String
    ) {
        if name.count < 3 {
            showError(string: "Name is too short!")
            return
        }
        
        if Int(age) == nil  {
            showError(string: "Age is invalid!")
            return
        }
        
        let person = Person(
            name: name,
            age: Int(age)!
        )
        
        viewModel.addPerson(person: person)
        showMessage(
            title: "Success",
            message: "Person succesfully added!"
        )
        
    }
    
    private func validateAndUpdatePerson(id: String, name: String, age: String){
        if name.count < 3 {
            showError(string: "New name is too short!")
            return
        }
        
        if Int(age) == nil  {
            showError(string: "New age is invalid!")
            return
        }
        let person = viewModel.updatePerson(id: id, name: name, age: Int(age)!)
        showMessage(
            title: "Success",
            message: "Person succesfully updated!"
        )
    }
    
    private func deletePerson(id: String){
        viewModel.deletePerson(id: id)
    }
    
    @IBAction private func onAddPressed(_ sender: Any) {
        let alert = UIAlertController(
            title: "Add Person",
            message: nil,
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "Name"
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Age"
            textField.keyboardType = .numberPad
        }
        
        let submitAction = UIAlertAction(
            title: "ADD",
            style: .default) { [weak self] _ in
                guard let self else {return}
                let name = alert.textFields![0].text!
                let age = alert.textFields![1].text!
                self.validateAndAddPerson(
                    name: name,
                    age: age
                )
            }
        
        let cancelAction = UIAlertAction(
            title: "CANCEL",
            style: .cancel) { _ in }
        
        alert.addAction(submitAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    @IBAction private func onDeleteAllPressed(_ sender: Any) {
        viewModel.deleteAll()
        showMessage(
            title: "Success",
            message: "All persons have been deleted!"
        )
    }
    
}

extension ViewController: ViewModelDelegate {
    func personsLoaded(person: [Person]) {
        personsTableView.reloadData()
    }
    func personsLoadedWithFailre(error: Error) {}
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.persons?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PersonCell", for: indexPath)
        let person = viewModel.persons![indexPath.row]
        cell.textLabel?.text = person.name
        cell.detailTextLabel?.text = "Age: \(person.age)"
        return cell
    }
    

     func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
         let personIDToDelete = viewModel.persons?[indexPath.row].id ?? ""
         let trashAction = UIContextualAction(style: .normal, title: "Delete") {action, view, completion in
             
             let alert = UIAlertController(
                title: "Are you sure?",
                message: nil,
                preferredStyle: .alert
             )
             
             
             let submitAction = UIAlertAction(
                title: "Yes",
                style: .default) { [weak self] _ in
                    guard let self else {return}
                    let row = indexPath.row
                    self.deletePerson(id: personIDToDelete)
                    self.removeRow(row: row)
                    tableView.beginUpdates()
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    tableView.endUpdates()
                }
             
             let cancelAction = UIAlertAction(
                title: "No",
                style: .cancel) { _ in }
             
             alert.addAction(cancelAction)
             alert.addAction(submitAction)
             
             self.present(alert, animated: true)
             completion(true)
         }
         trashAction.backgroundColor = .red
         let configuration = UISwipeActionsConfiguration(actions: [trashAction])
         return configuration
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let personIDToUpdate = viewModel.persons?[indexPath.row].id ?? ""
        let person = viewModel.getPerson(id: personIDToUpdate)
        let name = person!.name
        let age = person!.age
        let updateAction = UIContextualAction(style: .normal, title: "Update") {action, view, completion in
            
            let alert = UIAlertController(
                title: "Update Person",
                message: nil,
                preferredStyle: .alert
            )
            
            alert.addTextField { textField in
                textField.text = name
            }
            
            alert.addTextField { textField in
                textField.text = String(age)
                textField.keyboardType = .numberPad
            }
            
            let submitAction = UIAlertAction(
                title: "Update",
                style: .default) { [weak self] _ in
                    guard let self else {return}
                    let name = alert.textFields![0].text!
                    let age = alert.textFields![1].text!
                    self.validateAndUpdatePerson(
                        id: personIDToUpdate,
                        name: name,
                        age: age
                    )
                    tableView.beginUpdates()
                    self.viewModel.loadPersons()
                    tableView.endUpdates()
                }
            
            let cancelAction = UIAlertAction(
                title: "CANCEL",
                style: .cancel) { _ in }
            
            alert.addAction(submitAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true)
        }
        tableView.reloadData()
        updateAction.backgroundColor = .blue
        let configuration = UISwipeActionsConfiguration(actions: [updateAction])
        return configuration
   }
}
