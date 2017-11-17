/// Defines multipart request properties required to perform request call.
protocol MultipartRequest : Request {
    
    /// File representations with raw data.
    /// - Note: Default = nil.
    var files : [File<Data>]? {get}
    
    /// File representations with URL paths.
    /// - Note: Default = nil.
    var filePaths : [File<URL>]? {get}
    
    /// Defines how parameters should be encoded when embedding into multi-part request.
    /// - Note: Default = NSUTF8StringEncoding.
    var parametersEncoding : UInt {get}
}

/// Represents a file to be uploaded
struct File<T> : CustomStringConvertible {
    let name : String
    let value : T
    let fileName : String
    let mimeType : String
    public var description : String {
        get{
            return "\(name)"
        }
    }
}

// MARK: Defaults
extension MultipartRequest {
    var files : [File<Data>]? {
        return nil
    }
    
    var filePaths : [File<URL>]? {
        return nil
    }
    
    var parametersEncoding : UInt {
        return String.Encoding.utf8.rawValue
    }
    
    var encoding : RequestEncoding {
        return .formData
    }
    
    var description: String {
        var descr = "\(self.method) '"
        if let baseUrl = self.baseUrl {
            descr += "\(baseUrl)/"
        }
        descr += "\(self.url)'"
        if let headers = self.headers {
            descr += "\nHeaders:\n\(headers)"
        }
        if let params = self.parameters {
            descr += "\nParameters:\n\(params)"
        }
        if let files = self.files {
            descr += "\nFiles:\n"
            files.forEach{
                descr += "\($0.name) of type '\($0.mimeType)' (size: \($0.value.dataSize))\n"
            }
        } else if let files = self.filePaths {
            descr += "\n Files:\n"
            files.forEach{
                descr += "\($0.name) of type '\($0.mimeType)' (at: \($0.value.absoluteString))\n"
            }
        }
        return descr
    }
}

extension File where T == Data {
    var description: String {
        return "\(self.name). Type: \(self.mimeType). "//Size: \(self.value.dataSize).
    }
}

extension File where T == URL {
    var description: String {
        return "\(self.name). Type: \(self.mimeType). ."//Path: \(self.value.absoluteString)
    }
    var filename : String {
        return ""
    }
}
