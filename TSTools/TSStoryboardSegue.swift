class TSStoryboardSegue: UIStoryboardSegue {
	var completion: (() -> Void)?
	
	override func perform() {
		super.perform()
		if let completion = completion {
			completion()
		}
	}
}