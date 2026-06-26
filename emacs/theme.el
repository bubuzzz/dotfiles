;;; theme.el -*- lexical-binding: t; -*-
;;
;; Appearance: font, doom theme, and the TTY background hack.
;; Ported from the old Doom config to vanilla Emacs (no doom-font/doom-theme/
;; custom-set-faces!/doom-load-theme-hook here).
;;
;; Loaded from init.el via `(load (locate-user-emacs-file "theme") nil t)'.

;; ---------------------------------------------------------------------------
;; Font
;; ---------------------------------------------------------------------------
;; `default-frame-alist' covers frames created later (e.g. emacsclient);
;; `set-face-attribute' updates the already-open startup frame.
(add-to-list 'default-frame-alist '(font . "JetBrainsMono Nerd Font-15"))
(when (display-graphic-p)
  (set-face-attribute 'default nil :family "JetBrainsMono Nerd Font" :height 150))

;; ---------------------------------------------------------------------------
;; Doom theme
;; ---------------------------------------------------------------------------
;; Alternatives tried before: doom-one, doom-badger, doom-moonlight, doom-gruvbox.
(use-package doom-themes
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  (load-theme 'doom-homage-black t))

;; ---------------------------------------------------------------------------
;; TTY background hack
;; ---------------------------------------------------------------------------
;; In TTY frames, doom-homage-black (like most doom themes) leaves the
;; `default' background unspecified, so the terminal's own background shows
;; through. Paint it per-frame to match the theme's GUI bg.
;;
;; `#010101' instead of `#000000': exact black is treated as `unspecified-bg'
;; and falls through to the terminal; a non-pure-black hex forces Emacs to
;; actually paint it.
(defvar +my/tty-bg "#010101"
  "Near-black background painted on TTY frames (off #000000 on purpose).")

(defun +my/tty-apply-bg (&optional frame &rest _)
  "Paint FRAME's background with `+my/tty-bg'. No-op for GUI frames.
Accepts extra args so it can sit on `after-make-frame-functions',
`window-setup-hook', and `enable-theme-functions' alike."
  (let ((frame (if (framep frame) frame (selected-frame))))
    (unless (display-graphic-p frame)
      (dolist (face '(default fringe hl-line))
        (when (facep face)
          (set-face-background face +my/tty-bg frame))))))

(add-hook 'after-make-frame-functions #'+my/tty-apply-bg)
(add-hook 'window-setup-hook #'+my/tty-apply-bg)
(when (boundp 'enable-theme-functions)        ; Emacs 29+
  (add-hook 'enable-theme-functions #'+my/tty-apply-bg))
