import Foundation

protocol ScreenTransitionProtocol: AnyObject {
    func onTransition<T>(value: T, key: String)
}
