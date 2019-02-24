#ifndef UTILS_H
#define UTILS_H

#import <Foundation/Foundation.h>

#define UNUSED(arg0, ...)   (void) ((void) arg0, ##__VA_ARGS__)

#define LOG(fmt, ...)       NSLog(@fmt "\n", ##__VA_ARGS__)
#define LOG_ERR(fmt, ...)   LOG("[ERR] " fmt, ##__VA_ARGS__)
#ifdef DEBUG
#define LOG_DBG(fmt, ...)   LOG("[DBG] " fmt, ##__VA_ARGS__)
#else
#define LOG_DBG(fmt, ...)   UNUSED(fmt, ##__VA_ARGS__)
#endif

#define CASSERT(e)          NSCAssert(e, @#e)
#define CASSERT_NONNULL(p)  CASSERT(p != NULL)

#define ASSERT(e)           NSAssert(e, @#e)
#define ASSERT_NONNULL(p)   ASSERT(p != NULL)

#define AUTORELEASEPOOL_BEGIN   @autoreleasepool {
#define AUTORELEASEPOOL_END     }

#define CF_SAFE_RELEASE(ref)    if (ref) CFRelease(ref)

int mandoc2html_buffer(const char *, char **, size_t *);

#endif	/* UTILS_H */

