## ManPageQL

### Intro

ManPageQL is a macOS Quick Look plugin used to preview [*nix manual page](https://en.wikipedia.org/wiki/Man_page), it uses [mandoc](https://mandoc.bsd.lv/) to render HTML format output.

Current only support limited man page extensions: `.1`, `.2`, `.3`, `.4`, `.5`, `.6`, `.7`, `.8`, `.9`, `.n`

### Compile

NOTE: This repository uses [Git-LFS](https://git-lfs.github.com/) to track `dylib`, make sure `dylib` files are fetched to local before `make`.

This project is managed by `Makefile` and `Makefile.inc`, thus you can simply run `make` in terminal for a debug build, append `release` for a release build.

### Install & uninstall

```shell
# Install/uninstall Quick Look plugin for current user
make install
make uninstall

# Install/uninstall Quick Look plugin for all users
PREFIX=/Library/QuickLook sudo make install
PREFIX=/Library/QuickLook sudo make uninstall

# Remove all settings
defaults delete cn.junkman.quicklook.ManPageQL
```

### Debugging & test

```
# for macOS >= 10.13
log stream --style compact --predicate 'process == "QuickLookSatellite" AND eventMessage CONTAINS "ManPageQL"' --color=auto

# for macOS >= 10.12
log stream --style compact --predicate 'process == "QuickLookSatellite" AND eventMessage CONTAINS "ManPageQL"'

# for macOS < 10.12
syslog -w 0 -k Sender QuickLookSatellite -k Message S ManPageQL
```

### Settings

* Read current settings

	```shell
	defaults read cn.junkman.quicklook.ManPageQL
	```

* Turn on raw text preview

	```shell
	defaults write cn.junkman.quicklook.ManPageQL RawTextForPreview -bool TRUE
	```

* Turn on raw text thumbnail

	```shell
	defaults write cn.junkman.quicklook.ManPageQL RawTextForThumbnail -bool TRUE
	```

* Use custom style sheet for preview(won't affect behaviour of manual page thumbnailing)

	```shell
	defaults write cn.junkman.quicklook.ManPageQL StyleSheetForPreview -string <file>
	```

	The `<file>` is a path to the custom style sheet file, it can either be a absolute path, or a relative path, when specify a relative path, the file will search from plugin bundle's `Resources` directory.

	`~`, `.`, `..` are thusly supported.

	There're several embedded style sheets in `Resources` directory:

	* mandoc.css

	* fixed.css

### Compile `libmandoc2html` shared library

`libmandoc2html` use [mandoc](https://mandoc.bsd.lv/) as its core functionalities, it's merely a wrapper of [mandoc](https://mandoc.bsd.lv/), which this Quick Look plugin is link against it.

HOWTO compile `libmandoc2html.dylib` from latest [mandoc](https://mandoc.bsd.lv/) source

```shell
# Clone mandoc CVS repository
# see: https://mandoc.bsd.lv/anoncvs.html
$ cvs -d anoncvs@mandoc.bsd.lv:/cvs co mandoc

$ cd mandoc
# Replace $MANPAGEQL_REPO_DIR to this repo path on your computer
$ patch < $MANPAGEQL_REPO_DIR/mandoc/make.patch
patching file Makefile
patching file Makefile.depend
patching file configure
patching file configure.local.example

$ ./configure
$ cp $MANPAGEQL_REPO_DIR/mandoc/mandoc2html.c .
$ cp $MANPAGEQL_REPO_DIR/mandoc/mandoc2html.h .
$ make mandoc2html
```

Copy generated `libmandoc2html.dylib` into `$MANPAGEQL_REPO_DIR/mandoc`

<br>

HOWTO check `libmandoc2html.dylib`'s version

```shell
$ otool -L libmandoc2html.dylib
libmandoc2html.dylib:
	@loader_path/libmandoc2html.dylib (compatibility version 1.0.0, current version 1.14.4)
	/usr/lib/libz.1.dylib (compatibility version 1.0.0, current version 1.2.11)
	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1252.50.4)
```

### TODO

* Add user-configurable options

 	* [**DONE**] Allow user to use raw text thumbnail/preview

 	* Allow user to specify preview width/height

 	* ...

* Use hash-encoded name to cache-up on-disk files

* Support `.so` requests. Hint: use `chdir(2)` before generate output?

* Support thumbnail/preview of `gzip`-ed man page files([mandoc](https://mandoc.bsd.lv/) supports parse `gzip`-ed man page file natively)

	Hint: extensions: `.1.gz`, `.2.gz`, ...

* Support universal man page file detection, instead of known extensions like `.1`, `.2`, ...

	Hint: use `file --brief --mime-type FILE` for detection?

* Support man page symlink thumbnail/preview

* Support custom `os_s` in `mparse_alloc(int, enum mandoc_os, const char *);`

* [**DONE**] Support `-Ostyle=style.css` option in `mandoc2html`

* Use `@rpath` instead of `@loader_path` in `libmandoc2html.dylib`?

* Support `nroff(1)` + cat2html for thumbnail/preview?

<br>

### Contributing

If you ready to gets your hands dirty, here are the guidelines for contributing:

* Fork this repository and clone to your local machine

* Create a new branch and add some commits

* Push your local branch to your fork

* Submit a pull request upstream

### License

Please regard `LICENSE` file

### Screenshots

![](screenshots/1.png)

![](screenshots/2.png)

![](screenshots/3.png)

### *References*

[clang, change dependent shared library install name at link time](https://stackoverflow.com/questions/27506450/clang-change-dependent-shared-library-install-name-at-link-time)

[Install_name on OS X](http://log.zyxar.com/blog/2012/03/10/install-name-on-os-x/)

[Xcode Build Settings Reference](https://pewpewthespells.com/blog/buildsettings.html)

[Creating Dynamic Libraries](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/DynamicLibraries/100-Articles/CreatingDynamicLibraries.html)

[ExampleQL - Makefile for macOS Quick Look plugin](https://github.com/lynnlx/quicklook_plugin)

[How to open/link external files inside a HTML-designed QuickLook plugin without using the <src> attribute?](https://stackoverflow.com/questions/23758539/how-to-open-link-external-files-inside-a-html-designed-quicklook-plugin-without)

[Dynamically Generating Previews#Generating Enriched HTML](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/Quicklook_Programming_Guide/Articles/QLDynamicGeneration.html#//apple_ref/doc/uid/TP40005020-CH15-SW2)

---

*Created 190219+0800*