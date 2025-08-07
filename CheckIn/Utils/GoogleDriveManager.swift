//
//  GoogleDriveManager.swift
//  CheckIn
//
//  Created by Ahmad Shaheer on 28/07/2025.
//

import Foundation
import GoogleAPIClientForRESTCore
import GoogleAPIClientForREST_Drive
import GoogleSignIn

class GoogleDriveManager: ObservableObject, @unchecked Sendable {
    static let shared = GoogleDriveManager()
    
    private let service = GTLRDriveService()
    private var isAuthenticated = false
    
    // Google Drive folder cache
    private var dailyFolderCache: [String: String] = [:] // Date string -> Folder ID
    private var mainFolderCache: String? // Main "Check-In" folder ID
    
    // Authentication cache keys
    private let authenticationStatusKey = "GoogleDriveAuthenticationStatus"
    private let lastAuthenticationDateKey = "GoogleDriveLastAuthenticationDate"
    
    private init() {
        setupGoogleDrive()
    }
    
    // MARK: - Setup
    private func setupGoogleDrive() {
        // Ensure setup is performed on main thread to avoid UI access warnings
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
                  let plist = NSDictionary(contentsOfFile: path),
                  let clientId = plist["CLIENT_ID"] as? String else {
                print("❌ GoogleService-Info.plist not found or CLIENT_ID missing")
                return
            }
            
            let config = GIDConfiguration(clientID: clientId)
            GIDSignIn.sharedInstance.configuration = config
            
            // Check if user is already signed in with proper scopes
            if let currentUser = GIDSignIn.sharedInstance.currentUser {
                let driveScope = "https://www.googleapis.com/auth/drive.file"
                let grantedScopes = currentUser.grantedScopes ?? []
                
                if grantedScopes.contains(driveScope) {
                    // Verify the token is still valid
                    self.verifyAndSetupAuthentication(for: currentUser)
                } else {
                    print("⚠️ User signed in but missing Google Drive scopes. Will request on next authentication.")
                    self.isAuthenticated = false
                    UserDefaults.standard.set(false, forKey: self.authenticationStatusKey)
                }
            } else {
                print("🔐 Google Drive authentication required on first use")
                self.isAuthenticated = false
                UserDefaults.standard.set(false, forKey: self.authenticationStatusKey)
            }
        }
    }
    
    // MARK: - Authentication Helper
    private func verifyAndSetupAuthentication(for user: GIDGoogleUser) {
        // Check if the access token needs refreshing
        let accessToken = user.accessToken
        if let expirationDate = accessToken.expirationDate,
           expirationDate.timeIntervalSinceNow > 300 { // At least 5 minutes remaining
            // Token is still valid, use it
            self.service.authorizer = user.fetcherAuthorizer
            self.isAuthenticated = true
            self.saveAuthenticationStatus(true)
            print("✅ Google Drive already authenticated with valid token (expires: \(expirationDate.description))")
        } else {
            // Token is expired or expiring soon, refresh it
            print("🔄 Access token expired or expiring, refreshing...")
            user.refreshTokensIfNeeded { [weak self] user, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("❌ Token refresh failed: \(error.localizedDescription)")
                        self?.isAuthenticated = false
                        self?.saveAuthenticationStatus(false)
                    } else if let refreshedUser = user {
                        self?.service.authorizer = refreshedUser.fetcherAuthorizer
                        self?.isAuthenticated = true
                        self?.saveAuthenticationStatus(true)
                        print("✅ Google Drive token refreshed successfully")
                    } else {
                        print("❌ Token refresh returned no user")
                        self?.isAuthenticated = false
                        self?.saveAuthenticationStatus(false)
                    }
                }
            }
        }
    }
    
    private func saveAuthenticationStatus(_ isAuthenticated: Bool) {
        UserDefaults.standard.set(isAuthenticated, forKey: authenticationStatusKey)
        if isAuthenticated {
            UserDefaults.standard.set(Date(), forKey: lastAuthenticationDateKey)
        }
        print("💾 Saved authentication status: \(isAuthenticated)")
    }
    
    // MARK: - Authentication
    
    /// Check if user is already authenticated with Google Drive scopes
    func isAlreadyAuthenticated() -> Bool {
        // First check our internal authentication status
        guard isAuthenticated else {
            print("🔍 Internal authentication status: false")
            return false
        }
        
        // Check if we have a current user with valid token
        guard let currentUser = GIDSignIn.sharedInstance.currentUser else {
            print("🔍 No current Google user found")
            isAuthenticated = false
            saveAuthenticationStatus(false)
            return false
        }
        
        // Check if user has the required Google Drive scope
        let grantedScopes = currentUser.grantedScopes ?? []
        let hasRequiredScope = grantedScopes.contains("https://www.googleapis.com/auth/drive.file")
        
        if !hasRequiredScope {
            print("⚠️ User lacks Google Drive scope. Resetting authentication.")
            isAuthenticated = false
            saveAuthenticationStatus(false)
            return false
        }
        
        // Check if token is still valid (at least 5 minutes remaining)
        let accessToken = currentUser.accessToken
        if let expirationDate = accessToken.expirationDate,
           expirationDate.timeIntervalSinceNow > 300 {
            print("✅ Authentication valid (expires: \(expirationDate))")
            return true
        } else {
            print("⚠️ Access token expired or expiring soon")
            // Don't immediately set as unauthenticated - the refresh will handle this
            return false
        }
    }
    
    /// Clear existing authentication to force re-authentication with proper scopes
    func clearAuthentication() {
        isAuthenticated = false
        service.authorizer = nil
        dailyFolderCache.removeAll()
        mainFolderCache = nil
        saveAuthenticationStatus(false)
        GIDSignIn.sharedInstance.signOut()
        print("🔄 Cleared existing authentication. User will need to re-authenticate with Google Drive scopes.")
    }
    
    func authenticate() async throws {
        // Ensure we get the presenting view controller on the main thread
        let presentingViewController = await MainActor.run { () -> UIViewController? in
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else {
                return nil
            }
            return window.rootViewController
        }
        
        guard let presentingViewController = presentingViewController else {
            throw GoogleDriveError.noViewController
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            // Ensure Google Sign-In is called on the main thread
            DispatchQueue.main.async {
                // Request Google Drive scopes during authentication
                let driveScopes = ["https://www.googleapis.com/auth/drive.file"]
                
                GIDSignIn.sharedInstance.signIn(
                    withPresenting: presentingViewController,
                    hint: nil,
                    additionalScopes: driveScopes
                ) { [weak self] result, error in
                    if let error = error {
                        print("❌ Google Sign-In failed: \(error.localizedDescription)")
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    guard let user = result?.user else {
                        print("❌ No user returned from Google Sign-In")
                        continuation.resume(throwing: GoogleDriveError.authenticationFailed)
                        return
                    }
                    
                    // Verify that we have the required scopes
                    let grantedScopes = user.grantedScopes ?? []
                    let hasRequiredScope = grantedScopes.contains("https://www.googleapis.com/auth/drive.file")
                    
                    if hasRequiredScope {
                        self?.service.authorizer = user.fetcherAuthorizer
                        self?.isAuthenticated = true
                        self?.saveAuthenticationStatus(true)
                        print("✅ Google Drive authenticated successfully with required scopes for user: \(user.profile?.email ?? "Unknown")")
                        print("🔑 Granted scopes: \(grantedScopes)")
                        continuation.resume()
                    } else {
                        print("❌ Google Drive scope not granted. Granted scopes: \(grantedScopes)")
                        self?.saveAuthenticationStatus(false)
                        continuation.resume(throwing: GoogleDriveError.authenticationFailed)
                    }
                }
            }
        }
    }
    
    // MARK: - Folder Management
    func getMainFolderId() async throws -> String {
        let mainFolderName = "Check-In"
        
        // Check cache first
        if let cachedMainFolderId = mainFolderCache {
            print("📁 Using cached main folder ID for \(mainFolderName): \(cachedMainFolderId)")
            return cachedMainFolderId
        }
        
        // Search for existing main folder
        if let existingMainFolderId = try await findFolder(named: mainFolderName) {
            mainFolderCache = existingMainFolderId
            print("📁 Found existing main folder \(mainFolderName): \(existingMainFolderId)")
            return existingMainFolderId
        }
        
        // Create new main folder
        let newMainFolderId = try await createFolder(named: mainFolderName)
        mainFolderCache = newMainFolderId
        print("📁 Created new main folder \(mainFolderName): \(newMainFolderId)")
        return newMainFolderId
    }
    
    func getDailyFolderId(for date: Date = Date()) async throws -> String {
        let dateString = formatDateForFolder(date)
        let folderName = "Check-In \(dateString)"
        
        // Check cache first
        if let cachedFolderId = dailyFolderCache[dateString] {
            print("📁 Using cached folder ID for \(folderName): \(cachedFolderId)")
            return cachedFolderId
        }
        
        // Get or create main "Check-In" folder first
        let mainFolderId = try await getMainFolderId()
        
        // Search for existing date folder inside main folder
        if let existingFolderId = try await findFolder(named: folderName, parentId: mainFolderId) {
            dailyFolderCache[dateString] = existingFolderId
            print("📁 Found existing folder \(folderName) in main folder: \(existingFolderId)")
            return existingFolderId
        }
        
        // Create new date folder inside main folder
        let newFolderId = try await createFolder(named: folderName, parentId: mainFolderId)
        dailyFolderCache[dateString] = newFolderId
        print("📁 Created new folder \(folderName) in main folder: \(newFolderId)")
        return newFolderId
    }
    
    private func findFolder(named folderName: String, parentId: String? = nil) async throws -> String? {
        let query = GTLRDriveQuery_FilesList.query()
        
        var queryString = "name = '\(folderName)' and mimeType = 'application/vnd.google-apps.folder' and trashed = false"
        if let parentId = parentId {
            queryString += " and '\(parentId)' in parents"
        }
        
        query.q = queryString
        query.spaces = "drive"
        
        return try await withCheckedThrowingContinuation { continuation in
            service.executeQuery(query) { (ticket, result, error) in
                if let error = error {
                    print("❌ Failed to search for folder '\(folderName)': \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let fileList = result as? GTLRDrive_FileList,
                      let files = fileList.files,
                      let firstFile = files.first,
                      let folderIdValue = firstFile.identifier else {
                    continuation.resume(returning: nil)
                    return
                }
                
                // Safely convert identifier to string
                let folderId = String(describing: folderIdValue)
                continuation.resume(returning: folderId)
            }
        }
    }
    
    private func createFolder(named folderName: String, parentId: String? = nil) async throws -> String {
        let folder = GTLRDrive_File()
        folder.name = folderName
        folder.mimeType = "application/vnd.google-apps.folder"
        
        if let parentId = parentId {
            folder.parents = [parentId]
        }
        
        let query = GTLRDriveQuery_FilesCreate.query(withObject: folder, uploadParameters: nil)
        
        return try await withCheckedThrowingContinuation { continuation in
            service.executeQuery(query) { (ticket, result, error) in
                if let error = error {
                    print("❌ Failed to create folder '\(folderName)': \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let file = result as? GTLRDrive_File,
                      let folderIdValue = file.identifier else {
                    print("❌ Created folder but no ID returned")
                    continuation.resume(throwing: GoogleDriveError.folderCreationFailed)
                    return
                }
                
                // Safely convert identifier to string
                let folderId = String(describing: folderIdValue)
                print("✅ Successfully created folder '\(folderName)' with ID: \(folderId)")
                continuation.resume(returning: folderId)
            }
        }
    }
    
    // MARK: - PDF Upload
    func uploadAppointmentPDF(
        caregiverFirstName: String,
        caregiverLastName: String,
        childFirstName: String,
        childLastName: String,
        pdfData: Data,
        date: Date = Date()
    ) async throws {
        let fileName = "\(childFirstName) \(childLastName) \(formatDateForPDF(date)).pdf"
        print("📄 Starting appointment PDF upload: \(fileName) (\(pdfData.count) bytes)")
        try await uploadPDF(data: pdfData, fileName: fileName, date: date)
    }
    
    func uploadInterpreterPDF(
        interpreterFirstName: String,
        interpreterLastName: String,
        pdfData: Data,
        date: Date = Date()
    ) async throws {
        let fileName = "\(interpreterFirstName) \(interpreterLastName) - Interpreter \(formatDateForPDF(date)).pdf"
        print("📄 Starting interpreter PDF upload: \(fileName) (\(pdfData.count) bytes)")
        try await uploadPDF(data: pdfData, fileName: fileName, date: date)
    }
    
    private func uploadPDF(data: Data, fileName: String, date: Date) async throws {
        // Ensure authentication with automatic retry
        if !isAlreadyAuthenticated() {
            print("🔐 Authentication required, signing in...")
            try await authenticate()
        }
        
        // Double-check after authentication attempt
        guard isAuthenticated else {
            throw GoogleDriveError.authenticationFailed
        }
        
        // Get or create daily folder
        let folderId = try await getDailyFolderId(for: date)
        
        // Check for existing file with same name and handle duplicates
        let finalFileName = try await getUniqueFileName(fileName, in: folderId)
        
        // Create file metadata
        let file = GTLRDrive_File()
        file.name = finalFileName
        file.parents = [folderId]
        file.mimeType = "application/pdf"
        file.descriptionProperty = "Check-In PDF generated by CheckIn app on \(Date())"
        
        // Upload the file
        let uploadParameters = GTLRUploadParameters(data: data, mimeType: "application/pdf")
        let query = GTLRDriveQuery_FilesCreate.query(withObject: file, uploadParameters: uploadParameters)
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            service.executeQuery(query) { (ticket, result, error) in
                if let error = error {
                    print("❌ PDF upload failed for '\(finalFileName)': \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let uploadedFile = result as? GTLRDrive_File else {
                    print("❌ Upload completed but no file object returned")
                    continuation.resume(throwing: GoogleDriveError.uploadFailed)
                    return
                }
                
                print("✅ PDF uploaded successfully!")
                print("📁 File: \(finalFileName)")
                
                // Safely handle the file identifier which might be NSNumber or NSString
                let fileId = uploadedFile.identifier.map { String(describing: $0) } ?? "Unknown"
                print("🆔 File ID: \(fileId)")
                
                if !fileId.isEmpty && fileId != "Unknown" {
                    print("🔗 View at: https://drive.google.com/file/d/\(fileId)/view")
                }
                continuation.resume()
            }
        }
    }
    
    private func getUniqueFileName(_ baseName: String, in folderId: String) async throws -> String {
        var fileName = baseName
        var counter = 1
        
        while try await fileExists(fileName, in: folderId) {
            let nameWithoutExtension = (baseName as NSString).deletingPathExtension
            let fileExtension = (baseName as NSString).pathExtension
            fileName = "\(nameWithoutExtension) (\(counter)).\(fileExtension)"
            counter += 1
            
            // Safety check to prevent infinite loops
            if counter > 100 {
                print("⚠️ Too many duplicate files, using timestamp suffix")
                let timestamp = Int(Date().timeIntervalSince1970)
                fileName = "\(nameWithoutExtension) \(timestamp).\(fileExtension)"
                break
            }
        }
        
        if fileName != baseName {
            print("📄 Renamed to avoid duplicate: \(fileName)")
        }
        
        return fileName
    }
    
    private func fileExists(_ fileName: String, in folderId: String) async throws -> Bool {
        let query = GTLRDriveQuery_FilesList.query()
        query.q = "name = '\(fileName)' and '\(folderId)' in parents and trashed = false"
        
        return try await withCheckedThrowingContinuation { continuation in
            service.executeQuery(query) { (ticket, result, error) in
                if let error = error {
                    print("❌ Failed to check if file exists '\(fileName)': \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let fileList = result as? GTLRDrive_FileList,
                      let files = fileList.files else {
                    continuation.resume(returning: false)
                    return
                }
                
                continuation.resume(returning: !files.isEmpty)
            }
        }
    }
    
    // MARK: - Background Upload
    func uploadInBackground(operation: @escaping () async throws -> Void) {
        Task.detached(priority: .background) {
            do {
                print("🔄 Starting background Google Drive upload...")
                try await operation()
                print("✅ Background Google Drive upload completed successfully")
            } catch {
                print("❌ Background Google Drive upload failed: \(error.localizedDescription)")
                await self.handleUploadError(error)
            }
        }
    }
    
    @MainActor
    private func handleUploadError(_ error: Error) {
        print("🔄 Handling Google Drive upload error: \(error.localizedDescription)")
        
        // Log specific error types for debugging
        if let driveError = error as? GoogleDriveError {
            switch driveError {
            case .authenticationFailed:
                print("💡 Suggestion: User may need to sign in to Google Drive again")
            case .quotaExceeded:
                print("💡 Suggestion: Google Drive storage is full")
            case .networkError:
                print("💡 Suggestion: Check internet connection")
            default:
                print("💡 Suggestion: Retry upload or check Google Drive permissions")
            }
        }
        
        // Could implement retry logic here:
        // - Exponential backoff for network errors
        // - Re-authentication for auth errors
        // - User notification for quota/permission errors
    }
    
    // MARK: - Utility Methods
    func getAccountInfo() -> String? {
        guard let currentUser = GIDSignIn.sharedInstance.currentUser,
              let profile = currentUser.profile else {
            return nil
        }
        return profile.email
    }
    
    func getAuthenticationInfo() -> (isAuthenticated: Bool, email: String?, lastAuthDate: Date?) {
        let cachedAuthStatus = UserDefaults.standard.bool(forKey: authenticationStatusKey)
        let lastAuthDate = UserDefaults.standard.object(forKey: lastAuthenticationDateKey) as? Date
        let email = getAccountInfo()
        
        print("📊 Authentication Info:")
        print("   - Cached Status: \(cachedAuthStatus)")
        print("   - Internal Status: \(isAuthenticated)")
        print("   - Email: \(email ?? "none")")
        print("   - Last Auth: \(lastAuthDate?.description ?? "never")")
        
        return (isAuthenticated, email, lastAuthDate)
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        isAuthenticated = false
        dailyFolderCache.removeAll()
        mainFolderCache = nil
        saveAuthenticationStatus(false)
        print("🔐 Signed out of Google Drive")
    }
    
    // MARK: - Date Formatting
    private func formatDateForFolder(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: date)
    }
    
    private func formatDateForPDF(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Error Types
enum GoogleDriveError: LocalizedError {
    case noViewController
    case authenticationFailed
    case folderCreationFailed
    case uploadFailed
    case networkError
    case quotaExceeded
    
    var errorDescription: String? {
        switch self {
        case .noViewController:
            return "No view controller available for Google Sign-In"
        case .authenticationFailed:
            return "Google Drive authentication failed"
        case .folderCreationFailed:
            return "Failed to create daily folder in Google Drive"
        case .uploadFailed:
            return "PDF upload to Google Drive failed"
        case .networkError:
            return "Network connection error"
        case .quotaExceeded:
            return "Google Drive storage quota exceeded"
        }
    }
} 
