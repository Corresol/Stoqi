protocol RequestViewModel : HistoryRequestCellDataSource, CurrentRequestCellDataSource {
    var request : RequestList {get}
    var date: Date  {get}
    var startDate: Date? {get}
    var endDate: Date? {get}
    var hasNextNode: Bool {get set}
    var price: Float {get}
    var items: Int { get}
}
