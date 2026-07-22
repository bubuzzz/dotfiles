;;; config-statusline.el --- -*- lexical-binding: t -*-

(defface config-statusline-modified-face
  '((t :foreground "purple" :weight bold))
  "Face for unsaved file components in the mode-line."
  :group 'mode-line-faces)

(defun config-statusline--file-info ()
  (let* ((path (buffer-file-name))
         (modified (and path (buffer-modified-p)))
         (path-face (if modified 'config-statusline-modified-face 'mode-line-inactive))
         (name-face (if modified 'config-statusline-modified-face 'font-lock-keyword-face)))
    (if path
        (concat
         (propertize (abbreviate-file-name (file-name-directory path)) 'face path-face)
         (propertize (file-name-nondirectory path) 'face name-face))
      (propertize "%b" 'face 'font-lock-string-face))))

(defun config-statusline-set ()
  (line-number-mode 1)
  (column-number-mode 1)
  (setq-default mode-line-format
                '((:eval
                   (concat
                    (propertize " [%b] " 'face 'font-lock-type-face)
                    (config-statusline--file-info)
                    " "
                    (propertize
                     (make-string (max 1 (- (window-total-width)
                                            (length (buffer-name))
                                            (length (or (buffer-file-name) ""))
                                            25))
                                  ?\s)
                     'face 'mode-line)
                    (propertize " Ln %l, Col %c " 'face 'mode-line-inactive))))))

(provide 'config-statusline)
