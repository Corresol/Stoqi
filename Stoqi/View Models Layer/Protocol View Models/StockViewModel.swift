protocol StockViewModel {
    var stock : Stock? {get}
    var date : Date {get}
    
    var categories: [StockProductsCategoryViewModel] {get set}
}
