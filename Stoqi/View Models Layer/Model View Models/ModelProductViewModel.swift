struct ModelProductViewModel : ProductViewModel {
    
    var productEntry: ProductEntry? {
        guard let kind = self.kind?.kind,
            let brand = self.brand?.brand,
            let volume = self.volume?.volume else {
                return nil
        }
        let product = Product(id: nil, category: self.category, kind: kind, brand: brand, volume: volume, price: 0)
        return ProductEntry(product: product, units: self.units, suggestedProduct: nil)
    }

    
    var kind: KindPickerItemViewModel? = nil
    var brand : BrandPickerItemViewModel? = nil
    var volume: VolumePickerItemViewModel? = nil
    var units: Int = 0
   
    fileprivate let category : Category
    
    init(category : Category) {
        self.category = category
    }
    
    init(productEntry : ProductEntry) {
        self.brand = ModelBrandPickerItemViewModel(brand: productEntry.product.brand)
        self.volume = ModelVolumePickerItemViewModel(volume: productEntry.product.volume)
        self.kind = ModelKindPickerItemViewModel(kind: productEntry.product.kind)
        self.category = productEntry.product.category
        self.units = productEntry.units
    }
    
    var isValid: Bool {
        return self.kind != nil &&
            self.brand != nil &&
            self.volume != nil &&
            self.units > 0
    }
}
