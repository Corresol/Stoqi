/// Defines how `CompoundValidator` should treat specified set of `Validators`.
enum ValidationConjunction {
    
    /// Valid if all provided validators are valid.
    case all
    
    /// Valid if at least one of provided validators is valid.
    case any
    
    /// Valid if all provided validators are not valid.
    case none
}

struct CompoundValidator : Validator {
    let conjunction : ValidationConjunction
    let validators : [Validator]
    
    var failedMessage: String {
        return self.validators.map{$0.failedMessage}.joined(separator: ", ")
    }
    
    init(validators : [Validator], conjunction : ValidationConjunction = .all) {
        self.conjunction = conjunction
        self.validators = validators
    }
    
    func validate(_ value: Any?) -> Bool {
        guard self.validators.count > 0 else {
            print("\(type(of: self)): No validators provided.")
            return true
        }
        let passed = self.validators.filter{$0.validate(value)}
        switch self.conjunction {
        case .all: return self.validators.count == passed.count
        case .any: return passed.count > 0
        case .none: return passed.count == 0
        }
    }
}

// MARK: .All
func & (v1 : Validator, v2 : Validator) -> Validator {
    return CompoundValidator(validators: [v1, v2], conjunction: .all)
}

func & (v1 : [Validator], v2 : [Validator]) -> Validator {
    return CompoundValidator(validators: v1 + v2, conjunction: .all)
}

func & (v1 : [Validator], v2 : Validator) -> Validator {
    return v1 & [v2]
}

func & (v1 : Validator, v2 : [Validator]) -> Validator {
    return [v1] & v2
}

// MARK: .Any
func | (v1 : Validator, v2 : Validator) -> Validator {
    return CompoundValidator(validators: [v1, v2], conjunction: .any)
}

func | (v1 : [Validator], v2 : [Validator]) -> Validator {
    return CompoundValidator(validators: v1 + v2, conjunction: .any)
}

func | (v1 : [Validator], v2 : Validator) -> Validator {
    return v1 | [v2]
}

func | (v1 : Validator, v2 : [Validator]) -> Validator {
    return [v1] | v2
}

// MARK: .None
func ^ (v1 : Validator, v2 : Validator) -> Validator {
    return CompoundValidator(validators: [v1, v2], conjunction: .none)
}

func ^ (v1 : [Validator], v2 : [Validator]) -> Validator {
    return CompoundValidator(validators: v1 + v2, conjunction: .none)
}

func ^ (v1 : [Validator], v2 : Validator) -> Validator {
    return v1 ^ [v2]
}

func ^ (v1 : Validator, v2 : [Validator]) -> Validator {
    return [v1] ^ v2
}

