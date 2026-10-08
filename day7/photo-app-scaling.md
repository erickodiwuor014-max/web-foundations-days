# SnapShare Scaling Plan

## 1. Assumptions and Daily Active Users

SnapShare has 10,000,000 registered users.

Assumptions provided in the assignment:
- 10% of registered users are active each day.
- Each active user uploads 1 photo per day.
- Each active user views 50 feed pages per day.
- Each original photo is 2 MB.
- Each photo has a 50 KB thumbnail.
- For easy estimation, use approximately 100,000 seconds in a day, as in the course notes.
- Peak feed traffic is estimated as 5 times the average traffic.

### Daily active users

10,000,000 × 10% = 1,000,000 daily active users (DAU).

## 2. Load and Storage Estimates

### Uploads per second

1,000,000 uploads per day ÷ 100,000 seconds per day = approximately 10 uploads per second.

### Feed views per second

Each active user views 50 feed pages per day:

1,000,000 × 50 = 50,000,000 feed views per day.

Average feed views per second:

50,000,000 ÷ 100,000 = approximately 500 feed views per second.

Peak feed views per second:

500 × 5 = approximately 2,500 feed views per second.

### Photo storage per year

Original photos:

1,000,000 photos/day × 2 MB = 2,000,000 MB/day = 2,000 GB/day = 2 TB/day.

Per year:

2 TB × 365 = 730 TB/year.

Thumbnails:

1,000,000 thumbnails/day × 50 KB = 50,000,000 KB/day = 50,000 MB/day = 50 GB/day.

Per year:

50 GB × 365 = 18.25 TB/year.

Total photo and thumbnail storage:

730 TB + 18.25 TB = approximately 748.25 TB/year.

This estimate does not include additional storage such as database records, backups, or extra copies.

## 3. Read-Heavy or Write-Heavy?

SnapShare is read-heavy.

There are approximately 10 photo uploads per second but about 500 feed views per second on average. That means feed reads happen about 50 times as often as photo uploads. At peak, feed traffic can reach approximately 2,500 views per second.

Because the system is read-heavy, the design should use caching and read replicas to reduce database load and make feed requests faster. The course notes explain that caching is especially useful when reads greatly outnumber writes.

## 4. Why Photos Should Not Be Stored Inside the Database

The original photos and thumbnails should not be stored directly inside the database because photo files are large and would make the database much larger and harder to scale.

Instead, the photo files should be stored in object storage. Object storage is designed for large files such as images. The database should store the photo's metadata and the object's location or URL, such as the photo ID, user ID, caption, and storage key.

This keeps the database focused on structured data while object storage handles the large photo files.

## 5. SnapShare Architecture

```text
                         ┌──────────────┐
                         │     DNS      │
                         └──────┬───────┘
                                │
                                v
                    ┌──────────────────────┐
                    │ Browser / Mobile App │
                    └──────┬───────────────┘
                           │
             ┌─────────────┴─────────────┐
             │                           │
             │ Static files              │ API requests
             v                           v
      ┌──────────────┐           ┌─────────────────┐
      │     CDN      │           │ Load Balancer   │
      │ photos/thumbs│           └────────┬────────┘
      └──────────────┘                    │
                                          v
                              ┌─────────────────────┐
                              │     App Servers     │
                              │ App 1 │ App 2 │ App 3│
                              └───────┬─────────────┘
                                      │
                    ┌─────────────────┼──────────────────┐
                    │                 │                  │
                    v                 v                  v
             ┌────────────┐    ┌──────────────┐   ┌──────────────┐
             │ Cache      │    │ Primary DB   │   │ Message Queue│
             │ (Redis)    │    │              │   └──────┬───────┘
             └────────────┘    └──────┬───────┘          │
                                      │                   v
                                      v             ┌──────────────┐
                               ┌──────────────┐     │ Thumbnail    │
                               │ Read Replica │     │ Worker       │
                               └──────────────┘     └──────┬───────┘
                                                          │
                                                          v
                                                   ┌──────────────┐
                                                   │ Object       │
                                                   │ Storage      │
                                                   │ Photos +     │
                                                   │ Thumbnails   │
                                                   └──────────────┘
```

### Main traffic paths

**Loading the feed:**

```text
User → DNS → Load Balancer → App Server → Cache
                                  │
                                  └── cache miss → Read Replica → App Server → User
```

**Loading photos:**

```text
User → CDN → Object Storage (on CDN cache miss)
```

**Uploading a photo:**

```text
User → Load Balancer → App Server → Object Storage
                              │
                              ├──→ Primary DB
                              │
                              └──→ Message Queue → Thumbnail Worker
                                                        │
                                                        v
                                                  Object Storage
```

## 6. Component Explanations

- **Users / clients:** The browser or mobile application used to upload photos and view the feed.
- **DNS:** Converts the SnapShare domain name into the address needed to reach the system.
- **CDN:** Delivers frequently requested photos and thumbnails from locations close to users, reducing latency and origin-server load.
- **Load balancer:** Distributes API requests across healthy app servers so no single server handles all traffic.
- **App servers:** Run the SnapShare application logic and remain stateless so requests can be handled by any healthy server.
- **Cache (Redis):** Stores frequently requested feed data in fast memory so the database receives fewer read requests.
- **Primary database:** Stores structured data and handles writes such as photo metadata, users, and relationships.
- **Read replica:** Copies database data and handles read traffic so the primary database can focus on writes.
- **Object storage:** Stores the large original photos and thumbnails instead of putting the files inside the database.
- **Message queue:** Holds thumbnail-generation jobs so the app can respond without waiting for image processing to finish.
- **Thumbnail worker:** Takes jobs from the queue, creates smaller thumbnails, and stores them in object storage.

## 7. Photo Upload Flow

1. The user selects a photo in the SnapShare application.
2. The client sends the upload request to the SnapShare API through the load balancer.
3. An app server validates the request and the photo information.
4. The original photo is stored in object storage rather than inside the database.
5. The app server stores the photo metadata and object-storage key in the primary database.
6. The app server places a thumbnail-generation job on the message queue.
7. The app server responds to the user without waiting for thumbnail generation to finish.
8. A thumbnail worker takes the job from the queue.
9. The worker downloads or reads the original photo from object storage and creates the 50 KB thumbnail.
10. The worker stores the thumbnail in object storage.
11. The thumbnail can then be delivered through the CDN when users view the feed.

## 8. Trade-Offs

### Trade-off 1: Speed versus freshness

Caching makes feed reads much faster and reduces database load, but cached feed information can become slightly out of date. For SnapShare, this is acceptable because a user can usually tolerate a short delay before seeing a newly uploaded photo in a feed.

### Trade-off 2: Simplicity versus scalability

A single server would be simpler and cheaper, but it would not provide enough capacity or reliability for a system with 1 million daily active users. Multiple app servers with a load balancer are more complex but allow the system to scale horizontally.

### Trade-off 3: Cost versus reliability

Using multiple app servers, a database read replica, object storage, caching, and a queue costs more than a simple system. However, these components reduce single points of failure and allow SnapShare to handle high read traffic and large photo storage requirements.

## Summary

SnapShare has 1,000,000 daily active users, approximately 10 uploads per second, 500 average feed views per second, and a peak of about 2,500 feed views per second. The system is read-heavy, so caching, a read replica, and a CDN are important. Original photos and thumbnails should be stored in object storage, while the database stores their metadata. A message queue and thumbnail worker allow thumbnail creation to happen in the background without making photo uploads wait.
