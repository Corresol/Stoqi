struct ModelKindPickerItemViewModel : KindPickerItemViewModel {
    var kind: Kind
    var name: String {
        return self.kind.name
    }
}

struct ModelKindPickerDataSource : PickerDataSource {
    let pickerTitle = "Select a product"
    let values: [PickerItemViewModel]
    var initialValue: PickerItemViewModel?
    init(kinds : [Kind], initialValue : Kind? = nil) {
        self.values = kinds.map {ModelKindPickerItemViewModel(kind: $0)}
        self.initialValue = initialValue.flatMap {ModelKindPickerItemViewModel(kind: $0)}
    }
}