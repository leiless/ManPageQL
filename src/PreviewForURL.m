/*
 * Created 190219 lynnl
 */

#import <Foundation/Foundation.h>

#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>

#include "utils.h"
#include "mandoc2html.h"

static OSStatus rawTextPreviewForURL(
        void *thisInterface,
        QLPreviewRequestRef preview,
        CFURLRef url,
        CFStringRef contentTypeUTI,
        CFDictionaryRef options)
{
    QLPreviewRequestSetURLRepresentation(
        preview,
        url,
        kUTTypePlainText,
        NULL
    );

    LOG("Preview %@", url);

    return noErr;
}

static OSStatus htmlPreviewForURL(
        void *thisInterface,
        QLPreviewRequestRef preview,
        CFURLRef url,
        CFStringRef contentTypeUTI,
        CFDictionaryRef options)
{
    OSStatus e = noErr;
    NSDictionary *previewProperties = nil;
    CFStringRef cfpath;
    const char *path;
    char *buffer = NULL;
    size_t size;
    CFDataRef cfdata;

    cfpath = CFURLCopyFileSystemPath(url, kCFURLPOSIXPathStyle);
    if (cfpath == NULL) {
        e = paramErr;
        LOG_ERR("CFURLCopyFileSystemPath() fail  url: %@", url);
        goto out_exit;
    }

    path = CFStringGetCStringPtr(cfpath, kCFStringEncodingUTF8);
    if (path == NULL) {
        LOG_ERR("CFStringGetCStringPtr() fail  path: %@", cfpath);
        e = paramErr;
        goto out_cfpath;
    }

    e = mandoc2html_buffer(path, &buffer, &size);
    if (e != 0) {
        LOG_ERR("mandoc2html_buffer() fail  url: %s err: %d", path, (int) e);
        e = kGeneralFailureErr;
        goto out_cfpath;
    }

    cfdata = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, (UInt8 *) buffer, size, kCFAllocatorNull);
    if (cfdata == NULL) {
        e = kGeneralFailureErr;
        LOG_ERR("CFDataCreateWithBytesNoCopy() fail  url: %s", path);
        goto out_buffer;
    }

    QLPreviewRequestSetDataRepresentation(
        preview,
        cfdata,
        kUTTypeHTML,
        (__bridge CFDictionaryRef) previewProperties
    );

    LOG("Preview %s  html text size: %zu", path, size);

    CFRelease(cfdata);
out_buffer:
    free(buffer);
out_cfpath:
    CFRelease(cfpath);
out_exit:
    return e;
}

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
    OSStatus e;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *defaults = [userDefaults persistentDomainForName:@"cn.junkman.quicklook.ManPageQL"];
    id isRaw = nil;

    if (defaults != nil) isRaw = [defaults valueForKey:@"RawTextForPreview"];

    if (isRaw != nil && [isRaw boolValue]) {
        e = rawTextPreviewForURL(thisInterface, preview, url, contentTypeUTI, options);
    } else {
        e = htmlPreviewForURL(thisInterface, preview, url, contentTypeUTI, options);
    }

    return e;
    AUTORELEASEPOOL_END
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

