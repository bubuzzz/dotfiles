;;; config-statusline.el --- -*- lexical-binding: t -*-

(defface config-statusline-modified-face
  '((t :inherit warning :weight bold))
  "Face for unsaved file components in the mode-line."
  :group 'mode-line-faces)

(defun config-statusline--file-info ()
  (let* ((path (buffer-file-name))
         (modified (and path (buffer-modified-p)))
         (path-face (if modified 'config-statusline-modified-face 'mode-line))
         (name-face (if modified 'config-statusline-modified-face 'mode-line-buffer-id)))
    (if path
        (concat
         (propertize (abbreviate-file-name (file-name-directory path)) 'face path-face)
         (propertize (file-name-nondirectory path) 'face name-face))
      (propertize "%b" 'face 'mode-line-buffer-id))))

(defun config-statusline-set ()
  (line-number-mode 1)
  (column-number-mode 1)
  (setq-default mode-line-format
                '((:eval
                   (concat
                    " "
                    (config-statusline--file-info)
                    (propertize " " 'display '(space :align-to (- right 17)))
                    (propertize " Ln %l, Col %c " 'face 'mode-line))))))

(provide 'config-statusline)
