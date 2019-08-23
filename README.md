qfilter.vim
===========

*A filter for quickfix and loclist in vim*

### Overview

For help understanding what quickfix is, refer to `:help quickfix` in vim. It
will suffice to say that the quickfix list is very useful if you are familiar
with the `:make` and `:grep` commands. As a small example, if you run `:grep!
"foo" someFile`, then you can use `:copen` to open the quickfix list and see the
results. Pressing `<Return>` on any entry will jump to that file on the
particular line and column in a separate window.

This plugin uses `ftplugin` to create a few commands and mappings for the
quickfix and location lists--both commonly referred to as a qf list--to help
filter or narrow down results. This plugin exposes the buffer-local `:Keep` and
`:Reject` commands that will either keep or discard lines by matching patterns
in the metadata inside the qf list as well as the `d` operator that acts like
`d` in normal buffers and will remove lines from the current qf list. These
utilities are further detailed below. 

### Commands

| Command  | Description |
| -------  | ----------- |
| `:Keep /\<bar\>/`   | Keep all lines that contain `bar`. This is a regex match, and it searches the *text metadata* in the qf list. Note the `/\<` and `/\>` which means "bar" must not be embedded in a larger word. |
| `:Reject /bar/`     | Same as `:Keep /bar/` but remove all lines that contain `bar`. Also, note that since there is no `/\<` or `/\>`, "bar" can be embedded in a larger word. |
| `:KeepFile a.txt`   | Keep all lines that contain the partial match for a file `a.txt`. This is not a regex match (so `/.` will match a literal `'.'`), and it searches the *file metadata* in the qf list. Note: **it will match a _substring_**. |
| `:RejectFile a.txt` | Same as above but remove all lines that partially match `a.txt`. |
| `:KeepAll /foo/`    | Same as `:Keep /foo/` but this will also match (with vim regex) files. I.e., both `foobar.txt` in the file metadata and `function s:foo()` in the text metadata will be kept. |
| `:RejectAll /foo/`  | Same as `:Reject /foo/` but instead of keeping `foo`, reject it. |

### Operators

#### Delete

Currently, there is only the delete operator. When in normal mode in a qf list,
use `dd`, `d{motion}` (e.g., `d2j`), or `d` after visually selecting with `V` to
remove the specified lines.

### TODO

- Allow for `:KeepFile` and `:RejectFile` to match only whole files by
  potentially adding `/^` and `/$` to the beginning/end (resp.) of the pattern
  but only if `/[^[:alnum:]]` surrounding the pattern (still stays a non-regex
  search, though)
