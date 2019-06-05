# MikroTik RouterOS Codeless language module
Support for syntax highlighting opening `.rsc` files in BBEdit.

Place the `MikroTikRouterOS.plist` file in your `Application Support/BBEdit/Language Modules` folder.

## Please Note / TODO
This is a work in progress. At the moment strings are not properly parsed when multi line.
Also would be nice if number always were parsed as number, even within strings.
Maybe also alpha numerics (mac address etc) as numbers would be nice.

Also would like to get variables to be reconized and parsed as such, so that for example `$MyVar` would be recognized as variable.

(If you wonder: I've focused mainly on getting different colors in the syntax highlighting, not on it being correct type.)

## Licence
As stated in the `.plist` file:  


## Change log
### Version 1.x
Created for BBEdit 12.x.
