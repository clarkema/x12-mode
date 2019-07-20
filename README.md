# x12-mode

An Emacs major mode for working with X12 EDI files.

## Installation

 1. Copy `x12-mode.el` to somewhere in your `load-path`
 2. Add the following to `$HOME/.emacs.d/init.el`:

```elisp
(autoload 'x12-mode "x12-mode" "" t)
;; Add more file extensions as required
(add-to-list 'auto-mode-alist '("\\.x12\\'" . x12-mode))
```

## Features

 * Basic syntax highlighting
 * `C-c C-p` will prettify the current buffer, showing one X12 segment
   per line.
 * `C-c C-u` reverses the prettify operation, removing newlines so the
   entire document is a single line.

