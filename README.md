## ManPageQL

### Development status

Going to fix following bug:

```
2019-02-23 17:27:01.430 Df QuickLookSatellite[8221:41a33] (ManPageQL) Thumbnail file:///usr/share/man/man2/_exit.2  content size: 5898
2019-02-23 17:27:11.618 Df QuickLookSatellite[8222:41dc5] (ManPageQL) Thumbnail file:///usr/share/man/man2/fsetattrlist.2  content size: 969
2019-02-23 17:27:21.940 Df QuickLookSatellite[8223:42181] (ManPageQL) Thumbnail file:///usr/share/man/man2/adjtime.2  content size: 6356
2019-02-23 17:27:32.251 Df QuickLookSatellite[8224:424fa] (ManPageQL) Thumbnail file:///private/tmp/unlink.2  content size: 11173
2019-02-23 17:27:42.473 Df QuickLookSatellite[8225:42886] (ManPageQL) Thumbnail file:///usr/share/man/man2/fstat64.2  content size: 962
2019-02-23 17:27:52.590 Df QuickLookSatellite[8228:42c39] (ManPageQL) Preview file:///private/tmp/unlink.2  content size: 11173
2019-02-23 17:27:52.590 Df QuickLookSatellite[8228:42c39] (ManPageQL) [ERR] dup(2) fail  errno: 9
2019-02-23 17:27:52.591 Df QuickLookSatellite[8228:42c39] (ManPageQL) [ERR] mandoc2html_buffer() fail  url: file:///private/tmp/unlink.2 err: -2
2019-02-23 17:27:52.591 Df QuickLookSatellite[8228:42c39] (ManPageQL) [ERR] dup(2) fail  errno: 9
2019-02-23 17:27:52.591 Df QuickLookSatellite[8228:42c39] (ManPageQL) [ERR] mandoc2html_buffer() fail  url: file:///usr/share/man/man2/futimes.2 err: -2
2019-02-23 17:27:52.592 Df QuickLookSatellite[8228:42c39] (ManPageQL) [ERR] dup(2) fail  errno: 9
2019-02-23 17:27:52.592 Df QuickLookSatellite[8228:42c39] (ManPageQL) [ERR] mandoc2html_buffer() fail  url: file:///usr/share/man/man2/getattrlist.2 err: -2
2019-02-23 17:27:52.592 Df QuickLookSatellite[8228:42c39] (ManPageQL) [ERR] dup(2) fail  errno: 9
2019-02-23 17:27:52.593 Df QuickLookSatellite[8228:42c39] (ManPageQL) [ERR] mandoc2html_buffer() fail  url: file:///usr/share/man/man2/getlogin.2 err: -2
2019-02-23 17:27:52.593 Df QuickLookSatellite[8228:42c39] (ManPageQL) [ERR] dup(2) fail  errno: 9
2019-02-23 17:27:52.593 Df QuickLookSatellite[8228:42c39] (ManPageQL) [ERR] mandoc2html_buffer() fail  url: file:///usr/share/man/man2/getaudit_addr.2 err: -2
2019-02-23 17:27:52.594 Df QuickLookSatellite[8228:42c39] (ManPageQL) [ERR] dup(2) fail  errno: 9
2019-02-23 17:27:52.594 Df QuickLookSatellite[8228:42c39] (ManPageQL) [ERR] mandoc2html_buffer() fail  url: file:///usr/share/man/man2/getpgid.2 err: -2
2019-02-23 17:27:52.594 Df QuickLookSatellite[8228:42c39] (ManPageQL) [ERR] dup(2) fail  errno: 9
...
2019-02-23 17:27:52.713 Df QuickLookSatellite[8228:42c39] (ManPageQL) [ERR] dup(2) fail  errno: 9
2019-02-23 17:27:52.713 Df QuickLookSatellite[8228:42c39] (ManPageQL) [ERR] mandoc2html_buffer() fail  url: file:///usr/share/man/man2/recvfrom.2 err: -2
2019-02-23 17:27:52.714 Df QuickLookSatellite[8228:42c39] (ManPageQL) [ERR] fdopen(3) fail, stdout goes haywire  fd: 4 errno: 22
2019-02-23 17:27:52.851 Df QuickLookSatellite[8228:42c39] (ManPageQL) Thumbnail file:///usr/share/man/man2/recvmsg.2  content size: 962
2019-02-23 17:28:03.211 Df QuickLookSatellite[8229:42fd1] (ManPageQL) Thumbnail file:///usr/share/man/man2/sendto.2  content size: 962
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

### *References*

[clang, change dependent shared library install name at link time](https://stackoverflow.com/questions/27506450/clang-change-dependent-shared-library-install-name-at-link-time)

[Install_name on OS X](http://log.zyxar.com/blog/2012/03/10/install-name-on-os-x/)

[Xcode Build Settings Reference](https://pewpewthespells.com/blog/buildsettings.html)

[Creating Dynamic Libraries](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/DynamicLibraries/100-Articles/CreatingDynamicLibraries.html)

---

*Created 190219+0800*