//
//  View+Ex.swift
//  TennisFood
//
//  Created by Ahmad Shaheer on 23/07/2024.
//

import Foundation
import SwiftUI


extension View {
    
    @ViewBuilder
    func modifiers<Content: View>(@ViewBuilder content: @escaping (Self) -> Content) -> some View {
        content(self)
    }
    
    @ViewBuilder
    func backgroundImage() -> some View {
        Image("background")
            .resizable()
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            .aspectRatio(contentMode: .fill)
            .clipped()
    }
    
    func presentView(controller: UIViewController, withAnimation animation: Bool = false, modalPresentationStyle: UIModalPresentationStyle = .overCurrentContext, modalTransitionStyle: UIModalTransitionStyle = .coverVertical, backgroundColor: UIColor = .clear) {
        controller.view.backgroundColor = backgroundColor
        controller.modalPresentationStyle = modalPresentationStyle
        controller.modalTransitionStyle = modalTransitionStyle
        topViewController()?.present(controller, animated: animation, completion: nil)
    }
    
    func topViewController() -> UIViewController? {
        if var topController = UIApplication.shared.appWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController { topController = presentedViewController }
            return topController
        } else { return nil }
    }
    
    func transparentScrolling() -> some View {
        if #available(iOS 16.0, *) {
            return scrollContentBackground(.hidden)
        } else {
            return onAppear {
                UITextView.appearance().backgroundColor = .clear
            }
        }
    }
    
    func hide(if isHiddden: Bool) -> some View {
        ModifiedContent(content: self,
                        modifier: HideViewModifier(isHidden: isHiddden)
        )
    }
    
    func hapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: style)
        impactFeedbackgenerator.prepare()
        impactFeedbackgenerator.impactOccurred()
    }
    
    @ViewBuilder
    func shimmer(when isLoading: Binding<Bool>) -> some View {
        if isLoading.wrappedValue {
            self.modifier(Shimmer())
                .redacted(reason: isLoading.wrappedValue ? .placeholder : [])
        } else {
            self
        }
    }
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
    
    func animation(if animate: Bool, _ body: @escaping () -> Void) {
        if animate {
            withAnimation {
                body()
            }
        } else {
            withTransaction(Transaction(animation: nil)) {
                body()
            }
        }
    }
    
    @ViewBuilder
    func viewExtractor(result: @escaping (UIView) -> Void) -> some View {
        self
            .background(ViewExtractorHelper(result: result))
            .compositingGroup()
    }
    
    func dismissKeyboard() {
        UIApplication.shared.appWindow?.endEditing(true)
    }
    
    func openKeyboard() {
        UIApplication.shared.appWindow?.becomeFirstResponder()
    }
}

struct HideViewModifier: ViewModifier {
    let isHidden: Bool
    @ViewBuilder func body(content: Content) -> some View {
        if isHidden {
            EmptyView()
        } else {
            content
        }
    }
}

fileprivate struct ViewExtractorHelper: UIViewRepresentable {
    var result: (UIView) -> ()
    func makeUIView(context: Context) -> some UIView {
        let view  = UIView(frame: .zero)
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        
        DispatchQueue.main.async {
            if let uikitview = view.superview?.superview?.subviews.last?.subviews.first {
                result(uikitview)
            }
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}

public struct Shimmer: ViewModifier {
    @State private var isInitialState = true
    
    public func body(content: Content) -> some View {
        content
            .mask(
                LinearGradient(
                    gradient: .init(colors: [.black.opacity(0.4), .black, .black.opacity(0.4)]),
                    startPoint: (isInitialState ? .init(x: -0.3, y: -0.3) : .init(x: 1, y: 1)),
                    endPoint: (isInitialState ? .init(x: 0, y: 0) : .init(x: 1.3, y: 1.3))
                )
            )
            .animation(.linear(duration: 1.5).delay(0.25).repeatForever(autoreverses: false), value: isInitialState)
            .onAppear {
                isInitialState = false
            }
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}

// MARK: - Idle Timer Extension
extension View {
    /// Applies idle timer functionality to automatically return to home screen after 3 minutes of inactivity
    func idleTimer() -> some View {
        self.modifier(IdleTimerModifier())
    }
}

struct IdleTimerModifier: ViewModifier {
    @StateObject private var idleTimerManager = IdleTimerManager.shared
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                // Reset timer when app comes to foreground
                idleTimerManager.resetIdleTimer()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                // Stop timer when app goes to background
                idleTimerManager.stopIdleTimer()
            }
            .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification)) { _ in
                // Reset timer on text input
                idleTimerManager.userDidInteract()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                // Reset timer when keyboard appears
                idleTimerManager.userDidInteract()
            }
            .onAppear {
                // Start timer when view appears
                idleTimerManager.resetIdleTimer()
            }
            .onDisappear {
                // Don't stop timer on disappear as user is still in the app
                // Timer will continue running across screens
            }
            // Detect any touch/gesture interactions without interfering with existing gestures
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        idleTimerManager.userDidInteract()
                    }
            )
    }
}
