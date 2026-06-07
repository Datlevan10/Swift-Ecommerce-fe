//
//  APIClient.swift
//  Swift-Ecommerce-fe
//
//  Created by trustshop on 17/01/2026.
//

import Foundation
import Combine

// MARK: - API Configuration
struct APIConfig {
    static let baseURL = ProcessInfo.processInfo.environment["API_URL"] ?? "http://localhost:3000/api"
    static let timeout: TimeInterval = 30.0
    
    static var headers: [String: String] {
        return [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
}

// MARK: - API Error
enum APIError: LocalizedError {
    case invalidURL
    case noData
    case decodingError(String)
    case networkError(String)
    case unauthorized
    case forbidden
    case notFound
    case serverError(String)
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError(let message):
            return "Decoding error: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .unauthorized:
            return "Please login to continue"
        case .forbidden:
            return "You do not have permission to perform this action"
        case .notFound:
            return "The requested resource was not found"
        case .serverError(let message):
            return "Server error: \(message)"
        case .unknown(let message):
            return message
        }
    }
}

// MARK: - Response Models
struct SuccessResponse<T: Codable>: Codable {
    let success: Bool
    let data: T
    let message: String?
    let count: Int?
    let pagination: Pagination?
}

struct ErrorResponse: Codable {
    let success: Bool
    let error: String
}

struct Pagination: Codable {
    let page: Int
    let limit: Int
    let total: Int
    let totalPages: Int
}

// MARK: - API Client
class APIClient {
    static let shared = APIClient()
    private let session: URLSession
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = APIConfig.timeout
        configuration.timeoutIntervalForResource = APIConfig.timeout
        self.session = URLSession(configuration: configuration)
    }
    
    // MARK: - Request Methods
    func request<T: Codable>(
        _ endpoint: String,
        method: HTTPMethod = .get,
        parameters: [String: Any]? = nil,
        body: Encodable? = nil,
        headers: [String: String]? = nil
    ) async throws -> T {
        guard let url = buildURL(endpoint: endpoint, parameters: parameters) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // Set headers
        var allHeaders = APIConfig.headers
        
        // Add auth token if available
        if let token = KeychainService.shared.getAccessToken() {
            allHeaders["Authorization"] = "Bearer \(token)"
        }
        
        // Merge custom headers
        if let customHeaders = headers {
            allHeaders.merge(customHeaders) { _, new in new }
        }
        
        allHeaders.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        // Set body
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.unknown("Invalid response")
            }
            
            // Handle different status codes
            switch httpResponse.statusCode {
            case 200...299:
                // Success
                if T.self == EmptyResponse.self {
                    return EmptyResponse() as! T
                }
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                do {
                    let successResponse = try decoder.decode(SuccessResponse<T>.self, from: data)
                    return successResponse.data
                } catch {
                    // Try decoding directly as T
                    return try decoder.decode(T.self, from: data)
                }
                
            case 401:
                // Try to refresh token
                if await refreshTokenIfNeeded() {
                    // Retry the request
                    return try await self.request(endpoint, method: method, parameters: parameters, body: body, headers: headers)
                } else {
                    throw APIError.unauthorized
                }
                
            case 403:
                throw APIError.forbidden
                
            case 404:
                throw APIError.notFound
                
            case 400...499:
                // Client error
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    throw APIError.unknown(errorResponse.error)
                } else {
                    throw APIError.unknown("Request failed")
                }
                
            case 500...599:
                // Server error
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    throw APIError.serverError(errorResponse.error)
                } else {
                    throw APIError.serverError("Server error")
                }
                
            default:
                throw APIError.unknown("Unexpected status code: \(httpResponse.statusCode)")
            }
            
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error.localizedDescription)
        }
    }
    
    // MARK: - Multipart Request (for file uploads)
    func uploadMultipart<T: Codable>(
        _ endpoint: String,
        parameters: [String: String]? = nil,
        files: [(name: String, fileName: String, data: Data)]? = nil
    ) async throws -> T {
        guard let url = buildURL(endpoint: endpoint, parameters: nil) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Add auth token if available
        if let token = KeychainService.shared.getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        var body = Data()
        
        // Add parameters
        if let parameters = parameters {
            for (key, value) in parameters {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                body.append("\(value)\r\n".data(using: .utf8)!)
            }
        }
        
        // Add files
        if let files = files {
            for file in files {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(file.name)\"; filename=\"\(file.fileName)\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)
                body.append(file.data)
                body.append("\r\n".data(using: .utf8)!)
            }
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw APIError.unknown("Upload failed")
        }
        
        let decoder = JSONDecoder()
        let successResponse = try decoder.decode(SuccessResponse<T>.self, from: data)
        return successResponse.data
    }
    
    // MARK: - Helper Methods
    private func buildURL(endpoint: String, parameters: [String: Any]?) -> URL? {
        var urlString = "\(APIConfig.baseURL)\(endpoint)"
        
        if let parameters = parameters {
            var components = URLComponents(string: urlString)
            components?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
            return components?.url
        }
        
        return URL(string: urlString)
    }
    
    private func refreshTokenIfNeeded() async -> Bool {
        guard let refreshToken = KeychainService.shared.getRefreshToken() else {
            return false
        }
        
        do {
            let response: RefreshTokenResponse = try await request(
                "/auth/refresh-token",
                method: .post,
                body: RefreshTokenRequest(refreshToken: refreshToken)
            )
            
            KeychainService.shared.saveAccessToken(response.accessToken)
            KeychainService.shared.saveRefreshToken(response.refreshToken)
            
            return true
        } catch {
            // Clear tokens on refresh failure
            KeychainService.shared.clearTokens()
            return false
        }
    }
}

// MARK: - HTTP Methods
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

// MARK: - Empty Response
struct EmptyResponse: Codable {}

// MARK: - Refresh Token Models
struct RefreshTokenRequest: Codable {
    let refreshToken: String
}

struct RefreshTokenResponse: Codable {
    let accessToken: String
    let refreshToken: String
}
