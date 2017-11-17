struct ModelArticleItemViewModel : ArticleItemViewModel {
    let article : Article
    var title: String {
        return self.article.title
    }
    var description: String {
        return self.article.description
    }
    
    var backgroundColor: UIColor? {
        return self.article.color
    }
    var backgroundImage: UIImage? {
        return UIImage(named: self.article.imageUri ?? "")
    }
    
    init(article : Article) {
       self.article = article
    }
}
