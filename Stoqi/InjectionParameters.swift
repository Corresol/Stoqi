typealias RegisterListPageInjectionParameter = (question : QuestionViewModel,
    pageIndex : Int,
    totalPages : Int,
    canNavigateNext : Bool)

typealias SearchPropertyLocationInjectionParameter = (location : PropertyLocation, matchingTerm : String?)

typealias ProductsCategoryInjectionParameter = (category : Category, products : [ProductEntry])

typealias StockProductsCategoryInjectionParameter = (category : Category, products : [StockProduct])

typealias HomeInjectionParameter = (profile : Profile, requests : [RequestList], analytic: Analytic)

typealias StringPickerDataSourceInjectionParameter = (title : String, values : [String], initialValue : String?)

enum ValidatorTypeInjectionParameter {
    case loginValidators
    case passwordValidators
    case nameValidators
}

enum PickerInjectionParameter {
    case monthsPicker
    case yearsPicker
}
