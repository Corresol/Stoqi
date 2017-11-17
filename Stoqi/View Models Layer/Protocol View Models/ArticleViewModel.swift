/// Used within ReadArticle Screen
protocol ArticleViewModel {
    var article : Article {get}
    
    var image : UIImage? {get}
    var color : UIColor? {get}
    var title : String {get}
    var paragraphs : [(String, String)] {get}
}