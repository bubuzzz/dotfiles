;;; config-theme.el --- -*- lexical-binding: t -*-

(defvar config-theme--ring nil)

(defun config-theme-toggle ()
  (interactive)
  (let ((next (or (cadr (memq (car custom-enabled-themes) config-theme--ring))
                  (car config-theme--ring))))
    (mapc #'disable-theme custom-enabled-themes)
    (load-theme next t)
    (message "%s" next)))

(defun config-theme-set (themes toggle-key)
  (require 'doom-themes)
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  (doom-themes-org-config)

  (setq config-theme--ring themes)
  (load-theme (car themes) t)
  (keymap-global-set toggle-key #'config-theme-toggle))

(provide 'config-theme)
