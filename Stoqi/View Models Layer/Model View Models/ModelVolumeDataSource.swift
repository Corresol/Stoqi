struct ModelVolumePickerItemViewModel : VolumePickerItemViewModel {
    var volume: Volume
    var details: String {
        return "\(self.volume.name.capitalized) \(self.volume.volume) \(self.volume.unit)"
    }
}

struct ModelVolumePickerDataSource : PickerDataSource {
    let pickerTitle = "Select volume"
    let values: [PickerItemViewModel]
    var initialValue: PickerItemViewModel?
    init(volumes : [Volume], initialValue : Volume? = nil) {
        self.values = volumes.map {ModelVolumePickerItemViewModel(volume: $0)}
        self.initialValue = initialValue.flatMap {ModelVolumePickerItemViewModel(volume: $0)}
    }
}
