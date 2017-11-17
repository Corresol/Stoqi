protocol ProductViewModel : ValidatableViewModel {

    var productEntry : ProductEntry? {get}
    
    var kind : KindPickerItemViewModel? {get set}
    var brand : BrandPickerItemViewModel? {get set}
    var volume : VolumePickerItemViewModel? {get set}
    var units : Int {get set}
}

protocol KindPickerItemViewModel : PickerItemViewModel {
    var kind : Kind {get}
    var name : String {get}
}

extension KindPickerItemViewModel {
    var itemText: String {
        return self.name
    }
}

protocol BrandPickerItemViewModel : PickerItemViewModel {
    var brand : Brand {get}
    var name : String {get}
}

extension BrandPickerItemViewModel {
    var itemText: String {
        return self.name
    }
}

protocol VolumePickerItemViewModel : PickerItemViewModel {
    var volume : Volume {get}
    var details : String {get}
}

extension VolumePickerItemViewModel {
    var itemText: String {
        return self.details
    }
}