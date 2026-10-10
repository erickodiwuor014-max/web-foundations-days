# Day 7 Assignment: Scaling a Photo-Sharing App

## 1. Assumptions and Daily Active Users

SnapShare is a photo-sharing application where users upload photos and view a feed of photos from people they follow.

The following assumptions are based on the assignment requirements:

- Registered users: 10,000,000
- Daily active users: 10% of registered users
- Photos uploaded per active user per day: 1
- Feed pages viewed per active user per day: 50
- Average original photo size: 2 MB
- Average thumbnail size: 50 KB
- Seconds per day: 86,400
- Peak traffic: 5 times the average traffic
- Storage estimates use decimal units and assume photos are retained for one year.

Daily active users (DAU):

10,000,000 × 10% = 1,000,000 daily active users.

Total photo uploads per day:

1,000,000 × 1 = 1,000,000 uploads per day.

Total feed views per day:

1,000,000 × 50 = 50,000,000 feed views per day.

## 2. Traffic and Storage Estimates

### Photo uploads per second

Average uploads per second:

1,000,000 ÷ 86,400 = approximately 11.57 uploads per second.

### Feed views per second

Average feed views per second:

50,000,000 ÷ 86,400 = approximately 578.70 feed views per second.

Peak feed views per second:

578.70 × 5 = approximately 2,893.52 feed views per second.

The system should therefore be designed to handle approximately 2,894 feed views per second during peak traffic.

### Photo storage per year

Original photos:

1,000,000 photos/day × 2 MB = 2,000,000 MB per day, or 2 TB per day.

2 TB × 365 = 730 TB per year.

Thumbnails:

1,000,000 thumbnails/day × 50 KB = 50,000,000 KB per day, or 50 GB per day.

50 GB × 365 = 18.25 TB per year.

Total storage:

730 TB + 18.25 TB = 748.25 TB per year.

These estimates cover original photos and thumbnails only. They exclude backups, replication, metadata, temporary files, and other overhead.

## 3. Read-Heavy or Write-Heavy?

SnapShare is a read-heavy system because users view 50 feed pages for every photo they upload. This gives an estimated ratio of 50 feed views to 1 upload.

The architecture should therefore prioritize fast feed loading and efficient photo delivery. A cache can store frequently requested feed data, read replicas can handle database reads, and a CDN can deliver photos and thumbnails from locations close to users.

The load balancer distributes API requests across multiple application servers so that one server does not handle all the traffic.

## 4. Why Photos Should Use Object Storage

Photos should be stored in object storage rather than directly inside the database because image files are large binary objects. Storing them in the database would increase database size, backup time, and the cost of managing database storage.

Object storage is designed to store large files reliably and scale to very large amounts of data. The database should store photo metadata, such as the photo ID, owner ID, caption, timestamp, object-storage key, and thumbnail status.

The original photo and thumbnail can then be delivered through a CDN, while the database remains focused on structured data and relationships.

## 5. Architecture Diagram

```text
                       USERS / CLIENTS
                              |
                              v
                            DNS
                              |
                 +------------+-------------+
                 |                          |
                 v                          v
          CDN: HTML, CSS, JS          CDN: PHOTOS
          and cached images           and thumbnails
                 |                          ^
                 v                          |
          +----------------+                |
          | Origin / Web   |                |
          | Static Assets  |                |
          +----------------+                |
                                            |
Users / Clients -- API requests (HTTPS) ----+
                 |
                 v
          +----------------+
          | Load Balancer  |
          +----------------+
                 |
          +------+------+
          |             |
          v             v
     +----------+  +----------+
     | App      |  | App      |
     | Server 1 |  | Server 2 |
     +----------+  +----------+
          |             |
          +------+------+
                 |
       +---------+-------------------+
       |              |              |
       v              v              v
+-------------+ +-------------+ +-------------+
| Cache       | | Primary DB  | | Object      |
| (Redis)     | | Metadata    | | Storage     |
+-------------+ +------+------+ +-------------+
                      |                 ^
                      v                 |
                +-------------+         |
                | Read Replica|         |
                +-------------+         |
                                        |
App Server -- enqueue thumbnail job --> +----------------+
                                        | Message Queue  |
                                        +-------+--------+
                                                |
                                                v
                                        +----------------+
                                        | Thumbnail      |
                                        | Worker         |
                                        +-------+--------+
                                                |
                                  Read original photo,
                                  create thumbnail,
                                  save thumbnail to
                                  object storage, and
                                  update metadata
```

### Estimated load

- Daily active users: 1,000,000
- Average uploads: 11.57 per second
- Average feed views: 578.70 per second
- Peak feed views: 2,893.52 per second
- Annual original photo storage: 730 TB
- Annual thumbnail storage: 18.25 TB
- Annual combined photo storage: 748.25 TB

## 6. Component Explanations

1. **Users/clients:** Users upload photos, follow other users, and request their photo feeds through a browser or mobile application.

2. **DNS:** DNS translates the SnapShare domain name into the IP address needed to reach the application or CDN.

3. **CDN:** A content delivery network caches static files, original photos where appropriate, and thumbnails near users to reduce latency and application-server load.

4. **Load balancer:** The load balancer distributes incoming API requests across healthy application servers and stops sending traffic to unhealthy servers.

5. **Application servers:** Stateless application servers authenticate users, validate uploads, manage feed requests, save metadata, and coordinate background jobs.

6. **Cache (Redis):** Redis stores frequently requested feed data and other temporary results in memory to reduce database queries and improve response times.

7. **Primary database:** The primary database stores authoritative structured information, including user records, photo metadata, captions, relationships, and object-storage keys.

8. **Read replica:** A read replica handles suitable database read requests to reduce the load on the primary database, although replication lag may cause briefly outdated results.

9. **Object storage:** Object storage holds the original photo files and generated thumbnails separately from the database and scales to accommodate large volumes of images.

10. **Message queue:** The message queue holds thumbnail-generation jobs until a worker can process them, allowing the upload request to finish without waiting for image resizing.

11. **Thumbnail worker:** The worker retrieves queued jobs, reads the original photo, generates a smaller thumbnail, saves it to object storage, and updates the photo's processing status in the database.

12. **Monitoring and alerts:** Logs, metrics, and alerts help engineers detect failed uploads, growing queue backlogs, slow feed requests, and unhealthy servers.

## 7. Step-by-Step Photo Upload Flow

1. The user selects a photo and submits an upload request to SnapShare.

2. The request reaches the load balancer, which forwards it to a healthy application server.

3. The application server authenticates the user and validates the photo's file type, size, and upload permissions.

4. The application server stores the original photo in object storage under a unique object key. The application must confirm that the upload succeeded before treating the original as safely stored.

5. The application server saves the photo's metadata in the primary database. This includes the photo ID, owner ID, caption, timestamp, original object key, and a thumbnail status such as "processing".

6. The application server publishes a thumbnail-generation job to the message queue. The job contains the photo ID and the object-storage key needed by the worker.

7. Once the original photo and required metadata are safely saved and the job has been accepted by the queue, the application responds to the user without waiting for thumbnail generation to finish.

8. A thumbnail worker retrieves the job from the queue and reads the original photo from object storage.

9. The worker resizes the original photo and generates a thumbnail of approximately 50 KB, depending on the chosen image-processing settings.

10. The worker saves the thumbnail in object storage under its own object key and updates the database with the thumbnail key and a completed status.

11. The application or feed service can now include the thumbnail URL or object key when returning the photo in a feed. The CDN can deliver the thumbnail to users.

12. If a job fails, the queue and worker system should support retries with back-off. Repeated failures should be logged and moved to a dead-letter queue for investigation. Jobs should be designed to be idempotent so that retries do not create inconsistent records or duplicate effects.

If saving the original, writing metadata, or publishing the job fails, the system must handle the partial failure explicitly. For example, it can retry failed operations, mark the upload as incomplete, and clean up orphaned objects when safe. A transactional outbox can help ensure that a committed database record is not left without its corresponding queued job.

## 8. System Trade-Offs

### Trade-off 1: Speed versus freshness

Caching feed data improves response times and reduces database load. However, cached feeds can become stale when a user uploads a photo or changes a follow relationship.

SnapShare can use short cache expiration times and invalidate affected feed entries after important changes. This improves speed while limiting how long users see outdated information.

### Trade-off 2: Fast uploads versus immediate thumbnail availability

Using a message queue and background worker allows the application to confirm a successful upload without waiting for thumbnail generation. This reduces the time users spend waiting.

However, the thumbnail may not be available immediately. The application must show a processing state or temporarily display a suitable placeholder until the worker finishes.

### Trade-off 3: Reliability versus cost

Multiple application servers, read replicas, durable object storage, and monitoring improve availability and reduce the impact of individual failures.

However, these components increase infrastructure and operating costs. SnapShare should prioritize redundancy for critical components and scale capacity according to measured traffic and reliability requirements.

### Trade-off 4: Consistency versus availability

Database replication and caching help the system serve many reads quickly, but replicas and caches may briefly contain outdated data.

For ordinary photo feeds, a short delay before a new photo appears everywhere may be acceptable. However, upload ownership, permissions, and successful-storage status must be handled carefully to avoid showing users photos they are not allowed to access or claiming an upload succeeded when it did not.

## 9. Conclusion

SnapShare requires an architecture that separates photo storage, structured metadata, user-facing requests, and background processing. Object storage holds the large image files, the database stores metadata, the CDN delivers images close to users, and the cache and read replica support the read-heavy feed workload.

A load balancer distributes API requests across application servers, while a message queue and thumbnail worker process image resizing asynchronously. This design supports growth while making the major trade-offs between speed, freshness, reliability, complexity, and cost explicit.
