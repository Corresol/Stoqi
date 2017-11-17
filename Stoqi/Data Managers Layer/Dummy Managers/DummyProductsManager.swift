import GCDKit

class DummyProductsManager : DummyAuthorizedManager, ProductsManager {
    /// Loads list of available products
    func performLoadProducts(_ callback: @escaping (OperationResult<[Product]>) -> Void) {
        self.products = type(of: self).dummies
        GCDQueue.main.after(1) {
            callback(.success(self.products!))
        }
    }

    var products : [Product]?
    
    var categories: [Category]? {
        return type(of: self).dummyCategories
    }
    
    func performFindProduct(_ barcode: String, callback: @escaping (OperationResult<Product>) -> Void) {
        GCDQueue.main.after(1) {
            callback(.success(type(of: self).dummies.random))
        }
    }
}
extension DummyProductsManager {
    fileprivate class var dummies : [Product] {
        let categories = self.dummyCategories
        let brands = self.dummyBrands
        let kinds = self.dummyKinds
        let volumes = self.dummyVolumes
        
        return (0..<kinds.count).map {
            let volume = volumes[(0..<volumes.count).random]
            let id = $0 + 1
            let category = categories[(0..<categories.count).random]
            let kind = kinds[$0 % kinds.count]
            let brand = brands[(0..<brands.count).random]
            return Product(id: id,
                category: category,
                kind: kind,
                brand: brand,
                volume: volume,
				price: (1.0..<20.1).random)
        }
    }
    
    class var dummyBrands : [Brand] {
        return [Brand(id: 1, name: "OMO"),
                Brand(id: 2, name: "Confort"),
                Brand(id: 3, name: "Ype")]
    }
    
    class var dummyKinds : [Kind] {
        return [Kind(id: 1, name: "Soap Powder"),
                Kind(id: 2, name: "Softener"),
                Kind(id: 3, name: "Soapstone")]
    }
    
    class var dummyVolumes : [Volume] {
        return [Volume(id: 1, name: "Multiacao", volume: 2, unit: "kg"),
                Volume(id: 2, name: "Original", volume: 500, unit: "ml"),
                Volume(id: 3, name: "Glicerina", volume: 3, unit: "unidades")]
    }
    
    class var dummyCategories : [Category] {
        return [Category(id: 1, name: "Clothing"),
                Category(id: 2, name: "Cleaning"),
                Category(id: 3, name: "Others")]
    }
    
    override func deauthorize(_ notification: Notification) {
        super.deauthorize(notification)
        self.products = nil
    }
}
