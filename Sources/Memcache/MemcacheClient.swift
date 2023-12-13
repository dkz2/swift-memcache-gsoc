//
//  File.swift
//
//
//  Created by Delo on 11/10/23.
//

import _ConnectionPoolModule
import Atomics
import Logging
import NIOCore
import NIOPosix
import ServiceLifecycle

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
@_spi(ConnectionPool)
public struct MemcacheKeepAliveBehavior: ConnectionKeepAliveBehavior {
    public typealias Connection = MemcacheConnection

    /// The frequency with which to send keep-alive messages.
    public var keepAliveFrequency: Duration?

    /// Initializes the keep-alive behavior with a specified frequency.
    public init(frequency: Duration) {
        self.keepAliveFrequency = frequency
    }

    /// Sends a simulated no-op command to the Memcache server to keep the connection alive.
    public func runKeepAlive(for connection: MemcacheConnection) async throws {
        _ = try await connection.noop()
    }
}

public struct MemcacheConfiguration {
    public var minimumConnectionCount: Int
    public var maximumConnectionSoftLimit: Int
    public var maximumConnectionHardLimit: Int
    public var idleTimeout: Duration

    public init(minimumConnectionCount: Int = 0,
                maximumConnectionSoftLimit: Int = 16,
                maximumConnectionHardLimit: Int = 16,
                idleTimeout: Duration = .seconds(60)) {
        self.minimumConnectionCount = minimumConnectionCount
        self.maximumConnectionSoftLimit = maximumConnectionSoftLimit
        self.maximumConnectionHardLimit = maximumConnectionHardLimit
        self.idleTimeout = idleTimeout
    }
}

extension ConnectionPoolConfiguration {
    init(_ config: MemcacheConfiguration) {
        self = ConnectionPoolConfiguration()
        self.minimumConnectionCount = config.minimumConnectionCount
        self.maximumConnectionSoftLimit = config.maximumConnectionSoftLimit
        self.maximumConnectionHardLimit = config.maximumConnectionHardLimit
        self.idleTimeout = config.idleTimeout
    }
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
public final class MemcacheClient: Sendable {
    typealias Pool = ConnectionPool<
        MemcacheConnection,
        MemcacheConnection.ID,
        ConnectionIDGenerator,
        ConnectionRequest<MemcacheConnection>,
        ConnectionRequest.ID,
        MemcacheKeepAliveBehavior,
        MemcacheClientMetrics,
        ContinuousClock
    >

    let pool: Pool
    let factory: MemcacheConnectionFactory
    let runningAtomic = ManagedAtomic(false)
    let backgroundLogger: Logger

    public init(
        configuration: MemcacheConfiguration,
        eventLoopGroup: EventLoopGroup,
        backgroundLogger: Logger
    ) {
        self.backgroundLogger = backgroundLogger
        let factory = MemcacheConnectionFactory(host: "127.0.0.1", port: 11211, eventLoopGroup: eventLoopGroup, logger: backgroundLogger)
        self.factory = factory

        self.pool = ConnectionPool(
            configuration: .init(configuration),
            idGenerator: ConnectionIDGenerator(),
            requestType: ConnectionRequest<MemcacheConnection>.self,
            keepAliveBehavior: MemcacheKeepAliveBehavior(frequency: .seconds(30)),
            observabilityDelegate: MemcacheClientMetrics(logger: backgroundLogger),
            clock: ContinuousClock()
        ) { connectionID, pool in
            let connection = try await factory.makeConnection(connectionID, pool: pool)
            return ConnectionAndMetadata(connection: connection, maximalStreamsOnConnection: 1)
        }
    }

    /*
     public func get<Value: MemcacheValue>(key: String, as valueType: Value.Type = Value.self) async throws -> Value? {
         let connection = try await leaseConnection()
             defer { self.pool.releaseConnection(connection) }
             return try await connection.get(key, as: valueType)
         }*/
     
    public func withConnection<Result>(_ closure: (MemcacheConnection) async throws -> Result) async throws -> Result {
        let connection = try await self.leaseConnection()

        defer { self.pool.releaseConnection(connection) }
        return try await closure(connection)
    }

    private func leaseConnection() async throws -> MemcacheConnection {
        if !self.runningAtomic.load(ordering: .relaxed) {
            self.backgroundLogger.warning("MemcacheClient not running. Call `run()` before leasing a connection.")
        }
        return try await self.pool.leaseConnection()
    }

    public func run() async {
        let atomicOp = self.runningAtomic.compareExchange(expected: false, desired: true, ordering: .relaxed)
        precondition(!atomicOp.original, "MemcacheClient.run() should only be called once.")
        await self.pool.run()
    }
}
