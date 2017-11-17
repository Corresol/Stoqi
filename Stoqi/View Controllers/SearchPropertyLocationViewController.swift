import UIKit
import IQKeyboardManagerSwift
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class SearchPropertyLocationViewController : StandaloneViewController {
    
    @IBOutlet weak fileprivate var aiSearchActivity: UIActivityIndicatorView!
    @IBOutlet weak fileprivate var tvSearchResults: UITableView!
    @IBOutlet weak fileprivate var tfSearch: UITextField!
    
    fileprivate let manager = try! Injector.inject(ProfileManager.self)
    
    fileprivate var viewModel = try! Injector.inject(SearchQueryViewModel.self) {
        didSet {
            self.configure(with: self.viewModel)
        }
    }
    fileprivate let emptyResultsVM  = try! Injector.inject(CommonEmptyResultsCellDataSource.self, with: "Sorry, we don't know such city.")
    
    var hasResults : Bool {
        return !(self.viewModel.results.isEmpty)
    }
    
    fileprivate(set) var selectedViewModel : SearchPropertyLocationViewModel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tfSearch.addDoneOnKeyboardWithTarget(self, action: #selector(triggerSearch), titleText: "Search")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.configure(with: self.viewModel)
        super.viewWillAppear(animated)
    }
}

// MARK: - Controller (ViewModel <=> DataManager)
private extension SearchPropertyLocationViewController {
    
    @objc func triggerSearch() {
        if let query = self.viewModel.query {
            self.search(withTerm: query)
        } else {
            print("\(type(of: self)): Empty query.")
        }
        self.view.endEditing(true)
    }
    
    func search(withTerm term: String) {
        guard !self.viewModel.isSearching else {
            print("\(type(of: self)): Search in progress.")
            return // busy
        }
		
		let charactersToRemove = CharacterSet.alphanumerics.inverted
		let str = term.components(separatedBy: charactersToRemove).joined(separator: " ")
		
        self.viewModel.isSearching = true
        self.manager.performSearchPropertyLocation(withTerm: str) { result in
            self.viewModel.isSearching = false
            if case .success(let locations) = result {
                self.viewModel.results = locations.flatMap { try? Injector.inject(SearchPropertyLocationViewModel.self, with:SearchPropertyLocationInjectionParameter(location: $0, matchingTerm: str))
                }
                self.tvSearchResults.reloadData()
            }
        }
    }

}

// MARK: - Interactor (View => ViewModel)
private extension SearchPropertyLocationViewController {
    @IBAction func searchChanged(_ sender: AnyObject) {
        self.viewModel.query = self.tfSearch.text
        if self.tfSearch.text?.characters.count >= 3 {
            if let query = self.viewModel.query {
                self.search(withTerm: query)
            } else {
                print("\(type(of: self)): Empty query.")
            }
        }
    }
}

// MARK: - Presenter (ViewModel => View)
extension SearchPropertyLocationViewController : TSConfigurable {
    func configure(with dataSource: SearchQueryViewModel) {
        if dataSource.isSearching {
            self.aiSearchActivity.startAnimating()
        } else {
            self.aiSearchActivity.stopAnimating()
        }
    }
}

// MARK: - TableView Presenter (ViewModel => View)
extension SearchPropertyLocationViewController : UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.results.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.hasResults {
            let cell = tableView.dequeueReusableCellOfType(SearchCityContentCell.self)
            cell.configure(with: self.viewModel.results[indexPath.row])
            return cell
        } else {
            let cell = tableView.dequeueReusableCellOfType(CommonEmptyResultsCell.self)
            cell.configure(with: self.emptyResultsVM)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedViewModel = self.viewModel.results[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        self.selectedViewModel = self.viewModel.results[indexPath.row]
        return indexPath
    }
    
}
