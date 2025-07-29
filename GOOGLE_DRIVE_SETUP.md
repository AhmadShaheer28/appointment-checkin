# Google Drive Integration Setup Guide

This guide will help you set up Google Drive API integration for the CheckIn app to automatically upload PDF files.

## 📋 Prerequisites

1. Google Account with Google Drive access
2. Xcode 15+ installed
3. iOS 16+ target device

## 🔧 Step 1: Google Cloud Console Setup

### 1.1 Create a Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Click **"Create Project"** or select an existing project
3. Enter a project name (e.g., "CheckIn App")
4. Click **"Create"**

### 1.2 Enable Google Drive API

1. In the Google Cloud Console, navigate to **"APIs & Services" > "Library"**
2. Search for **"Google Drive API"**
3. Click on it and press **"Enable"**

### 1.3 Create OAuth 2.0 Credentials

1. Go to **"APIs & Services" > "Credentials"**
2. Click **"+ CREATE CREDENTIALS" > "OAuth client ID"**
3. If prompted, configure the OAuth consent screen:
   - Choose **"External"** for user type
   - Fill in the required information:
     - App name: `CheckIn App`
     - User support email: Your email
     - Developer contact information: Your email
   - Add scopes: `../auth/drive.file` (for file upload)
4. For Application type, select **"iOS"**
5. Enter your Bundle ID: `com.stakx.CheckIn`
6. Click **"Create"**

### 1.4 Download Configuration File

1. After creating credentials, click the download button (📥)
2. Download the `GoogleService-Info.plist` file
3. **Important**: Replace the template file at `CheckIn/Resources/GoogleService-Info.plist` with the downloaded file

## 🔧 Step 2: Update App Configuration

### 2.1 Update Info.plist URL Scheme

1. Open `CheckIn/Info.plist`
2. Find the line with `com.googleusercontent.apps.YOUR_CLIENT_ID_HERE`
3. Replace `YOUR_CLIENT_ID_HERE` with your actual **REVERSED_CLIENT_ID** from `GoogleService-Info.plist`

Example:
```xml
<string>com.googleusercontent.apps.123456789-abcdef.apps.googleusercontent.com</string>
```
Should become:
```xml
<string>com.googleusercontent.apps.123456789-abcdef</string>
```

### 2.2 Add Google Drive API Dependencies

The app already includes the necessary dependencies in `Package.swift`. When you build the project, Xcode will automatically download and link:

- GoogleAPIClientForREST
- GoogleSignIn

## 🔧 Step 3: Configure App Delegate (if needed)

The app is configured to work with SwiftUI lifecycle. If you need to add custom configuration, you can modify `CheckInApp.swift`.

## 📱 Step 4: Test the Integration

### 4.1 Build and Run

1. Build the project in Xcode
2. Run on a physical device (Google Sign-In doesn't work well in simulator)
3. Complete either check-in flow (Appointment or Interpreter)
4. The app will automatically attempt to upload PDFs to Google Drive

### 4.2 Authentication Flow

On first use, the app will:
1. Prompt for Google account sign-in
2. Ask for permission to access Google Drive
3. Upload PDFs in the background

### 4.3 Verify Upload

1. Check your Google Drive
2. Look for folders named "Check-In MM/DD/YYYY"
3. PDFs should be named according to the format:
   - Appointment: `ChildFirstName ChildLastName MM/DD/YYYY.pdf`
   - Interpreter: `FirstName LastName - Interpreter MM/DD/YYYY.pdf`

## 🔒 Security Considerations

### Production Deployment

For production apps:

1. **Use Service Account** instead of OAuth for unattended operation:
   - Create a Service Account in Google Cloud Console
   - Download the JSON key file
   - Use service account authentication instead of user authentication

2. **Restrict API Key**:
   - In Google Cloud Console, go to "Credentials"
   - Edit your API key to restrict it to specific APIs and apps

3. **Configure OAuth Consent Screen**:
   - Submit for verification if distributing publicly
   - Add proper privacy policy and terms of service

## 🚨 Troubleshooting

### Common Issues

#### 1. "GoogleService-Info.plist not found"
- Ensure you've replaced the template file with the actual downloaded file
- Verify the file is added to the Xcode project target

#### 2. Authentication Failed
- Check that the Bundle ID matches exactly
- Verify the URL scheme in Info.plist matches REVERSED_CLIENT_ID
- Ensure Google Drive API is enabled in Google Cloud Console

#### 3. Upload Failed
- Check internet connectivity
- Verify Google Drive has sufficient storage space
- Ensure the user has granted necessary permissions

#### 4. Build Errors
```bash
# Clean and rebuild
xcodebuild clean
xcodebuild build
```

### Debug Mode

To enable detailed logging, add to GoogleDriveManager.swift:
```swift
private func setupGoogleDrive() {
    // Add this line for debugging
    GTMSessionFetcher.setLoggingEnabled(true)
    // ... rest of setup
}
```

## 🔄 Background Upload

The app uses background uploading to ensure:
- UI responsiveness
- Automatic retry on failure
- Upload continues even if user navigates away

Upload status is logged to console for debugging.

## 📊 Monitoring

For production use, consider:
- Adding upload success/failure notifications
- Implementing retry logic with exponential backoff
- Adding analytics to track upload success rates
- Storing failed uploads for manual retry

## 🆘 Support

For additional help:
- [Google Drive API Documentation](https://developers.google.com/drive/api)
- [Google Sign-In for iOS](https://developers.google.com/identity/sign-in/ios)
- [Google API Client for iOS](https://github.com/google/google-api-objectivec-client-for-rest)

---

**Note**: This setup requires actual Google Drive API credentials. The template files provided will not work without proper configuration. 