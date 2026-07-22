;;; config-shortcut.el --- -*- lexical-binding: t -*-

(defun config-shortcut-set (leader shortcuts mode-shortcuts)
  (require 'general)
  (general-evil-setup)

  (apply #'general-define-key
         :states '(normal visual motion)
         :keymaps 'override
         :prefix leader
         :global-prefix (concat "C-" leader)
         shortcuts)

  (dolist (spec mode-shortcuts)
    (apply #'general-define-key
           :states '(normal visual motion)
           :keymaps (car spec)
           :prefix leader
           (cdr spec))))

(provide 'config-shortcut)
