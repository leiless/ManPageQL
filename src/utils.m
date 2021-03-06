/*
 * Created 190223 lynnl
 */

#include "utils.h"
#include "mandoc2html.h"

/**
 * Get length of a file stream
 * @return      0 if success  -1 otherwise(errno will be set)
 *              file position will at beginning if success
 *              otherwise its position is unknown
 */
static long ftell2(FILE *fp)
{
    long size;

    size = fseek(fp, 0L, SEEK_END);
    if (size != 0) {
        LOG_ERR("fseek(3) SEEK_END fail  errno: %d", errno);
        goto out_exit;
    }

    size = ftell(fp);
    if (size < 0) {
        LOG_ERR("ftell(3) fail  errno: %d", errno);
        goto out_exit;
    }

    if (fseek(fp, 0L, SEEK_SET) != 0) {
        size = -1;
        LOG_ERR("fseek(3) SEEK_SET fail  errno: %d", errno);
    }

out_exit:
    return size;
}

/**
 * Read file content into buffer
 * @buffp       Pointer to buffer
 * @sizep       Pointer to length of buffer(count EOS)
 * @return      0 if success  -1 otherwise(errno will be set)
 *              you're responsible to free(3) *buffp if success
 */
static int read2buffer(const char *path, char **buffp, size_t *sizep)
{
    int e = -1;
    FILE *fp;
    long size;
    char *buffer;
    long size2;

    CASSERT_NONNULL(path);
    CASSERT_NONNULL(buffp);
    CASSERT_NONNULL(sizep);
    CASSERT(*buffp == NULL);

    fp = fopen(path, "r");
    if (fp == NULL) {
        LOG_ERR("fopen(3) fail  path: %s errno: %d", path, errno);
        goto out_exit;
    }

    size = ftell2(fp);
    if (size < 0) goto out_close;

    buffer = (char *) malloc((size + 1) * sizeof(char));
    if (buffer == NULL) {
        LOG_ERR("malloc(3) fail  size: %zu errno: %d", size + 1, errno);
        goto out_close;
    }

    size2 = fread(buffer, sizeof(char), size, fp);
    if (ferror(fp) == 0) {
        e = 0;
        *buffp = buffer;
        *sizep = size + 1;
        buffer[size2++] = '\0';
    } else {
        LOG_ERR("fread(3) fail  read: %ld vs %ld errno: %d", size2, size, errno);
        free(buffer);
    }

out_close:
    (void) fclose(fp);
out_exit:
    return e;
}

/**
 * Convert man page into HTML
 *
 * @path        man page file path
 * @style       style sheet file path(NULL for internal style)
 * @buffp       Pointer to buffer
 * @sizep       Pointer to length of buffer(count EOS)
 * @return      0 is success  error code otherwise
 *              you're responsible to free(3) *buffp if success
 *
 * see:
 *  http://c-faq.com/stdio/undofreopen.html
 *  http://kaskavalci.com/redirecting-stdout-to-array-and-restoring-it-back-in-c/
 *  https://www.experts-exchange.com/questions/20420198/How-to-return-to-stdout-after-freopen.html
 */
int mandoc2html_buffer(const char *path, const char *style, char **buffp, size_t *sizep)
{
    char template[] = "/tmp/.ManPageQL-XXXXXXXXXXXX";
    char *tmp;
    int fd;
    FILE *fp;
    fpos_t pos;
    int e;

    CASSERT_NONNULL(path);
    CASSERT_NONNULL(buffp);
    CASSERT_NONNULL(sizep);
    CASSERT(*buffp == NULL);

    /* mktemp(3)'s template must on heap  otherwise you got bus error: 10 */
    tmp = mktemp(template);
    if (tmp == NULL){
        LOG_ERR("mktemp(3) fail  errno: %d", errno);
        e = -1;
        goto out_exit;
    }

    (void) fflush(stdout);
    if (fgetpos(stdout, &pos) != 0) {
        LOG_ERR("fgetpos(3) fail  errno: %d", errno);
        e = -2;
        goto out_exit;
    }

out_dup:
    fd = dup(fileno(stdout));
    if (fd == -1) {
        if (errno == EINTR) goto out_dup;
        LOG_ERR("dup(2) fail  errno: %d", errno);
        e = -3;
        goto out_exit;
    }

    fp = freopen(tmp, "w", stdout);
    if (fp == NULL) {
        LOG_ERR("freopen(3) fail  path: %s errno: %d", tmp, errno);
        e = -4;
        goto out_close;
    }

    e = mandoc2html(path, style);

    /* Restore stdout ASAP */
    (void) fflush(stdout);
out_dup2:
    if (dup2(fd, fileno(stdout)) == -1) {
        if (errno == EINTR) goto out_dup2;
        LOG_ERR("dup2(2) fail  %d -> %d errno: %d", fd, fileno(stdout), errno);
        /* Should never happen  stdout goes haywire */
    } else {
        clearerr(stdout);
        if (fsetpos(stdout, &pos) != 0) {
            LOG_ERR("fsetpos(3) fail  pos: %lld errno: %d", pos, errno);
            /* No fallback  stdout position goes haywire */
        }
    }

    if (e == M2H_ERR_SUCCESS) {
        if ((e = read2buffer(tmp, buffp, sizep)) != 0) {
            e = -5;  /* Reassign an error code */
        }
    }

    /* see: https://www.gnu.org/software/libc/manual/html_node/Deleting-Files.html */
    if (unlink(tmp) != 0) LOG_ERR("unlink(2) fail  path: %s errno: %d", tmp, errno);

out_close:
    (void) close(fd);
out_exit:
    return e;
}

/**
 * Convert a relative path into absolute path under bundle Resources directory
 * @style       style sheet file path
 * @return      an UTF-8 encoded C-string
 */
const char *absolutize_style_path(NSString * _Nullable style)
{
    static NSString *iden = @PLUGIN_BID_S;
    NSString *path = style ? [style stringByExpandingTildeInPath] : nil;
    NSBundle *bundle;

    /* If style not provided or already absolute */
    if (path == nil || [path characterAtIndex:0] == '/') goto out_exit;

    bundle = [NSBundle bundleWithIdentifier:iden];
    if (bundle == nil) {
        path = nil;         /* NULLify relative path */
        goto out_exit;
    }

    path = [bundle pathForResource:path ofType:nil];
    if (path == NULL) {
        LOG_ERR("Cannot found %@ under %@", style, [bundle resourcePath]);
    }

out_exit:
    return path ? [path UTF8String] : NULL;
}

/**
 * [sic strtol(3)] Convert a string value to a long
 *
 * @str     the value string
 * @delim   delimiter character(an invalid one) for a success match
 *          note '\0' for a strict match
 *          other value indicate a substring conversion
 *          NOTE: plus & minus sign need special care
 * @base    numeric base
 * @val     where to store parsed long value
 * @return  1 if parsed successfully  0 o.w.
 *
 * see: https://stackoverflow.com/a/14176593/10725426
 */
int parse_long(const char *str, char delim, int base, long *val)
{
    int ok = 1;
    char *p;
    long t;

    CASSERT_NONNULL(str);
    CASSERT_NONNULL(val);

    errno = 0;
    t = strtol(str, &p, base);

    if (p == str || *p != delim || (errno == ERANGE && (t == LONG_MIN || t == LONG_MAX))) {
        ok = 0;
    } else {
        *val = t;
    }

    return ok;
}

