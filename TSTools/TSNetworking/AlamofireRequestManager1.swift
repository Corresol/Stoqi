import Alamofire

/**
 RequestManager is part of TSNetworking layer. It provides a way to do request calls defined by Request objects.
 Key features:
 1. It is designed to be used directly without any sublasses.
 2. Highly configurable via configuration object.
 3. Sync multiple requests.
 4. Simple and obvious way to create request calls.
 
 - Requires:   iOS  [2.0; 8.0)
 - Requires:   
 * TSNetworking framework
 * TSUtils
 
 - Version:    2.0
 - Since:      10/26/2016
 - Author:     AdYa
 */
class AlamofireRequestManager : RequestManager {
    
    fileprivate let manager : Alamofire.Manager
    fileprivate var baseUrl : String?
    fileprivate var defaultHeaders : [String : String]?
    
    func request(_ requestCall : AnyRequestCall, completion : RequestCompletion? = nil) {
        let request = requestCall.request
        let compoundCompletion : AnyResponseResultCompletion = {
            requestCall.completion?($0)
            completion?(Result(responseResult: $0))
        }
        let type = requestCall.responseType
        var aRequest : Alamofire.Request?
        if let multipartRequest = request as? MultipartRequest {
            self.createMultipartRequest(multipartRequest, responseType: type, completion: compoundCompletion) {
                aRequest = $0//.validate()
                self.executeRequest(aRequest, withRequest: request, type: type, completion: compoundCompletion)
            }
        } else {
            aRequest = self.createRegularRequest(request, responseType : type, completion: compoundCompletion)//?.validate()
            self.executeRequest(aRequest, withRequest: request, type: type, completion: compoundCompletion)
        }
        
    }
    
    func request(_ requestCalls : [AnyRequestCall], option : ExecutionOption, completion : ((Result) -> Void)? = nil) {
        switch option {
        case .executeAsynchronously:
            self.asyncRequest(requestCalls, completion: completion)
        case .executeSynchronously(let ignoreFailures):
            self.syncRequest(requestCalls, ignoreFailures: ignoreFailures, completion: completion)
        }
    }
    
    fileprivate func executeRequest(_ aRequest : Alamofire.Request?, withRequest request: Request, type : AnyResponse.Type, completion: @escaping AnyResponseResultCompletion) {
        guard let aRequest = aRequest else {
            print("\(type(of: self)): Failed to execute request: \(request)")
            completion(.failure(error: .invalidRequest))
            return
        }
        print("\(type(of: self)): Executing request: \(request)")
        _ = self.appendResponse(aRequest, request: request, type: type, completion: completion)
    }
    
    required init(configuration: RequestManagerConfiguration) {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = Double(configuration.timeout)
        self.manager = Alamofire.Manager(configuration: sessionConfiguration)
        self.baseUrl = configuration.baseUrl
        self.defaultHeaders = configuration.headers
    }
    
    fileprivate var isReady : Bool {
        return self.baseUrl != nil
    }
    
    
    
}

// MARK: - Multiple requests.
extension AlamofireRequestManager {
    fileprivate func syncRequest(_ requestCalls : [AnyRequestCall], ignoreFailures : Bool, lastResult : Result? = nil, completion : ((Result) -> Void)?) {
        var calls = requestCalls
        guard let call = calls.first else {
            guard let result = lastResult else {
                completion?(.failure(error: .invalidRequest))
                return
            }
            completion?(result)
            return
        }
        self.request(call) { result in
            if ignoreFailures {
                calls.removeFirst()
                self.syncRequest(calls, ignoreFailures: ignoreFailures, lastResult: nil, completion: completion)
                
            } else if case .success = result {
                calls.removeFirst()
                self.syncRequest(calls, ignoreFailures: ignoreFailures, lastResult: .success, completion: completion)
            } else if case .failure(let error) = result{
                completion?(.failure(error: error))
            }
        }
    }
    
    fileprivate func asyncRequest(_ requestCalls : [AnyRequestCall], completion : ((Result) -> Void)?) {
        let group = DispatchGroup()
        var response : Result? = nil
        requestCalls.forEach {
            group.enter()
            self.request($0) { res in
                switch res {
                case .success: response = .success
                case .failure(let error): response = .failure(error: error)
                }
                group.leave()
            }
        }
        group.notify(queue: DispatchQueue.main) {
            if let response = response {
                completion?(response)
            } else {
                completion?(.failure(error: .failedRequest))
            }
        }
    }
}

// MARK: - Constructing request properties.
extension AlamofireRequestManager {
    
    fileprivate func constructUrl(withRequest request: Request) -> String? {
        guard let baseUrl = (request.baseUrl ?? self.baseUrl) else {
            print("\(type(of: self)): Neither default baseUrl nor request's baseUrl had been specified.")
            return nil
        }
        return "\(baseUrl)/\(request.url)"
    }
    
    fileprivate func constructHeaders(withRequest request : Request) -> [String : String]? {
        var headers = self.defaultHeaders
        if let customHeaders = request.headers {
            if headers == nil {
                headers = customHeaders
            } else if headers != nil {
                headers! += customHeaders
            }
        }
        return headers
    }
    
}

// MARK: - Constructing regular Alamofire request
extension AlamofireRequestManager {
    fileprivate func createRegularRequest(_ request : Request, responseType type: AnyResponse.Type, completion : AnyResponseResultCompletion) -> Alamofire.Request? {
        guard let url = self.constructUrl(withRequest: request) else {
            completion(.failure(error:.invalidRequest))
            return nil
        }
        let method = Method(method: request.method)
        let encoding = Alamofire.ParameterEncoding(encoding: request.encoding)
        let headers = self.constructHeaders(withRequest: request)
        return self.manager.request(method, url, parameters: request.parameters, encoding: encoding, headers: headers)
    }
}

// MARK: - Constructing multipart Alamofire request.
extension AlamofireRequestManager {
    
    fileprivate func createMultipartRequest(_ request : MultipartRequest, responseType type: AnyResponse.Type, completion : @escaping AnyResponseResultCompletion, creationCompletion : @escaping (_ createdRequest : Alamofire.Request) -> Void) {
        guard var url = self.constructUrl(withRequest: request) else {
            completion(.failure(error:.invalidRequest))
            return
        }
        let method = Method(method: request.method)
        let headers = self.constructHeaders(withRequest: request)
        var urlParams : [String : AnyObject]?
        var dataParams : [String : AnyObject]? = request.parameters // by default all parameters are dataParams
        if let params = request.parameters {
            urlParams = params.filter {
                if let customEncoding = request.parametersEncodings?[$0.0], customEncoding == RequestEncoding.url {
                    return true
                }
                return false
            }
            if let urlParams = urlParams {
                urlParams.forEach{
                    url = self.encodeURLParam($0.1, withName: $0.0, inURL: url)
                }
                dataParams = params.filter { name, _ in
                    return !urlParams.contains { name == $0.0 }
                }
            }            
            print("\(type(of: self)): Encoded params into url: \(url)\n")
        }
        print("\(type(of: self)): Encoding data for multipart...")
        self.manager.upload(method, url, headers: headers, multipartFormData: { formData in
            if let files = request.files, !files.isEmpty {
                print("\(type(of: self)): Appending \(files.count) in-memory files...\n")
                files.forEach {
                    print("\(type(of: self)): Appending file \($0)...\n")
                    
                    formData.appendBodyPart(data: $0.value, name: $0.name, fileName: $0.fileName, mimeType: $0.mimeType)
                }
                
            }
            if let files = request.filePaths, !files.isEmpty {
                print("\(type(of: self)): Appending \(files.count) files from storage...\n")
                files.forEach{
                    print("\(type(of: self)): Appending file \($0)...\n")
                    formData.appendBodyPart(fileURL: $0.value, name: $0.name)
                }
                
            }
            
            if let dataParams = dataParams {
                dataParams.forEach {
                    print("\(type(of: self)): Encoding parameter '\($0.0)'...")
                    self.appendParam($0.1, withName: $0.0, toFormData: formData, usingEncoding: request.parametersEncoding)
                }
            }
            }
            , encodingCompletion: { encodingResult in
                switch encodingResult {
                case let .Success(aRequest, _, _):
                    creationCompletion(createdRequest: aRequest)
                case .Failure(let error):
                    print("\(type(of: self)): Failed to encode data with error: \(error).")
                    completion(.Failure(error: RequestError.InvalidRequest))
                }
        })
        
    }
    
    fileprivate func createParameterComponent(_ param : AnyObject, withName name : String) -> [(String, String)] {
        var comps = [(String, String)]()
        if let array = param as? [AnyObject] {
            array.forEach {
                comps += self.createParameterComponent($0, withName: "\(name)[]")
            }
        } else if let dictionary = param as? [String : AnyObject] {
            dictionary.forEach { key, value in
                comps += self.createParameterComponent(value, withName: "\(name)[\(key)]")
            }
        } else {
            comps.append((name, "\(param)"))
        }
        return comps
    }
    
    
    fileprivate func encodeURLParam(_ param : AnyObject, withName name : String, inURL url: String) -> String {
        let comps = self.createParameterComponent(param, withName: name).map {"\($0)=\($1)"}
        return "\(url)?\(comps.joined(separator: "&"))"
    }
    
    /// Appends param to the form data.
    fileprivate func appendParam(_ param : AnyObject, withName name : String, toFormData formData : MultipartFormData, usingEncoding encoding: UInt) {
        let comps = self.createParameterComponent(param, withName: name)
        comps.forEach {
            guard let data = $0.1.data(using: String.Encoding(rawValue: encoding)) else {
                print("\(type(of: self)): Failed to encode parameter '\($0.0)'")
                return
            }
            formData.appendBodyPart(data: data, name: $0.0)
        }
    }
}

// MARK: - Constructing Alamofire response.
extension AlamofireRequestManager {
    
    fileprivate func appendResponse(_ aRequest : Alamofire.Request, request : Request, type : AnyResponse.Type, completion: @escaping AnyResponseResultCompletion) -> Alamofire.Request {
        switch type.kind {
        case .json: return aRequest.responseJSON { res in
            if let error = res.result.error {
                print("\(type(of: self)): Internal error while sending request:\n\(error)")
                completion(.Failure(error:.NetworkError))
            } else if let json = res.result.value {
                print("\(type(of: self)): Received JSON:\n\(json).")
                if let response = type.init(request: request, body: json) {
                    completion(ResponseResult.Success(response: response))
                }
                else {
                    print("\(type(of: self)): Specified response type couldn't handle '\(type.kind)'. Response '\(type)' has '\(type.kind)'.")
                    completion(.Failure(error:.InvalidResponseKind))
                }
            } else {
                print("\(type(of: self)): Couldn't get any response.")
                completion(.Failure(error: .FailedRequest))
            }
            }
        case .Data: return aRequest.responseData {res in
            if let error = res.result.error {
                print("\(type(of: self)): Internal error while sending request:\n\(error)")
                completion(.Failure(error:.NetworkError))
            } else if let data = res.result.value {
                print("\(type(of: self)): Received \(data.dataSize) of data.")
                if let response = type.init(request: request, body: data) {
                    completion(ResponseResult.Success(response: response))
                }
                else {
                    print("\(type(of: self)): Specified response type couldn't handle '\(type.kind)' response '\(type)' has '\(type.kind)'.")
                    completion(.Failure(error:.InvalidResponseKind))
                }
            } else {
                print("\(type(of: self)): Couldn't get any response.")
                completion(.Failure(error: .FailedRequest))
            }
            }
        case .String: return aRequest.responseString {res in
            if let error = res.result.error {
                print("\(type(of: self)): Internal error while sending request:\n\(error)")
                completion(.Failure(error:.NetworkError))
            } else if let string = res.result.value {
                print("\(type(of: self)): Received string : \(string).")
                if let response = type.init(request: request, body: string) {
                    completion(ResponseResult.Success(response: response))
                }
                else {
                   print("\(type(of: self)): Specified response type couldn't handle '\(type.kind)' response '\(type)' has '\(type.kind)'.")
                    completion(.Failure(error:.InvalidResponseKind))
                }
            } else {
                print("\(type(of: self)): Couldn't get any response.")
                completion(.Failure(error: .FailedRequest))
            }
            }
        }
    }
}

// MARK: - Mapping abstract enums to Alamofire enums.

extension Alamofire.Method {
    init(method : RequestMethod) {
        switch method {
        case .get: self = .get
        case .post: self = .post
        case .patch: self = .patch
        case .delete: self = .delete
        case .put: self = .put
        }
    }
}

extension Alamofire.ParameterEncoding {
    init(encoding : RequestEncoding) {
        switch encoding {
        case .json: self = .json
        case .url: self = .url
        case .formData: self = .url
        }
    }
}
