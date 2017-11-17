let kStorageBackToPurchase = "kStorageBackToPurchase"

class ManageCardsViewController: BaseViewController, UIPopoverPresentationControllerDelegate {
    
    fileprivate enum Segues : String {
        case Back = "segBack"
        case PrimaryCard = "segPrimaryCard"
		case Purchase = "segToPurchase"
	}
    
    @IBOutlet weak fileprivate var tvCards: UITableView!
    
    @IBOutlet weak var btnNavAdd: UIButton!
    fileprivate var viewModel : [CardViewModel]!
    fileprivate let emptyViewModel = try! Injector.inject(CommonEmptyResultsCellDataSource.self, with: "You haven't added any cards yet.")
    
    fileprivate var editor : AddCardViewController!
    
    fileprivate let manager = try! Injector.inject(ProfileManager.self)
	fileprivate let cardsManager = try! Injector.inject(CardsManager.self)
    
    var cards : [Card]? {
        return viewModel?.flatMap{$0.card}
    }
    
    fileprivate(set) var selectedCard : Card?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editor = AddCardViewController()
        editor.modalPresentationStyle = .popover
        editor.isModalInPopover = true
        editor.preferredContentSize = CGSize(width: 316, height: 178)
        editor.delegate = self
        
        viewModel = manager.profile?.cards?.flatMap {try! Injector.inject(CardViewModel.self, with: $0)} ?? []
        
        tvCards.rowHeight = UITableViewAutomaticDimension
        tvCards.estimatedRowHeight = ProfilePayMethodCell.height
    }
    override func viewWillAppear(_ animated : Bool) {
        super.viewWillAppear(animated)
        if viewModel.count == 0 {
            showPopover(btnNavAdd)
        }
    }
//    func saveProfile() {
//        if let cards = cards where !isSaved {
//            TSNotifier.showProgressWithMessage("Saving Profile..", onView: view)
//			
//            manager.performSaveProfile(Profile(cards: cards)) {
//				TSNotifier.hideProgress()
//                if case .Success = $0 {
//                    TSNotifier.notify("Profile saved!")
//				} else if case let .Failure(error) = $0 {
//					self.showError(error, errorMessage: "Failed to save profile.".localized)
//				}
//            }
//        }
//    }
	
	func addCardToServer(_ card: Card)
	{
		TSNotifier.showProgress(withMessage: "Adding card...".localized, on: view)
		cardsManager.performAddCard(card) {
			TSNotifier.hideProgress(on: self.view)
			
			if case .success = $0 {
				TSNotifier.notify("Card added!".localized)
				self.viewModel = self.manager.profile?.cards?.flatMap {try! Injector.inject(CardViewModel.self, with: $0)} ?? []
				self.tvCards.reloadData()
				
			} else if case let .failure(error) = $0 {
				self.viewModel.removeLast()
				self.tvCards.reloadData()
				
				self.showError(error, errorMessage: "Failed to add card.".localized)
			}
		}
	}
	
    
    var isSaved : Bool {
        guard let cards = cards else {
            return true
        }
        return !(manager.profile?.cards == nil || cards != manager.profile!.cards!)
    }
    
    @IBAction func addAction(_ sender: UIButton) {
        showPopover(sender)
    }
	
	fileprivate func openPurchase()
	{
		if Storage.temp[kStorageInitialSetup] != nil
		{
			self.dismiss(animated: true, completion: nil)
		}
		else
		{
			performSegue(withIdentifier: Segues.Purchase.rawValue, sender: self)
		}
	}

    
    @IBAction func backAction(_ sender: AnyObject) {
		
		if Storage.temp[kStorageInitialSetup] != nil
		{
			self.dismiss(animated: true, completion: nil)
		}
		else
		{
			performSegue(withIdentifier: Segues.Back.rawValue, sender: self)
		}
    }
    
    func showPopover(_ base: UIView)
    {
        if let popover = editor.popoverPresentationController {
            popover.delegate = self
            popover.sourceView = base
            popover.sourceRect = base.bounds
            popover.permittedArrowDirections = [.up, .down]
            self.present(editor, animated: true, completion: nil)
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension ManageCardsViewController : CardEditorDelegate {
    func editor(_ editor: CardEditor, didEdit newCardViewModel: EditableCardViewModel) {
		guard let card = newCardViewModel.card else {
			print("Invalid card")
			return
		}
		let cardViewModel = try! Injector.inject(CardViewModel.self, with: card)
		
        viewModel.append(cardViewModel)

        if viewModel.count == 1 {
			let indexPath = IndexPath(row: 0, section: 0)
            tvCards.reloadRows(at: [indexPath], with: .automatic)
        } else {
			let indexPath = IndexPath(row: viewModel.count - 1, section: 0)
            tvCards.insertRows(at: [indexPath], with: .automatic)
        }
        //saveProfile()
		addCardToServer(card)
        editor.reset()
        self.dismiss(animated: true, completion: nil)
    }
    func editorDidCancel(_ editor: CardEditor) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ManageCardsViewController : UITableViewDelegate, UITableViewDataSource {
    
    fileprivate func hasCards() -> Bool {
        return viewModel.count > 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hasCards() ? viewModel.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if hasCards() {
            let cell = tableView.dequeueReusableCellOfType(ProfilePayMethodCell.self)
            cell.configure(with: viewModel[indexPath.row])
            return cell
        } else {
            let cell = tableView.dequeueReusableCellOfType(CommonEmptyResultsCell.self)
            cell.configure(with: emptyViewModel)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row > 0 || hasCards()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if hasCards() {
			
			var card = self.viewModel[indexPath.row].card
			card.isPrimary = 1
			self.selectedCard = card
			
			TSNotifier.showProgress(withMessage: "Selecting card...".localized, on: view)
			cardsManager.performSelectCard(selectedCard!, callback: {
				TSNotifier.hideProgress(on: self.view)
				if case .success = $0 {
					TSNotifier.notify("Card selected!".localized)
					
					if Storage.temp[kStorageInitialSetup] != nil
					{
						self.dismiss(animated: true, completion: nil)
					}
					else
					{
						self.performSegue(withIdentifier: Segues.PrimaryCard.rawValue, sender: self)
					}
				} else if case let .failure(error) = $0 {
					self.showError(error, errorMessage: "Card don't selected".localized)
				}
			})
        }
    }
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if case .delete = editingStyle {
			TSNotifier.showProgress(withMessage: "Remove card...".localized, on: view)
			cardsManager.performRemoveCard(viewModel[indexPath.row].card)
			{
				TSNotifier.hideProgress(on: self.view)
				if case .success = $0 {
					TSNotifier.notify("Card removed!".localized)
				} else if case let .failure(error) = $0 {
					self.showError(error, errorMessage: "Card don't removed".localized)
				}
			}
			
			viewModel.remove(at: indexPath.row)
			if viewModel.count == 0
			{
				tableView.reloadRows(at: [indexPath], with: .automatic)
			}
			else
			{
				tableView.deleteRows(at: [indexPath], with: .automatic)
			}
			
		}
	}
	
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return hasCards()
	}
}
