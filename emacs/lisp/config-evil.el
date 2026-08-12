;;; config-evil.el --- -*- lexical-binding: t -*-

(defun config-evil-set ()
  (setq evil-want-keybinding nil)
  (require 'evil)
  (setopt evil-undo-system 'undo-redo)
  (evil-mode 1)
  (require 'evil-collection)
  (evil-collection-init)

  (setq select-enable-clipboard t
        select-enable-primary t
        evil-visual-update-x-selection-p nil
        evil-kill-on-visual-paste nil)

  (unless (display-graphic-p)
    (require 'xclip)
    (xclip-mode 1)))

(provide 'config-evil)
