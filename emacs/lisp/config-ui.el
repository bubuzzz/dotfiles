;;; config-ui.el --- -*- lexical-binding: t -*-

(defun config-ui-set (font)
  (menu-bar-mode -1)
  (when (fboundp 'tool-bar-mode) (tool-bar-mode -1))
  (when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
  (add-to-list 'default-frame-alist (cons 'font font))
  (setq display-line-numbers-type 'relative
        dired-kill-when-opening-new-buffer t)
  (add-hook 'prog-mode-hook #'display-line-numbers-mode)
  (add-hook 'text-mode-hook #'display-line-numbers-mode))

(provide 'config-ui)
