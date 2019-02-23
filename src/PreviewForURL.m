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

    CFStringRef path = CFURLCopyPath(url);
    LOG("%s() called  path: %@", __func__, path);
    CF_SAFE_RELEASE(path);

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
    LOG_DBG("Preview %p cancelled", preview);
    AUTORELEASEPOOL_END
}

