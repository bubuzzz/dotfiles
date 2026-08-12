;;; config-theme.el --- -*- lexical-binding: t -*-

(defvar config-theme--ring nil)

(defun config-theme-appearance ()
  "Return the appearance, `dark' or `light', of the active theme."
  (alist-get (car custom-enabled-themes) config-theme--ring 'dark))

(defun config-theme-toggle ()
  (interactive)
  (let* ((themes (mapcar #'car config-theme--ring))
         (next (or (cadr (memq (car custom-enabled-themes) themes))
                   (car themes))))
    (mapc #'disable-theme custom-enabled-themes)
    (load-theme next t)
    (message "%s" next)))

(defun config-theme-set (themes)
  "Load the first theme in THEMES, an alist of (THEME . dark|light)."
  (require 'doom-themes)
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  (doom-themes-org-config)

  (setq config-theme--ring themes)
  (load-theme (caar themes) t))

(provide 'config-theme)
