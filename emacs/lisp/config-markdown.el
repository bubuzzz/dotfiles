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

(provide 'config-markdown)
