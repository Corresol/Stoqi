typealias ArticleParagraph = (title : String, content : String)

struct Article {

    let title : String
    let description : String
    let content : [ArticleParagraph]
    
    
    let imageUri : String? /// TODO: Remote image
    let color : UIColor? /// TODO: Remote color??
    
    init(title : String, description : String, content : [ArticleParagraph], imageUri : String? = nil, color : UIColor? = nil) {
        self.title = title
        self.description = description
        self.content = content
        self.imageUri = imageUri
        self.color = color
    }
}