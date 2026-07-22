;;; config-evil.el --- -*- lexical-binding: t -*-

(defun config-evil-set ()
  (setq evil-want-keybinding nil)
  (require 'evil)
  (evil-mode 1)
  (require 'evil-collection)
  (evil-collection-init)

  (setq select-enable-clipboard t
        select-enable-primary t
        evil-interprogram-cut-function #'gui-select-text
        evil-interprogram-paste-function #'gui-selection-value
        evil-visual-update-x-selection nil
        evil-kill-on-visual-paste nil)

  (unless (display-graphic-p)
    (require 'xclip)
    (xclip-mode 1)))

(provide 'config-evil)
