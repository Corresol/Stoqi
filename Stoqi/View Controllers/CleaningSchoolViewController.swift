class CleaningSchoolViewController: RefreshableBaseViewController {
    
    typealias `Self` = CleaningSchoolViewController
    
    fileprivate static let segOpenArticle = "segReadMore"
    
    fileprivate let manager = try! Injector.inject(ArticlesManager.self)
    
    fileprivate var viewModel : [ArticleItemViewModel] = [] {
        didSet {
            self.tvArticles?.reloadData()
        }
    }
    
    fileprivate var selectedArticle : ArticleItemViewModel? {
        didSet {
            self.performSegue(withIdentifier: Self.segOpenArticle, sender: self)
        }
    }
    
    @IBAction func unwindArticle(_ segue : UIStoryboardSegue) { }
    
    @IBOutlet weak fileprivate var tvArticles: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tvArticles.rowHeight = UITableViewAutomaticDimension
        self.tvArticles.estimatedRowHeight = ArticleCell.height
        //if self.manager.articles == nil {
            self.loadArticles()
        //}
    }
    
    func refresh(_ sender: UIRefreshControl) {
        self.loadArticles(true)
    }
    
    fileprivate func loadArticles(_ refreshing : Bool = false) {
        if !refreshing {
            TSNotifier.showProgress(withMessage: "Loading..", on: self.view)
        }
        self.manager.performLoadArticles {
            if refreshing {
                self.refreshing = false
                if case .success = $0 {
                    self.updateRefresher()
                }
            } else {
                TSNotifier.hideProgress()
            }
            if case .success(let articles) = $0 {
                self.viewModel = articles.flatMap {try? Injector.inject(ArticleItemViewModel.self, with: $0)}
            }
        }
    }
    
    // MARK: - Refresher Implementation
    override func refresh() {
        self.loadArticles(true)
    }
    
    override var refresherTableView: UITableView? {
        return self.tvArticles
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier, id == Self.segOpenArticle else {
            return
        }
        
        guard let controller = segue.destination as? ReadArticleViewController else {
            return
        }
        
        controller.setArticle(self.selectedArticle!.article)
    }
}

// MARK: - TableView Presenter (ViewModel => View)
extension CleaningSchoolViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellOfType(ArticleCell.self)
        let articleViewModel = self.viewModel[indexPath.row]
        cell.configure(with: articleViewModel)
        cell.style(with: articleViewModel)
        cell.delegate = { self.selectedArticle = articleViewModel }
        return cell
    }
}
