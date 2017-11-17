struct ModelAddressViewModel : AddressViewModel {
    var address : Address? {
        guard let street = street.value,
        let building = building.value,
            let zip = zip.value, isValid else {
                return nil
        }
        return Address(street: street, building: building, zip: zip)
    }
    
    var fullAddress : String? {
        guard let street = street.value,
            let building = building.value,
            let zip = zip.value, isValid else {
                return nil
        }
        return "\(building) \(street), \(zip)"
    }
    
    var street: ValidatableProperty<String>
    var building: ValidatableProperty<String>
    var zip: ValidatableProperty<String>
    
    init(address : Address? = nil) {
        street = ValidatableProperty(value: address?.street, validators: [NilValidator(), LengthValidator(minLength: 3)])
        building = ValidatableProperty(value: address?.building, validators: [NilValidator(), LengthValidator(minLength: 1)])
        zip = ValidatableProperty(value: address?.zip, validators: [NilValidator(), LengthValidator(minLength: 5), LengthValidator(maxLength: 9)])
    }
    
    var validatables : [Validatable] {
        return [street, building, zip]
    }
}
