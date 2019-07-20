;;;
;;; x12-mode.el
;;;
;;; An Emacs major mode for editing X12 EDI files.
;;;
;;; Copyright (C) 2019 Michael Clarke
;;;

(defvar x12-max-pretty-buffer-size 10485760) ; 10MB

(defvar x12-prettify-filter nil)
(defvar x12-uglify-filter nil)

(defvar x12-mode-map nil "Keymap for X12-mode")
(setq x12-mode-map (make-sparse-keymap))
(define-key x12-mode-map (kbd "C-c C-p") 'x12-prettify)
(define-key x12-mode-map (kbd "C-c C-u") 'x12-uglify)

(define-key x12-mode-map [menu-bar] (make-sparse-keymap))

(let ((menu-map (make-sparse-keymap)))
  (define-key x12-mode-map [menu-bar x12]
    (cons "X12" menu-map))
  (define-key menu-map [prettify]
    '("Prettify X12 file" . x12-prettify))
  (define-key menu-map [uglify]
    '("Uglify X12 file" . x12-uglify)))
  
(define-derived-mode x12-mode fundamental-mode "X12"
  "Major mode for X12 EDI files."
  (make-local-variable 'x12-segment-separator)
  (let ((isa-segment (buffer-substring-no-properties
                      (point-min)
                      (+ (point-min) 106))))
    (if (string= (substring isa-segment 0 3) "ISA")
        (let ((component (substring isa-segment 104 105))
              (element (substring isa-segment 103 104)))
          (setq x12-segment-separator (substring isa-segment 105 106))
          (setq font-lock-defaults
                `(((,x12-segment-separator . font-lock-warning-face)
                   (,element . font-lock-warning-face)
                   ("^\\(ISA\\|GS\\|ST\\|SE\\|GE\\|IEA\\)" . font-lock-constant-face)
                   ("^[A-Z0-9]+" . font-lock-keyword-face))))
          (if (< (buffer-size) x12-max-pretty-buffer-size)
              (x12-prettify)
            (message "Buffer larger than auto-prettify.  Run C-c C-p")))
      (message "Cannot parse ISA segment; unable to detect separators."))))


(defun x12-prettify ()
  (interactive)
  (if x12-prettify-filter
      (shell-command-on-region (point-min) (point-max) x12-prettify-filter nil t)
    (save-excursion
      (goto-char (point-min))
      (while (search-forward-regexp (concat "\\(" x12-segment-separator "\\)"
                                            "\\([^[:space:]]\\)")
                                    nil t)
        (replace-match "\\1\n\\2")))))

(defun x12-uglify ()
  (interactive)
  (if x12-uglify-filter
      (shell-command-on-region (point-min) (point-max) x12-uglify-filter nil t)
    (save-excursion
      (goto-char (point-min))
      (while (search-forward-regexp (concat x12-segment-separator
                                            "[[:space:]]*")
                                    nil t)
        (replace-match x12-segment-separator)))))

(provide 'x12-mode)
