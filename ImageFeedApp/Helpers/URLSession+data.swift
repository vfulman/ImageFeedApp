import UIKit

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidRequest
    case duplicateRequest
    case decodingError
    
    var description: String {
        switch self {
        case .httpStatusCode(let int):
            return "NetworkError - status code \(int)"
        case .urlRequestError(let error):
            return "NetworkError - request error \(error)"
        case .urlSessionError:
            return "NetworkError - session error"
        case .invalidRequest:
            return "NetworkError - invalid request"
        case .duplicateRequest:
            return "NetworkError - duplicate request"
        case .decodingError:
            return "NetworkError - decoding error"
        }
    }
    
}

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, NetworkError>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, NetworkError>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    print("URLSession: Network error \(NetworkError.httpStatusCode(statusCode))")
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                print("URLSession: Network error \(NetworkError.urlRequestError(error))")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                print("URLSession: Network error \(NetworkError.urlSessionError)")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
            }
        })
        
        return task
    }
}

extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        let task = URLSession.shared.data(for: request) { (result: Result<Data, NetworkError>) in
            switch result {
            case .failure(let error):
                print("URLSession: Error \(error.description)")
                completion(.failure(error))
            case .success(let data):
                do {
                    let tokenData = try decoder.decode(T.self, from: data)
                    completion(.success(tokenData))
                } catch {
                    print("URLSession: Decoding error: \(error.localizedDescription), Data: \(String(data: data, encoding: .utf8) ?? "")")
                    completion(.failure(NetworkError.decodingError))
                }
            }
        }
        return task
    }
}
