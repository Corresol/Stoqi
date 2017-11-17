import MTBBarcodeScanner

class ScannerViewController: BaseViewController {

    fileprivate static let segScanned = "segScanned"
    
    fileprivate let manager = try! Injector.inject(ProductsManager.self)
    
    fileprivate var scanner : MTBBarcodeScanner!
    
    @IBOutlet fileprivate weak var vCamera: UIView!
    
    
    fileprivate(set) var product : Product?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scanner = MTBBarcodeScanner(previewView: vCamera)
        //scanner.camera = .Back
        startScanner()
    }

    fileprivate func requestScanner() {
        MTBBarcodeScanner.requestCameraPermission(success: {
            if $0 {
                self.startScanner()
            }
        })
    }
    
    fileprivate func startScanner() {
        guard MTBBarcodeScanner.cameraIsPresent() else {
            TSNotifier.notify("You haven't got a camera :(", on: self.view)
            return
        }
        guard !MTBBarcodeScanner.scanningIsProhibited() else {
            requestScanner()
            return
        }
		
		do {
			try scanner.startScanning(resultBlock: {
				guard let code = $0?.first as? String else {
					return
				}
				self.scanner.stopScanning()
				TSNotifier.showProgress(on: self.view)
				self.manager.performFindProduct(code, callback: {
					TSNotifier.hideProgress()
					if case .success(let product) = $0 {
						self.product = product
						self.performSegue(withIdentifier: type(of: self).segScanned, sender: self)
					} else {
						TSNotifier.notify("Uknown product", on: self.view)
						self.startScanner()
					}
				})
				}
			)
		} catch {
			
		}
		
		
    }
}
