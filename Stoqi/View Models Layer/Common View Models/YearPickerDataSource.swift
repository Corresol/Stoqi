struct YearPickerDataSource : PickerDataSource {
    var values: [PickerItemViewModel]
    var initialValue: PickerItemViewModel?
    var pickerTitle = "Select year"
    
    init(initialYear : Int? = nil) {
        let current = Date().year
        let latest = current + 10
        values = (current...latest).map {YearPickerItemViewModel(year: $0)}
        initialValue = initialYear.map{YearPickerItemViewModel(year: $0)}
    }
}

struct YearPickerItemViewModel : PickerItemViewModel {
    var year : Int
    
    var itemText: String {
        return "\(year)"
    }
    
    init(year : Int) {
        self.year = year
    }
}
