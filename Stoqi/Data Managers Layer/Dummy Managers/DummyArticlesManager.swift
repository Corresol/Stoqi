import GCDKit

class DummyArticlesManager : ArticlesManager {
    
    typealias `Self` = DummyArticlesManager
    
    var articles: [Article]?
    
    func performLoadArticles(_ callback: @escaping (OperationResult<[Article]>) -> Void) {
        self.articles = Self.createDummies()
        GCDQueue.main.after(1) {
            callback(.success(self.articles!))
        }
    }
    
    
    class func createDummies() -> [Article] {
        return [
            Article(title: "What to wear on wood floors?",
                description: "Hardwood floors are more sensitive to cleaning products. See the most common recommendations to keep them clean.",
                content: [
                    (title: "Some Details 1", content: "Here you'll read details 1."),
                    (title: "Some Details 2", content: "Here you'll read details 2."),
                    (title: "Nothing to read In Details 3", content: "")],
                imageUri: "school_article_1"),
            Article(title: "What to wear on wood floors?",
                description: "Hardwood floors are more sensitive to cleaning products. See the most common recommendations to keep them clean.",
                content: [
                    (title: "Some Details 1", content: "Here you'll read details 1."),
                    (title: "Some Details 2", content: "Here you'll read details 2."),
                    (title: "Nothing to read In Details 3", content: "")],
                color: StoqiPallete.darkColor),
            Article(title: "What to wear on wood floors?",
                description: "Hardwood floors are more sensitive to cleaning products. See the most common recommendations to keep them clean.",
                content: [
                    (title: "Some Details 1", content: "Here you'll read details 1."),
                    (title: "Some Details 2", content: "Here you'll read details 2."),
                    (title: "Really long Details 3", content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent vel suscipit nisi. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Morbi mi arcu, egestas a egestas eu, bibendum eu sapien. Maecenas ut scelerisque purus, eget accumsan mi. Vivamus et augue nunc. Nulla consequat tempus volutpat. Duis ut ante ut lectus pretium aliquam a mattis orci. Sed sit amet pulvinar lacus. Proin finibus sapien vitae turpis commodo, a volutpat mi pellentesque. Aliquam aliquam, neque vitae posuere dapibus, turpis nibh cursus nunc, ac mattis tellus sapien euismod felis. Donec iaculis suscipit massa, sit amet sagittis orci tristique in. Cras pharetra molestie porttitor. Aliquam interdum dolor et semper bibendum. Pellentesque in lorem augue. Etiam lorem justo, dapibus eget tellus eget, dictum rhoncus sem.\n\nNam in ipsum vitae nisl finibus vehicula. Maecenas massa risus, convallis nec mi at, maximus finibus augue. Quisque et arcu at tortor sagittis lacinia. Pellentesque sed diam et tellus fringilla sollicitudin. Aliquam nibh erat, rutrum nec malesuada in, rutrum mattis magna. Etiam a ipsum ultrices, sagittis diam ac, tristique nibh. Morbi tempor consequat nunc id porttitor. Aliquam erat volutpat. Aenean facilisis sapien in mi molestie ultricies. Donec ac felis sit amet ex mollis facilisis sed in elit. Suspendisse vitae lacus ut justo tempus fringilla at non felis. Phasellus iaculis, nulla fringilla aliquet venenatis, mi orci aliquam sapien, vitae egestas ipsum ligula sit amet neque. Ut mauris magna, placerat ultricies pellentesque non, dapibus a nibh. Sed sit amet eros id sapien viverra blandit.")],
                imageUri: "school_article_2"),
            Article(title: "What to wear on wood floors?",
                description: "Hardwood floors are more sensitive to cleaning products. See the most common recommendations to keep them clean.",
                content: [
                    (title: "Some Details 1", content: "Here you'll read details 1."),
                    (title: "Some Details 2", content: "Here you'll read details 2."),
                    (title: "Nothing to read In Details 3", content: "")],
                color: StoqiPallete.accentColor)
        ]

    }
}
