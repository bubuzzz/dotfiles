;;; config-markdown.el --- -*- lexical-binding: t -*-

(require 'config-diagram)

(defvar config-markdown--fence-regexp
  "^[ \t]*\\(?:```\\|~~~\\)[ \t]*\\([^ \t\n]+\\)?\\(.*\\)$")

(defvar config-markdown--file-regexp
  "\\bfile=\\(?:\"\\([^\"]+\\)\"\\|\\([^ \t]+\\)\\)")

(defvar config-markdown--result-regexp
  "\\(?:[ \t]*\n\\)\\{1,2\\}[ \t]*\\(!\\[[^]]*\\]([^)]*)\\)")

(defun config-markdown--fence-end (end)
  "Return the end of the closing fence line of a block ending at END."
  (save-excursion
    (goto-char end)
    ;; the block may end at the start of the line after the closing fence
    (when (and (bolp) (> end (point-min))) (forward-char -1))
    (line-end-position)))

(defun config-markdown--block ()
  "Return (LANG INFO BODY TAIL) for the fenced block at point, or nil.
INFO is the rest of the opening fence line and TAIL the end of the
closing fence line."
  (when-let* ((bounds (or (markdown-code-block-at-point-p)
                          ;; the block range is right open: point at the end of
                          ;; the closing fence line reads as outside it
                          (markdown-code-block-at-point-p (line-beginning-position))))
              (beg (car bounds))
              (end (cadr bounds))
              (tail (config-markdown--fence-end end)))
    (save-excursion
      (goto-char beg)
      (beginning-of-line)
      (when (looking-at config-markdown--fence-regexp)
        (list (match-string-no-properties 1)
              (match-string-no-properties 2)
              (buffer-substring-no-properties
               (save-excursion (forward-line 1) (point))
               (save-excursion (goto-char tail) (line-beginning-position)))
              tail)))))

(defun config-markdown--file (info)
  "Return the file= value in INFO, or nil."
  (when (and info (string-match config-markdown--file-regexp info))
    (or (match-string 1 info) (match-string 2 info))))

(defun config-markdown--insert (tail link)
  "Put LINK after the block ending at TAIL, replacing a previous one."
  (save-excursion
    (goto-char tail)
    (if (looking-at config-markdown--result-regexp)
        (progn
          (delete-region (match-beginning 1) (match-end 1))
          (goto-char (match-beginning 1))
          (insert link))
      (insert "\n\n" link))))

(defun config-markdown--refresh-images ()
  (when (display-images-p)
    (markdown-remove-inline-images)
    (markdown-display-inline-images)))

(defun config-markdown-render ()
  "Render the diagram block at point to the file named in its fence."
  (interactive)
  (pcase-let* ((`(,lang ,info ,body ,tail)
                (or (config-markdown--block)
                    (user-error "[diagram] no code block at point")))
               (file (or (config-markdown--file info)
                         (user-error "[diagram] file=NAME is required in the fence"))))
    (config-diagram-render lang body (expand-file-name file))
    (config-markdown--insert tail (format "![](%s)" file))
    (config-markdown--refresh-images)
    (message "[diagram] %s" file)))

(defun config-markdown-execute ()
  "Render the diagram block at point, else defer to the markdown command map."
  (interactive)
  (if (config-diagram-backend (car (config-markdown--block)))
      (config-markdown-render)
    (set-transient-map markdown-mode-command-map nil nil "C-c C-c-")))

(defun config-markdown-set ()
  (with-eval-after-load 'markdown-mode
    (define-key markdown-mode-map (kbd "C-c C-c") #'config-markdown-execute)))

;;; ----------------------- Viewing -----------------------

(defvar config-markdown--fixed-pitch-faces
  '(markdown-table-face
    markdown-pre-face
    markdown-code-face
    markdown-inline-code-face
    markdown-language-keyword-face)
  "Faces that must stay monospaced for table pipes to line up.")

(defun config-markdown--fix-pitch (font)
  "Pin FONT on the faces that tables and code depend on."
  (dolist (face config-markdown--fixed-pitch-faces)
    (when (facep face)
      (set-face-attribute face nil :family (font-get (font-spec :name font) :family)
                          :height 'unspecified :width 'normal))))

(defun config-markdown--align-buffer ()
  "Align every table in the buffer."
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward markdown-table-line-regexp nil t)
      (when (markdown-table-at-point-p)
        (markdown-table-align)
        (goto-char (markdown-table-end)))
      (forward-line 1))))

(defun config-markdown-align ()
  "Align the table at point, or every table when point is outside one."
  (interactive)
  (if (markdown-table-at-point-p)
      (markdown-table-align)
    (config-markdown--align-buffer)))

(defun config-markdown--view-setup ()
  "Make the current markdown buffer readable: no wrap, aligned tables."
  ;; both modes kill the local truncate-lines and word-wrap on exit, so they
  ;; have to go off before those values are set
  (when (bound-and-true-p visual-line-mode) (visual-line-mode -1))
  (when (bound-and-true-p olivetti-mode) (olivetti-mode -1))
  (setq-local truncate-lines t
              word-wrap nil)
  (add-hook 'before-save-hook #'config-markdown--align-buffer nil t))

(defun config-markdown-view-set (font)
  "Set up markdown viewing with FONT pinned on code and table faces."
  (with-eval-after-load 'markdown-mode
    (setq markdown-table-align-p t
          markdown-fontify-code-blocks-natively t
          markdown-hide-urls t)
    (config-markdown--fix-pitch font)
    (define-key markdown-mode-map (kbd "C-c C-t") #'config-markdown-align))
  (add-hook 'markdown-mode-hook #'config-markdown--view-setup))

(provide 'config-markdown)
