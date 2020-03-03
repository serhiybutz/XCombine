import Combine

extension XCombine {
    enum UpstreamCompletionPolicy {
        case transparent
        case completeAll
    }

    final class UpstreamGroupCompleter {
        private var completionHandlers = [() -> Void]()
        func register(_ handler: @escaping () -> Void) {
            completionHandlers.append(handler)
        }
        func complete() {
            completionHandlers.forEach { $0() }
        }
    }

    final class UpstreamCompletionObserver<Upstream: Publisher>: Publisher
    {
        // MARK: - Types

        typealias Output = Upstream.Output
        typealias Failure = Upstream.Failure

        // MARK: - Properties

        private let upstream: Upstream
        private var subscriber: AnySubscriber<Output, Failure>!

        private let completer: UpstreamGroupCompleter
        private let policy: UpstreamCompletionPolicy
        private var isCompleted: Bool = false

        // MARK: - Initialization

        init(upstream: Upstream,
             completer: UpstreamGroupCompleter,
             policy: UpstreamCompletionPolicy)
        {
            self.upstream = upstream
            self.completer = completer
            self.policy = policy
        }

        // MARK: - Publisher Lifecycle

        func receive<S: Subscriber>(subscriber: S)
            where S.Failure == Failure, S.Input == Output
        {
            completer.register({
                guard !self.isCompleted else { return; }
                self.isCompleted = true
                subscriber.receive(completion: .finished)
            })

            let innerSubscriber = AnySubscriber<Output, Failure>(
                receiveSubscription: { subscription in
                    subscriber.receive(subscription: subscription)
            },
                receiveValue: { value in
                    subscriber.receive(value)
            },
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        switch self.policy {
                        case .transparent:
                            self.isCompleted = true
                            subscriber.receive(completion: completion)
                        case .completeAll:
                            self.completer.complete()
                        }
                    default:
                        subscriber.receive(completion: completion)
                    }
            })

            upstream.subscribe(innerSubscriber)
        }
    }
}
