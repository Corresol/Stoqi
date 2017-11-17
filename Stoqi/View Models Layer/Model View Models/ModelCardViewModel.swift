struct ModelCardViewModel : CardViewModel {
	let card : Card
	
	var cardNumber: String {
		return card.number
	}
	
	var cardTypeImage: UIImage {
		return UIImage(named: "credit_card_icon")!
	}
	
	var isPrimary: Bool {
		return card.isPrimary == 1
	}
	
	var isValid: Bool {
		return true
	}
	
}
