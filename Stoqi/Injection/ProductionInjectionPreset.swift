struct ProductionInjectionPreset : InjectionRulesPreset {
    
    var rules : [InjectionRule] = []
    
    init() {
        var compoundRules : [InjectionRule] = []
        compoundRules += self.requestConfiguration
        compoundRules += self.convertersRules
        compoundRules += self.managersRules
        compoundRules += self.viewModelsRules
        compoundRules += self.valdiatorsRules
        compoundRules += self.dataSourcesRules
        self.rules = compoundRules
    }
    
    /// Shortcut for injectable `RequestManager`
    fileprivate var requestManager : RequestManager {
        return try! Injector.inject(RequestManager.self)
    }
    
    fileprivate var accountManager : AuthorizationManager {
        return try! Injector.inject(AuthorizationManager.self)
    }
	
	fileprivate var profileManager : ProfileManager {
		return try! Injector.inject(ProfileManager.self)
	}
	
    /// Shortcut for injectable `RequestManagerConfiguration`
    fileprivate var requestManagerConfiguration : RequestManagerConfiguration {
        return try! Injector.inject(RequestManagerConfiguration.self)
    }
    
    // MARK: - Manager Rules
    var managersRules : [InjectionRule] {
        return [
            InjectionRule(injectable: RequestManager.self, injected: AlamofireRequestManager(configuration: self.requestManagerConfiguration)),
            
            InjectionRule(injectable: AuthorizationManager.self, injected: ServiceAuthorizationManager(requestManager: self.requestManager)),
            
            InjectionRule(injectable: ProfileManager.self, injected: ServiceProfileManager(requestManager: self.requestManager, accountManager: self.accountManager)),
            InjectionRule(injectable: ProductsManager.self, injected: ServiceProductsManager(requestManager: self.requestManager)),
            InjectionRule(injectable: RequestsManager.self, injected: ServiceRequestsManager(requestManager: self.requestManager, accountManager: self.accountManager)),
            InjectionRule(injectable: StockManager.self, injected: ServiceStockManager(requestManager: self.requestManager, accountManager: self.accountManager)),
            InjectionRule(injectable: CardsManager.self, injected: ServiceCardsManager(requestManager: self.requestManager, accountManager: self.accountManager, profileManager: self.profileManager)),
            InjectionRule(injectable: AnalyticManager.self, injected: ServiceAnalyticManager(requestManager: self.requestManager, accountManager: self.accountManager))
        ]
    }
    
    var requestConfiguration : [InjectionRule] {
        return [
            InjectionRule(injectable: RequestManagerConfiguration.self, injected: StoqiRequestManagerConfiguration())
        ]
    }
}

// MARK: - Converters Rules
extension ProductionInjectionPreset {
    
    fileprivate var brandConverter : ResponseConverter<Brand> {
        return try! Injector.inject(ResponseConverter<Brand>.self)
    }
    
    fileprivate var volumeConverter : ResponseConverter<Volume> {
        return try! Injector.inject(ResponseConverter<Volume>.self)
    }
    
    fileprivate var kindConverter : ResponseConverter<Kind> {
        return try! Injector.inject(ResponseConverter<Kind>.self)
    }
    
    fileprivate var productConverter : ResponseConverter<Product> {
        return try! Injector.inject(ResponseConverter<Product>.self)
    }
    
    fileprivate var stockProductConverter : ResponseConverter<StockProduct> {
        return try! Injector.inject(ResponseConverter<StockProduct>.self)
    }
    
    var convertersRules : [InjectionRule] {
        return [
            InjectionRule(injectable: ResponseConverter<Account>.self, injected: AccountConverter()),
            InjectionRule(injectable: ResponseConverter<PropertyLocation>.self, injected: PropertyLocationConverter()),
            InjectionRule(injectable: ResponseConverter<Product>.self, injected: ProductConverter(kindConverter: self.kindConverter,
                                                                                                    brandConverter: self.brandConverter,
                                                                                                    volumeConverter: self.volumeConverter)),
            InjectionRule(injectable: ResponseConverter<Kind>.self, injected: KindConverter()),
            InjectionRule(injectable: ResponseConverter<Volume>.self, injected: VolumeConverter()),
            InjectionRule(injectable: ResponseConverter<Brand>.self, injected: BrandConverter()),
            InjectionRule(injectable: ResponseConverter<Category>.self, injected: CategoryConverter()),
            InjectionRule(injectable: ResponseConverter<RequestList>.self, injected: RequestListConverter()),
            InjectionRule(injectable: ResponseConverter<ProductEntry>.self, injected: RequestedProductConverter(productConverter: self.productConverter)),
            InjectionRule(injectable: ResponseConverter<Stock>.self, injected: StockConverter(stockProductConverter: self.stockProductConverter)),
            InjectionRule(injectable: ResponseConverter<StockProduct>.self, injected: StockProductConverter(productConverter: self.productConverter)),
            InjectionRule(injectable: ResponseConverter<Card>.self, injected: CardConverter()),
            InjectionRule(injectable: ResponseConverter<Address>.self, injected: AddressConverter()),
            InjectionRule(injectable: ResponseConverter<PropertyArea>.self, injected: PropertyAreaConverter()),
            InjectionRule(injectable: ResponseConverter<PropertyResidents>.self, injected: PropertyResidentsConverter()),
            InjectionRule(injectable: ResponseConverter<Analytic>.self, injected: AnalyticConverter())
        ]
    }
}

// MARK: - ViewModel Rules
extension ProductionInjectionPreset {
    
    fileprivate var loginValidators : [Validator] {
        
        let target : Any.Type
        target = type(of: (ValidatorTypeInjectionParameter.loginValidators) as AnyObject)
        let targetType = "\(target)"
        if targetType == "_SwiftValue" {
           return [NilValidator(), LengthValidator(minLength: 4)]
        }

        
        return try! Injector.inject([Validator].self, with: ValidatorTypeInjectionParameter.loginValidators)
    }
    
    fileprivate var passwordValidators : [Validator] {
        let target : Any.Type
        target = type(of: (ValidatorTypeInjectionParameter.loginValidators) as AnyObject)
        let targetType = "\(target)"
        if targetType == "_SwiftValue" {
            return [NilValidator(), LengthValidator(minLength: 4)]
        }
        return try! Injector.inject([Validator].self, with: ValidatorTypeInjectionParameter.passwordValidators)
    }
    
    fileprivate var nameValidators : [Validator] {
        let target : Any.Type
        target = type(of: (ValidatorTypeInjectionParameter.loginValidators) as AnyObject)
        let targetType = "\(target)"
        if targetType == "_SwiftValue" {
            return [NilValidator(), LengthValidator(minLength: 4)]
        }
        return try! Injector.inject([Validator].self, with: ValidatorTypeInjectionParameter.nameValidators)
    }
    
    var viewModelsRules : [InjectionRule] {
        return [
            // MARK: LoginViewModel
            InjectionRule(injectable: LoginViewModel.self, targetType: Credentials.self) {
                ModelLoginViewModel(credentials: $0,
                    loginValidators: self.loginValidators,
                    passwordValidators: self.passwordValidators)
            },
            InjectionRule(injectable: LoginViewModel.self) {
                ModelLoginViewModel(loginValidators: self.loginValidators,
                    passwordValidators: self.passwordValidators)
            },
            
            // MARK: SearchQueryViewModel
            InjectionRule(injectable: SearchQueryViewModel.self) {
                ModelSearchQueryViewModel()
            },
            
            // MARK: PropertyLocationViewModel
            InjectionRule(injectable: SearchPropertyLocationViewModel.self, targetType: PropertyLocation.self) {
                ModelSearchPropertyLocationViewModel(location: $0, matchingTerm: nil)
            },
            
            // MARK: SearchPropertyLocationViewModel
            InjectionRule(injectable: SearchPropertyLocationViewModel.self, targetType: SearchPropertyLocationInjectionParameter.self) {
                ModelSearchPropertyLocationViewModel(location: $0.location, matchingTerm: $0.matchingTerm)
            },
            
            // MARK: PropertyLocationQuestionViewModel
            InjectionRule(injectable: PropertyLocationQuestionViewModel.self, targetType: PropertyLocation.self) {
                ModelPropertyLocationQuestionViewModel(location: $0)
            },
            InjectionRule(injectable: PropertyLocationQuestionViewModel.self) {
                ModelPropertyLocationQuestionViewModel()
            },
            InjectionRule(injectable: QuestionViewModel.self, targetType: PropertyLocation.self) {
                ModelPropertyLocationQuestionViewModel(location: $0)
            },
            
            // MARK: PropertyTypeQuestionViewModel
            InjectionRule(injectable: PropertyTypeQuestionViewModel.self, targetType: PropertyType.self) {
                ModelPropertyTypeQuestionViewModel(type: $0)
            },
            InjectionRule(injectable: PropertyTypeQuestionViewModel.self) {
                ModelPropertyTypeQuestionViewModel()
            },
            InjectionRule(injectable: QuestionViewModel.self, targetType: PropertyType.self) {
                ModelPropertyTypeQuestionViewModel(type: $0)
            },
            
            // MARK: PropertyAreaQuestionViewModel
            InjectionRule(injectable: PropertyAreaQuestionViewModel.self, targetType: PropertyArea.self) {
                ModelPropertyAreaQuestionViewModel(area: $0)
            },
            InjectionRule(injectable: PropertyAreaQuestionViewModel.self) {
                ModelPropertyAreaQuestionViewModel()
            },
            InjectionRule(injectable: QuestionViewModel.self, targetType: PropertyArea.self) {
                ModelPropertyAreaQuestionViewModel(area: $0)
            },
            
            // MARK: PropertyResidentsQuestionViewModel
            InjectionRule(injectable: PropertyResidentsQuestionViewModel.self, targetType: PropertyResidents.self) {
                ModelPropertyResidentsQuestionViewModel(residents: $0)
            },
            InjectionRule(injectable: PropertyResidentsQuestionViewModel.self) {
                ModelPropertyResidentsQuestionViewModel()
            },
            InjectionRule(injectable: QuestionViewModel.self, targetType: PropertyResidents.self) {
                ModelPropertyResidentsQuestionViewModel(residents: $0)
            },
            
            // MARK: ProductsPriorityQuestionViewModel
            InjectionRule(injectable: ProductsPriorityQuestionViewModel.self, targetType: ProductsPriority.self) {
                ModelProductsPriorityQuestionViewModel(priority: $0)
            },
            InjectionRule(injectable: ProductsPriorityQuestionViewModel.self) {
                ModelProductsPriorityQuestionViewModel()
            },
            InjectionRule(injectable: QuestionViewModel.self, targetType: ProductsPriority.self) {
                ModelProductsPriorityQuestionViewModel(priority: $0)
            },
            
            // MARK: ArticleItemViewModel
            InjectionRule(injectable: ArticleItemViewModel.self, targetType: Article.self) {
                ModelArticleItemViewModel(article: $0)
            },
            
            // MARK: ArticleViewModel
            InjectionRule(injectable: ArticleViewModel.self, targetType: Article.self) {
                ModelArticleViewModel(article: $0)
            },
            
            // MARK: ProductsCategoryViewModel
            InjectionRule(injectable: ProductsCategoryViewModel.self, targetType: ProductsCategoryInjectionParameter.self) {
                ModelProductsCategoryViewModel(category: $0.category, products: $0.products)
            },
            
            // MARK: StockProductViewModel
            InjectionRule(injectable: StockProductViewModel.self, targetType: StockProduct.self) {
                ModelStockProductViewModel(product: $0)
            },
            
            // MARK: StockProductsCategoryViewModel
            InjectionRule(injectable: StockProductsCategoryViewModel.self, targetType: StockProductsCategoryInjectionParameter.self) {
                ModelStockProductsCategoryViewModel(category: $0.category, products: $0.products)
            },
            
            // MARK: ProductsListViewModel
            InjectionRule(injectable: RequestListViewModel.self, targetType: RequestList.self) {
                ModelRequestListViewModel(requestList: $0)
            },
            
            // MARK: StockViewModel
            InjectionRule(injectable: StockViewModel.self, targetType: Stock.self) {
                ModelStockViewModel(stock: $0)
            },
            
            // MARK: AnalyticViewModel
			InjectionRule(injectable: AnalyticViewModel.self, targetType: Analytic.self) {
				ModelAnalyticVewModel(analytic: $0)
			},
			
            // MARK: ProductViewModel
            InjectionRule(injectable: ProductViewModel.self, targetType: ProductEntry.self) {
                ModelProductViewModel(productEntry: $0)
            },
            InjectionRule(injectable: ProductViewModel.self, targetType: Category.self) {
                ModelProductViewModel(category: $0)
            },
            
            // MARK: ProductItemViewModel
			InjectionRule(injectable: ProductItemViewModel.self, targetType: ProductEntry.self) {
				ModelProductItemViewModel(product: $0)
			},
			
            // MARK: RequestViewModel
            InjectionRule(injectable: RequestViewModel.self, targetType: RequestList.self) {
                ModelRequestViewModel(request: $0)
            },
            
            // MARK: PurchaseViewModel
            InjectionRule(injectable: PurchaseViewModel.self, targetType: RequestList.self) {
                ModelPurchaseViewModel(request: $0)
            },
            
            // MARK: ProfileViewModel
            InjectionRule(injectable: ProfileViewModel.self, targetType: Profile.self) {
                ModelProfileViewModel(profile: $0)
            },
            InjectionRule(injectable: ProfileViewModel.self) {
                ModelInitialProfileViewModel()
            },
            
            // MARK: AddressViewModel
            InjectionRule(injectable: AddressViewModel.self, targetType: Address.self) {
                ModelAddressViewModel(address: $0)
            },
            InjectionRule(injectable: AddressViewModel.self) {
                ModelAddressViewModel()
            },
            
            // MARK: CardViewModel
            InjectionRule(injectable: CardViewModel.self, targetType: Card.self) {
                ModelCardViewModel(card: $0)
            },
            
            // MARK: EditableCardViewModel
			InjectionRule(injectable: EditableCardViewModel.self, targetType: Card.self) {
				ModelEditableCardViewModel(card: $0)
			},
			InjectionRule(injectable: EditableCardViewModel.self) {
				ModelEditableCardViewModel()
			},
			
            // MARK: HomeViewModel
            InjectionRule(injectable: HomeViewModel.self, targetType: HomeInjectionParameter.self) {
				guard let value = ModelHomeViewModel(profile: $0.profile, requests:$0.requests, analytic: $0.analytic) else {
					throw InjectionError.parameterCastingError
				}
				
				return value
            },
            
            // MARK: PickerItemViewModel
            InjectionRule(injectable: PickerItemViewModel.self, targetType: Kind.self) {
                ModelKindPickerItemViewModel(kind: $0)
            },
            // MARK: PickerItemViewModel
            InjectionRule(injectable: PickerItemViewModel.self, targetType: Brand.self) {
                ModelBrandPickerItemViewModel(brand: $0)
            },
            // MARK: PickerItemViewModel
            InjectionRule(injectable: PickerItemViewModel.self, targetType: Volume.self) {
                ModelVolumePickerItemViewModel(volume: $0)
            },
            InjectionRule(injectable: UserInfoViewModel.self, targetType: Profile.self) {
				ModelUserInfoViewModel(profile: $0)
			}
        ]
    }
    
    // MARK: - DataSource Rules
    var dataSourcesRules : [InjectionRule] {
        return [
            InjectionRule(injectable: CommonEmptyResultsCellDataSource.self, targetType: String.self) {
                SimpleEmptyResultDataSource(message: $0)
            },
            
            InjectionRule(injectable: PickerDataSource.self, targetType: StringPickerDataSourceInjectionParameter.self) {
                StringPickerDataSource(title: $0.title, values: $0.values, initialValue: $0.initialValue)
            },
            
            InjectionRule(injectable: PickerDataSource.self, targetType: [Kind].self) {
                ModelKindPickerDataSource(kinds: $0)
            },
            
            InjectionRule(injectable: PickerDataSource.self, targetType: [Brand].self) {
                ModelBrandPickerDataSource(brands: $0)
            },
            
            InjectionRule(injectable: PickerDataSource.self, targetType: [Volume].self) {
                ModelVolumePickerDataSource(volumes: $0)
            },
            
            InjectionRule(injectable: PickerDataSource.self, targetType: PickerInjectionParameter.self) {
                switch $0 {
                case .monthsPicker: return MonthPickerDataSource()
                case .yearsPicker: return YearPickerDataSource()
                }
            },
            
            InjectionRule(injectable: CommonHeaderViewDataSource.self, targetType: String.self) {
                SimpleCommonHeaderViewDataSource(title: $0)
            },
            
            InjectionRule(injectable: CommonHeaderViewStyleSource.self, targetType: ( UIColor, UIColor).self) {
                SimpleCommonHeaderViewStyleSource(titleColor: $0.0, backgroundColor: $0.1)
            }
        ]
    }
    
    // MARK: - Validators Rules
    var valdiatorsRules : [InjectionRule] {
        return [InjectionRule(injectable: [Validator].self, targetType: ValidatorTypeInjectionParameter.self) {
            switch $0 {
            case .loginValidators: return [NilValidator(), EmailValidator()]
            case .passwordValidators: return [NilValidator(), PasswordValidator()]
            case .nameValidators: return [NilValidator(), LengthValidator(minLength: 4)]
            }
            }
        ]
    }
}
