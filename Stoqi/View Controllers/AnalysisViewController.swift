import GCDKit

class AnalysisViewController: BaseViewController {
	
	@IBOutlet weak var lSpendingMoney: UILabel!
	@IBOutlet weak var lSpendingPersent: UILabel!
	@IBOutlet weak var lSpendingMoreOrLess: UILabel!
	
	@IBOutlet weak var lConsumption: UILabel!
	
	@IBOutlet weak var lFavoriteVillain: UILabel!
	@IBOutlet weak var lFavoriteVillainValue: UILabel!
	@IBOutlet weak var lFavoriteHero: UILabel!
	@IBOutlet weak var lFavoriteHeroValue: UILabel!
	
	@IBOutlet weak var lWeightClothing: UILabel!
	@IBOutlet weak var lWeightCleaning: UILabel!
	@IBOutlet weak var lWeightOther: UILabel!
	
	fileprivate let manager = try! Injector.inject(AnalyticManager.self)
	fileprivate var viewModel : AnalyticViewModel!
	
    override func viewDidLoad()
	{
        super.viewDidLoad()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if manager.analytic == nil
		{
			loadAnalytic()
		}
		else
		{
			self.viewModel = try! Injector.inject(AnalyticViewModel.self, with: manager.analytic)
			self.configure(with: self.viewModel)
		}
		
	}
    
    override func viewDidLayoutSubviews() {
        self.lFavoriteHero.font = self.lFavoriteVillain.font
    }
	
	func loadAnalytic()
	{
		TSNotifier.showProgress(withMessage: "Loading analytic..".localized, on: self.view)
		self.manager.performLoadAnalytic() {
			TSNotifier.hideProgress(on: self.view)
			switch $0 {
			case .success(let analytic):
				self.viewModel = try! Injector.inject(AnalyticViewModel.self, with: analytic)
			case .failure(let error):
				self.showError(error, errorMessage: "Failed to load your analytic".localized)
				self.viewModel = try! Injector.inject(AnalyticViewModel.self, with: Analytic())
			}
			
			self.configure(with: self.viewModel)
		}
	}
}

extension AnalysisViewController : TSConfigurable
{
	func configure(with dataSource: AnalyticViewModel)
	{
		lSpendingMoney.text = dataSource.spending_Money
		lSpendingPersent.text = dataSource.spending_Persent
		lSpendingMoreOrLess.text = "less"
		lConsumption.text = dataSource.consumption
		lFavoriteVillain.text = dataSource.favorite_Villain
		lFavoriteVillainValue.text = dataSource.favorite_Villain_Value
		lFavoriteHero.text = dataSource.favorite_Hero
		lFavoriteHeroValue.text = dataSource.favorite_Hero_Value
		lWeightCleaning.text = dataSource.cleaning_Weight
		lWeightClothing.text = dataSource.clothing_Weight
		lWeightOther.text = dataSource.other_Weight
	}
}
