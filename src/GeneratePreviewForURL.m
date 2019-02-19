/*
 * Created 190219 lynnl
 */
#import <Foundation/Foundation.h>
#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
#include "utils.h"

/*
 * Generate a preview for designated file
 */
OSStatus GeneratePreviewForURL(
        void *thisInterface,
        QLPreviewRequestRef preview,
        CFURLRef url,
        CFStringRef contentTypeUTI,
        CFDictionaryRef options)
{
    AUTORELEASEPOOL_BEGIN

    /* Alternatively [NSDictionary dictionary] */
    NSDictionary *previewProperties = nil;

    if (QLPreviewRequestIsCancelled(preview)) goto out_exit;

    LOG("%s() called", __func__);

    QLPreviewRequestSetURLRepresentation(
        preview,
        url,
        kUTTypePlainText,
        (__bridge CFDictionaryRef) previewProperties
    );

    AUTORELEASEPOOL_END
out_exit:
    return noErr;
}

/*
 * Implement only if supported
 */
void CancelPreviewGeneration(
        void *thisInterface,
        QLPreviewRequestRef preview)
{
    AUTORELEASEPOOL_BEGIN
    uint16_t rid = ((uint64_t) preview) & 0xffff;
    LOG_DBG("Preview %#x cancelled", rid);
    AUTORELEASEPOOL_END
}

