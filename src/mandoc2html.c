/*
 * Created 190217 lynnl
 *
 * directories:
 *	/usr/share/man
 *	/usr/local/share/man
 *
 * see:
 *  https://github.com/sizeofvoid/ifconfigd/blob/master/usr/src/usr.bin/mandoc/main.c
 *  mandoc/main.c#189
 *  mandoc/demandoc.c
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <errno.h>
#include <unistd.h>
#include <sys/stat.h>

#include "mandoc.h"
#include "roff.h"
#include "mandoc_parse.h"
#include "manconf.h"

#define UNUSED(a0, ...)         (void) ((void) a0, ##__VA_ARGS__)

#define LOG(fmt, ...)           fprintf(stderr, fmt "\n",  ##__VA_ARGS__)
#define LOG_ERR(fmt, ...)       fprintf(stderr, fmt "\n", ##__VA_ARGS__)
#ifndef DEBUG
#define LOG_DBG(fmt, ...)       LOG("[DBG] " fmt, ##__VA_ARGS__)
#else
#define LOG_DBG(fmt, ...)       UNUSED(fmt, ##__VA_ARGS__)
#endif

#define ASSERT(e)               assert(e)
#define ASSERT_NONNULL(p)       ASSERT(p != NULL)

enum outt {
    OUTT_ASCII = 0,     /* -Tascii */
    OUTT_LOCALE,        /* -Tlocale */
    OUTT_UTF8,          /* -Tutf8 */
    OUTT_TREE,          /* -Ttree */
    OUTT_MAN,           /* -Tman */
    OUTT_HTML,          /* -Thtml */
    OUTT_MARKDOWN,      /* -Tmarkdown */
    OUTT_LINT,          /* -Tlint */
    OUTT_PS,            /* -Tps */
    OUTT_PDF            /* -Tpdf */
};

struct curparse {
    struct mparse *mp;
    struct manoutput *outopts;  /* output options */
    void *outdata;              /* data for output */
    char *os_s;                 /* operating system for display */
    enum mandoc_os os_e;        /* check base system conventions */
    enum outt outtype;          /* which output to use */
};

static void usage(void);
static void outdata_alloc(struct curparse *);
static void print_meta(const struct roff_meta *);
static int parse(const char *path);
static int do_parse(struct curparse *curp, int, const char *);

void usage(void)
{
    fprintf(stderr, "usage: man_roff_file\n");
    exit(-1);
    __builtin_unreachable();
}

int main(int argc, char *argv[])
{
    if (argc != 2) usage();
    return parse(argv[1]);
}

/**
 * Parse a man page file
 * @path        which file
 * @return      0 if no error  error o.w.
 */
static int parse(const char *path)
{
    int e;
    struct manconf conf;
    struct curparse curp;
    int options;
    int fd;
    struct stat st;

    ASSERT_NONNULL(path);

    (void) memset(&conf, 0, sizeof(conf));
    (void) memset(&curp, 0, sizeof(curp));
    curp.outtype = OUTT_HTML;
    curp.outopts = &conf.output;
    /* ASK: do we need MPARSE_SO flag */
    options = MPARSE_SO | MPARSE_UTF8 | MPARSE_LATIN1 | MPARSE_VALIDATE;

    /* Print parse warning to `stderr' */
    mandoc_msg_setoutfile(stderr);
    mandoc_msg_setmin(MANDOCERR_WARNING);

    mchars_alloc();
    curp.mp = mparse_alloc(options, curp.os_e, curp.os_s);
    ASSERT_NONNULL(curp.mp);

    mparse_reset(curp.mp);
    fd = mparse_open(curp.mp, path);
    if (fd < 0) {
        LOG_ERR("mparse_open() fail  path: %s errno: %d", path, errno);
        e = 1;
        goto out_exit;
    }

    if (fstat(fd, &st) < 0) {
        LOG_ERR("fstat(2) fail  path: %s fd: %d errno: %d", path, fd, errno);
        e = 2;
        (void) close(fd);
        goto out_exit;
    }
    if (!S_ISREG(st.st_mode)) {
        e = 3;
        (void) close(fd);
        LOG_ERR("path %s isn't regular file?  mode: %#x", path, st.st_mode);
        goto out_exit;
    }

    e = do_parse(&curp, fd, path);

out_exit:
    mparse_free(curp.mp);
    mchars_free();

    return e;
}

/**
 * Those two functions not exported
 * see:
 *  mandoc/man_html.c#html_mdoc
 *  mandoc/man_html.c#html_man
 *  mandoc/man_html.c#html_alloc
 */
extern void html_mdoc(void *, const struct roff_meta *);
extern void html_man(void *, const struct roff_meta *);
extern void *html_alloc(const struct manoutput *);

void outdata_alloc(struct curparse *curp)
{
    ASSERT_NONNULL(curp);
    ASSERT(curp->outtype == OUTT_HTML);
    curp->outdata = html_alloc(curp->outopts);
}

int do_parse(struct curparse *curp, int fd, const char *path)
{
    int e = 0;
    struct roff_meta *meta;

    ASSERT_NONNULL(curp);
    ASSERT(fd >= 0);
    ASSERT_NONNULL(path);

    mparse_readfd(curp->mp, fd, path);
    (void) close(fd);

    if (curp->outdata == NULL) outdata_alloc(curp);
    ASSERT_NONNULL(curp->outdata);

    meta = mparse_result(curp->mp);
    ASSERT_NONNULL(meta);

    print_meta(meta);

    if (meta->macroset == MACROSET_MDOC) {
        html_mdoc(curp->outdata, meta);
    } else if (meta->macroset == MACROSET_MAN) {
        html_man(curp->outdata, meta);
    } else {
        e = 4;      /* Unsupported macroset */
    }

    return e;
}

void print_meta(const struct roff_meta *meta)
{
    ASSERT_NONNULL(meta);

    if (meta->title != NULL)
        LOG("title = \"%s\"", meta->title);
    if (meta->name != NULL)
        LOG("name  = \"%s\"", meta->name);
    if (meta->msec != NULL)
        LOG("sec   = \"%s\"", meta->msec);
    if (meta->vol != NULL)
        LOG("vol   = \"%s\"", meta->vol);
    if (meta->arch != NULL)
        LOG("arch  = \"%s\"", meta->arch);
    if (meta->os != NULL)
        LOG("os    = \"%s\"", meta->os);
    if (meta->date != NULL)
        LOG("date  = \"%s\"", meta->date);
}

