
class ReadArticleViewController : BaseViewController {
    
    @IBOutlet weak var svContent: UIScrollView!
    @IBOutlet weak var ivArticleImage: UIImageView!
    @IBOutlet weak var tvContent: UITextView!
    
    fileprivate var viewModel : ArticleViewModel!
    
    func setArticle(_ article : Article) {
        self.viewModel = try! Injector.inject(ArticleViewModel.self, with: article)
    }
    
    override func viewWillAppear(_ animated : Bool) {
        super.viewWillAppear(animated)
        self.configure(with: self.viewModel)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.adjustScrollContent()
    }
	
	@IBAction func onShareButton(_ sender: AnyObject) {
		let alert = UIAlertController(title: "Stoqi".localized, message: nil, preferredStyle: .actionSheet)
		alert.addAction(UIAlertAction(title: "Share in FaceBook".localized, style: .default, handler: { _ in
			self.shareOnFacebook(nil)
		}))
		alert.addAction(UIAlertAction(title: "Share in Twitter".localized, style: .default, handler: { _ in
			self.shareOnTwitter(nil)
		}))
		alert.addAction(UIAlertAction(title: "Share in WhatsApp".localized, style: .default, handler: { _ in
			self.shareOnWathApp(nil)
		}))
		alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
		
		if let popoverController = alert.popoverPresentationController {
			popoverController.sourceView = sender as! UIButton
			popoverController.sourceRect = sender.bounds
		}
		self.present(alert, animated: true, completion: nil)
	}
}

extension ReadArticleViewController : TSConfigurable {
   
    func configure(with dataSource: ArticleViewModel) {
        self.ivArticleImage.image = dataSource.image
        self.tvContent.attributedText = self.buildArticleContent(dataSource.title, paragraphs: dataSource.paragraphs)
        self.view.setNeedsLayout()
    }
    
    fileprivate func adjustScrollContent() {
        let size = self.tvContent.sizeThatFits(CGSize(width: self.view.bounds.width, height: CGFloat.infinity))
        self.tvContent.frame.size = CGSize(width: self.tvContent.frame.width, height: size.height)
        self.svContent.contentSize = CGSize(width: size.width, height: self.ivArticleImage.frame.height + size.height)

    }
    
    fileprivate func buildArticleContent(_ title : String, paragraphs : [(String, String)]) -> NSAttributedString {
        let attrString = NSMutableAttributedString()
        attrString.append(self.buildArticleTitle("\(title)\n\n"))
        paragraphs.forEach {
            attrString.append(self.buildParagraphTitle("\($0.0)\n\n"))
            attrString.append(NSAttributedString(string: "\($0.1)\n\n"))
        }
        
        // Set Justify alignment
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.justified
       
        attrString.addAttributes([
            NSParagraphStyleAttributeName: paragraphStyle,
            NSBaselineOffsetAttributeName: 0
            ], range: attrString.string.nsrange)
        return NSAttributedString(attributedString: attrString)
    }
    
    fileprivate func buildParagraphTitle(_ title : String) -> NSAttributedString {
        return NSAttributedString(string: title, attributes: [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 14),
            NSForegroundColorAttributeName : StoqiPallete.darkGrayTextColor])
    }
    fileprivate func buildArticleTitle(_ title : String) -> NSAttributedString {
        return NSAttributedString(string: title, attributes: [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 16),
            NSForegroundColorAttributeName : StoqiPallete.mainColor])
    }
}
