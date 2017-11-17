/// TSTOOLS: Candidate for TSTools part. (Like TSDataPicking)
protocol PickerDataSource {
    var values : [PickerItemViewModel] {get}
    var initialValue : PickerItemViewModel? {get set}
    var pickerTitle : String {get}
}

protocol PickerItemViewModel {
    var itemText : String {get}
}