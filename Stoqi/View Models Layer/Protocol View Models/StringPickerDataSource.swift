struct StringPickerDataSource : PickerDataSource {
    var values: [PickerItemViewModel]
    var initialValue: PickerItemViewModel?
    var pickerTitle: String
    
    init(title : String, values : [String], initialValue : String? = nil) {
        self.pickerTitle = title
        self.values = values.map {StringPickerItemViewModel(itemText: $0)}
        self.initialValue = initialValue.flatMap{StringPickerItemViewModel(itemText: $0)}
    }
}

struct StringPickerItemViewModel : PickerItemViewModel {
    var itemText: String
}