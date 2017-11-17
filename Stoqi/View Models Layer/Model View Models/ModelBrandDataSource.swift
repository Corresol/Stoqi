struct ModelBrandPickerItemViewModel : BrandPickerItemViewModel {
    var brand: Brand
    var name: String {
        return self.brand.name
    }
}

struct ModelBrandPickerDataSource : PickerDataSource {
    let pickerTitle = "Select a brand"
    let values: [PickerItemViewModel]
    var initialValue: PickerItemViewModel?
    init(brands : [Brand], initialValue : Brand? = nil) {
        self.values = brands.map {ModelBrandPickerItemViewModel(brand: $0)}
        self.initialValue = initialValue.flatMap {ModelBrandPickerItemViewModel(brand: $0)}
    }
}