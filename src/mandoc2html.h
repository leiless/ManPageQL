/*
 * Created 190220 lynnl
 */

#ifndef MANDOC2HTML_H
#define MANDOC2HTML_H

#define M2H_ERR_SUCCESS             0
#define M2H_ERR_MPARSE_OPEN         1
#define M2H_ERR_SYSCALL_FSTAT       2
#define M2H_ERR_NOT_ISREG           3
#define M2H_ERR_BAD_MACROSET        4

/**
 * Convert man roff to HTML output
 * @return      0 if success  error code o.w.
 * NOTE: output prints to stdout due to mandoc limitation
 */
int mandoc2html(const char *);

#endif  /* MANDOC2HTML_H */

