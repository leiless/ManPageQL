#
# Put user-defined variables here
#

PLUGIN_NAME=ManPageQL
PLUGIN_VERSION=0000.00.06
PLUGIN_BUILD:=$(shell ./bump_build.sh)
BUNDLE_DOMAIN=cn.junkman
#
# Supported UTI types(use space to separate each one)
# Do NOT use any quote character
# NOTE: use mdls(1) to fetch kMDItemContentType info
#
# .1 .2 .3 .4 .5 .6 .7 .8 .9 .n dynamic UTIs
#
PLUGIN_SUPPORTED_UTI=dyn.ah62d4rv4ge8xc dyn.ah62d4rv4ge8xe dyn.ah62d4rv4ge8xg dyn.ah62d4rv4ge8xk dyn.ah62d4rv4ge8xn dyn.ah62d4rv4ge8xq dyn.ah62d4rv4ge8xs dyn.ah62d4rv4ge8xu dyn.ah62d4rv4ge8xw dyn.ah62d4rv4ge806
LDFLAGS+=-Lmandoc -lmandoc2html

