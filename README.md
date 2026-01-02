## Architecture
- UIKit + MVVM
- Network layer separated via protocols for testability

## Image Caching
- In-memory cache + disk cache
- In-flight request deduplication to prevent duplicate downloads

## Testing
- ViewModel unit tests
- ImageLoader caching and concurrency tests
