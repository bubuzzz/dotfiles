;;; config-sync.el --- -*- lexical-binding: t -*-

;; Keeping buffers in step with files an outside process (an AI agent, a
;; formatter, a git checkout) rewrites underneath Emacs.
;;
;; Two distinct situations, deliberately handled differently:
;;
;;   buffer unmodified -> nothing to lose, so pull the new contents in
;;                        silently via `global-auto-revert-mode'.
;;
;;   buffer modified   -> two sets of edits genuinely diverge.  Auto-revert
;;                        refuses to touch such a buffer (correctly), so
;;                        `config-sync-diff' opens an ediff of buffer vs disk
;;                        to merge hunk by hunk instead of discarding blind.

(require 'autorevert)

(defvar ediff-window-setup-function)
(defvar ediff-split-window-function)
(declare-function ediff-setup-windows-plain "ediff-wind")

(defvar config-sync--window-config nil
  "Window configuration saved before ediff took over the frame.")

(defun config-sync--save-windows ()
  (setq config-sync--window-config (current-window-configuration)))

(defun config-sync--restore-windows ()
  (when config-sync--window-config
    (set-window-configuration config-sync--window-config)
    (setq config-sync--window-config nil)))

(defun config-sync-diff ()
  "Merge the current buffer against its file on disk with ediff.
Use when a file has changed underneath an edited buffer: `a' takes the
buffer's version of a hunk, `b' the version on disk, `n'/`p' move
between hunks and `q' ends the session."
  (interactive)
  (unless buffer-file-name
    (user-error "[sync] buffer is not visiting a file"))
  (unless (file-exists-p buffer-file-name)
    (user-error "[sync] file no longer on disk: %s" buffer-file-name))
  (if (and (not (buffer-modified-p))
           (verify-visited-file-modtime (current-buffer)))
      (message "[sync] buffer and file are identical")
    (ediff-current-file)))

(defun config-sync-diff-plain ()
  "Show a read-only diff of the current buffer against its file on disk."
  (interactive)
  (unless buffer-file-name
    (user-error "[sync] buffer is not visiting a file"))
  (diff-buffer-with-file (current-buffer)))

(defun config-sync-set ()
  "Revert unmodified buffers automatically; leave modified ones alone."
  ;; File notifications make this event-driven; the interval is only a
  ;; fallback for filesystems that cannot notify.
  (setq auto-revert-verbose nil          ; no echo-area line per revert
        auto-revert-avoid-polling t
        auto-revert-check-vc-info t)     ; keep the VC state in the mode line fresh
  (global-auto-revert-mode 1)

  (with-eval-after-load 'ediff
    ;; Default setup spawns a separate control frame, which is wrong in a
    ;; terminal and awkward in a tiling window manager.
    (setq ediff-window-setup-function #'ediff-setup-windows-plain
          ediff-split-window-function #'split-window-horizontally))

  ;; ediff rearranges the frame and does not put it back on its own.
  (add-hook 'ediff-before-setup-hook #'config-sync--save-windows)
  (add-hook 'ediff-quit-hook #'config-sync--restore-windows t))

(provide 'config-sync)
