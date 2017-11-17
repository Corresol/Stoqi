/// Dummy rules
struct DummyInjectionPreset : InjectionRulesPreset {

    var rules : [InjectionRule] = []
	
	fileprivate var dummyProfileManager : ProfileManager {
		return try! Injector.inject(ProfileManager.self)
	}
	
	fileprivate var productsManager : ProductsManager {
		return try! Injector.inject(ProductsManager.self)
	}

	
    init() {
        var compoundRules : [InjectionRule] = []
        compoundRules += self.managersRules
        compoundRules += self.valdiatorsRules
        self.rules = compoundRules
    }
    
    // MARK: - Manager Rules
    var managersRules : [InjectionRule] {
        return [InjectionRule(injectable: AuthorizationManager.self, injected: DummyAuthorizationManager()),
                InjectionRule(injectable: ProfileManager.self, injected: DummyProfileManager()),
                InjectionRule(injectable: ArticlesManager.self, injected: DummyArticlesManager()),
                InjectionRule(injectable: ProductsManager.self, injected: DummyProductsManager()),
                InjectionRule(injectable: RequestsManager.self, injected: DummyRequestsManager(productsManager: self.productsManager)),
                InjectionRule(injectable: StockManager.self, injected: DummyStockManager(productsManager: self.productsManager)),
                InjectionRule(injectable: CardsManager.self, injected: DummyCardsManager(profileManager: self.dummyProfileManager)),
                InjectionRule(injectable: AnalyticManager.self, injected: DummyAnalyticManager())
        ]
    }
    
}

// MARK: - Validation Rules
extension DummyInjectionPreset {
    
    fileprivate var loginValidators : [Validator] {
        return [NilValidator(), LengthValidator(minLength: 4)]
//        return try! Injector.inject([Validator].self, with: ValidatorTypeInjectionParameter.loginValidators)
    }
    
    fileprivate var passwordValidators : [Validator] {
        return [NilValidator(), LengthValidator(minLength: 4)]
//        return try! Injector.inject([Validator].self, with: ValidatorTypeInjectionParameter.passwordValidators)
    }
    
    var valdiatorsRules : [InjectionRule] {
        return [InjectionRule(injectable: [Validator].self, targetType: ValidatorTypeInjectionParameter.self) {
            switch $0 {
            case .loginValidators: return [NilValidator(), LengthValidator(minLength: 4)]
            case .passwordValidators: return [NilValidator(), LengthValidator(minLength: 4)]
            case .nameValidators: return [NilValidator(), LengthValidator(minLength: 4)]
            }
            }
        ]
    }
}
