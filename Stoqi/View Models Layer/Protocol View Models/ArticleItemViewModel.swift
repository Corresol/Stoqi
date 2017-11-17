/// Used within CleaningSchool Screen to represent short article.
protocol ArticleItemViewModel : ArticleCellDataSource, ArticleCellStyleSource {
    var article : Article {get}
}