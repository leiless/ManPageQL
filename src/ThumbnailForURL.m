/*
 * Created 190219 lynnl
 */
#import <Foundation/Foundation.h>

#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>

#include "utils.h"
#include "mandoc2html.h"

/*
 * Generate a thumbnail for designated file as fast as possible
 */
OSStatus GenerateThumbnailForURL(
        void *thisInterface,
        QLThumbnailRequestRef thumbnail,
        CFURLRef url,
        CFStringRef contentTypeUTI,
        CFDictionaryRef options,
        CGSize maxSize)
{
    AUTORELEASEPOOL_BEGIN

    /* Alternatively [NSDictionary dictionary] */
    NSDictionary *previewProperties = nil;
    NSString *badge = [NSString stringWithFormat:@".%@", CFURLCopyPathExtension(url)];
    NSDictionary *properties = @{
        (NSString *) kQLThumbnailPropertyExtensionKey : badge
    };

    if (QLThumbnailRequestIsCancelled(thumbnail)) goto out_exit;

    LOG(@"%s() called", __func__);

    QLThumbnailRequestSetThumbnailWithURLRepresentation(
        thumbnail,
        url,
        kUTTypePlainText,
        (__bridge CFDictionaryRef) previewProperties,
        (__bridge CFDictionaryRef) properties
    );

    AUTORELEASEPOOL_END
out_exit:
    return noErr;
}

/*
 * Implement only if supported
 */
void CancelThumbnailGeneration(
        void *thisInterface,
        QLThumbnailRequestRef thumbnail)
{
    AUTORELEASEPOOL_BEGIN
    LOG_DBG("Thumbnail %p cancelled", thumbnail);
    AUTORELEASEPOOL_END
}

