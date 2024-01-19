## Description
This project is an iOS application developed in Swift & UIKit, utilizing Core Data for data management and adhering to the MVVM (Model-View-ViewModel) architecture.

## Key Features
1. **TableView with Swipe Actions**
    - Table cells can be deleted by swiping left, revealing a delete button.
    - Additionally, cells can be updated by swiping right, revealing an update button.

2. **Adding and Updating Using Alert Controller**
    - Adding new items to the table is done through an alert that contains text fields for entering data.
    - Updating existing cells is also done through an alert, where existing values are preloaded into the text fields.
        - Data entered is validated before addition/modification (e.g., name must be longer than 3 characters, age must be a valid number).

3. **Data Persistence with Core Data**
    - Data is stored using Core Data, providing easy and efficient data management in the application.

4. **MVVM Architecture**
    - The project adheres to the MVVM architecture, dividing logic between Model, View, and ViewModel.
