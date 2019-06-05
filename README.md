# MikroTik RouterOS Codeless language module
Support for syntax highlighting opening `.rsc` files in BBEdit.

Place the `MikroTikRouterOS.plist` file in your `Application Support/BBEdit/Language Modules` folder.

## Please Note / TODO
This is a work in progress. At the moment strings are not properly parsed when multi line.
Also would be nice if number always were parsed as number, even within strings.
Maybe also alpha numerics (mac address etc) as numbers would be nice.

Also would like to get variables to be reconized and parsed as such, so that for example `$MyVar` would be recognized as variable.

(If you wonder: I've focused mainly on getting different colors in the syntax highlighting, not on it being correct type.)

## Change Log
### v0.2 - 20190605
Fixed some parsing, sorted into different keyword categories

### v0.1 - 20190223
Initial file. Not really working too well. ;-)
Created for BBEdit 12.6.x

## Licence
As stated in the `.plist` file:  
Released under a
[Creative Commons Attribution-ShareAlike License](<http://www.creativecommons.org/licenses/by-sa/3.0/)

### Related URLs/Links

- [MikroTik](https://mikrotik.com/)
- [BBEdit](https://www.barebones.com/products/bbedit/index.html)