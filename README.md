# vers
Prints version information for easy pasting into Bug Reporter. Use it like this:
```shell
$ vers [product] 2> /dev/null
```
where [product] is one of the following:
* Mac: Hardware information in the form "MacBook Pro (Retina, 13-inch, Early 2015)"
* macOS: Operating system information in the form "macOS High Sierra 10.13.1 Beta (17B35a)"
* Xcode: Xcode information for Xcode (or Xcode-beta, if it's available) in the form "Xcode Version 9.1 beta (9B46)"

The `2> /dev/null` is currently necessary because vers links to Xcode's frameworks to extract this information, which causes some Swift-related classes to be duplicated and makes the Objective-C runtime complain. I'm working on a better fix for this.
