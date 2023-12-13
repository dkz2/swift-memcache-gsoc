import Logging
import NIOCore
import NIOPosix

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
final class MemcacheConnectionFactory: Sendable {
    let eventLoopGroup: EventLoopGroup
    let logger: Logger
    let host: String
    let port: Int

    init(host: String, port: Int, eventLoopGroup: EventLoopGroup, logger: Logger) {
        self.host = host
        self.port = port
        self.eventLoopGroup = eventLoopGroup
        self.logger = logger
    }

    func makeConnection(_ connectionID: Int, pool: MemcacheClient.Pool) async throws -> MemcacheConnection {
        return try await withCheckedThrowingContinuation { continuation in
            let connection = MemcacheConnection(id: connectionID, host: self.host, port: self.port, eventLoopGroup: self.eventLoopGroup)

            Task {
                do {
                    try await connection.run()
                    continuation.resume(returning: connection)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
