import _ConnectionPoolModule
import Logging

final class MemcacheClientMetrics: ConnectionPoolObservabilityDelegate {
    func connectSucceeded(id: Int, streamCapacity: UInt16) {}

    func connectionUtilizationChanged(id: Int, streamsUsed: UInt16, streamCapacity: UInt16) {}

    func requestQueueDepthChanged(_: Int) {}

    typealias ConnectionID = MemcacheConnection.ID

    let logger: Logger

    init(logger: Logger) {
        self.logger = logger
    }

    func startedConnecting(id: ConnectionID) {
        self.logger.debug("Creating new Memcache connection", metadata: ["connection_id": "\(id)"])
    }

    func connectFailed(id: ConnectionID, error: Error) {
        self.logger.error("Memcache connection creation failed", metadata: ["connection_id": "\(id)", "error": "\(error)"])
    }

    func connectSucceeded(id: ConnectionID) {
        self.logger.info("Memcache connection established", metadata: ["connection_id": "\(id)"])
    }

    func connectionLeased(id: ConnectionID) {
        self.logger.debug("Memcache connection leased", metadata: ["connection_id": "\(id)"])
    }

    func connectionReleased(id: ConnectionID) {
        self.logger.debug("Memcache connection released", metadata: ["connection_id": "\(id)"])
    }

    func keepAliveTriggered(id: ConnectionID) {
        self.logger.debug("Memcache keep-alive triggered", metadata: ["connection_id": "\(id)"])
    }

    func keepAliveSucceeded(id: ConnectionID) {
        self.logger.info("Memcache keep-alive succeeded", metadata: ["connection_id": "\(id)"])
    }

    func keepAliveFailed(id: ConnectionID, error: Error) {
        self.logger.error("Memcache keep-alive failed", metadata: ["connection_id": "\(id)", "error": "\(error)"])
    }

    func connectionClosing(id: ConnectionID) {
        self.logger.warning("Memcache connection closing", metadata: ["connection_id": "\(id)"])
    }

    func connectionClosed(id: ConnectionID, error: Error?) {
        // let errorMetadata = error.map { String(describing: $0) } ?? "none"
        // logger.info("Memcache connection closed", metadata: ["connection_id": "\(id)", "error": error])
    }

    // Implement other necessary methods as needed
}
