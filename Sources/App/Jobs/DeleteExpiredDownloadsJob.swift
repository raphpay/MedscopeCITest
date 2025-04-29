//
//  DeleteExpiredDownloadsJob.swift
//  Medscope
//
//  Created by Raphaël Payet on 20/09/2024.
//

import Vapor
import Queues
import Fluent

/// A job that deletes expired file downloads from the database.
/// - Note: This job deletes all expired `FileDownload` records from the database.
///     It is scheduled to run periodically to clean up expired downloads.
/// - Important: This job should be scheduled to run at regular intervals to ensure that expired downloads are removed from the database.
struct DeleteExpiredDownloadsJob: ScheduledJob {
    func run(context: QueueContext) -> EventLoopFuture<Void> {
        // Get the current date
        let now = Date()

        // Delete all expired `FileDownload` records
        return FileDownload.query(on: context.application.db)
            .filter(\.$expiresAt < now)
            .delete(force: true)
            .map {
                context.logger.info("Deleted expired FileDownload entries")
            }
    }
}
