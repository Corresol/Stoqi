struct ModelArticleViewModel : ArticleViewModel {
    
    var article: Article
    
    var title : String {
        return self.article.title
    }
    
    var image: UIImage? {
        return UIImage(named: self.article.imageUri ?? "")
    }
    var color: UIColor? {
        return self.article.color
    }
    
    var paragraphs : [(String, String)] {
        return self.article.content.map {($0.title, $0.content)}
    }
    
    init(article : Article) {
        self.article = article
    }
}