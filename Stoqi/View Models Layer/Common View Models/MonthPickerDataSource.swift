struct MonthPickerDataSource : PickerDataSource {
    var values: [PickerItemViewModel]
    var initialValue: PickerItemViewModel?
    var pickerTitle = "Select month"
    
    init(initialMonth : Int? = nil) {
        values = (1...12).map {MonthPickerItemViewModel(month: $0)}
        initialValue = initialMonth.map{MonthPickerItemViewModel(month: $0)}
    }
}

struct MonthPickerItemViewModel : PickerItemViewModel {
    var month : Int
    
    var itemText: String {
        return "\(String(format: "%02d", month))"
    }
    
    init(month : Int) {
        self.month = month
    }
}