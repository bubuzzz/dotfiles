;;; theme.el -*- lexical-binding: t; -*-
;;
;; All theme/appearance config: fonts, doom theme, treemacs icon variant,
;; nerd-icons color overrides, and the TTY background hack.
;;
;; Loaded from config.el via `(load! "theme")'.

;; ---------------------------------------------------------------------------
;; Fonts
;; ---------------------------------------------------------------------------
;; `doom-font' is the primary monospace face; `doom-big-font' is used by
;; `doom-big-font-mode' for presentations / screen sharing.
(setq doom-font (font-spec :family "JetBrainsMono Nerd Font" :size 15)
      doom-big-font (font-spec :family "JetBrainsMono Nerd Font" :size 20))

;; ---------------------------------------------------------------------------
;; Doom theme
;; ---------------------------------------------------------------------------
;; Alternatives tried before: doom-one, doom-badger, doom-moonlight, doom-gruvbox.
(setq doom-theme 'doom-homage-black)

;; ---------------------------------------------------------------------------
;; Treemacs appearance
;; ---------------------------------------------------------------------------
;; (setq treemacs-position 'right)
;; (setq doom-themes-treemacs-theme "doom-colors")

;; ---------------------------------------------------------------------------
;; Nerd-icons color overrides
;; ---------------------------------------------------------------------------
;; Python logo blue/yellow — applied to .py file icons in dired/treemacs/dashboard.
(custom-set-faces!
  '(nerd-icons-dblue :foreground "#4B8BBE")
  '(nerd-icons-dyellow :foreground "#FFD43B"))

;; ---------------------------------------------------------------------------
;; TTY background hack
;; ---------------------------------------------------------------------------
;; In TTY frames, doom-homage-black (and most doom themes) deliberately leave
;; the `default' background unspecified — the palette's TTY slot is nil — so
;; the terminal's own background (gruvbox here) shows through. Override it
;; per-frame to match the theme's GUI bg. Hook on frame creation + theme load
;; so it survives new `emacsclient -t' frames and theme switches.
;;
;; Note: `#010101' instead of `#000000' — exact black is treated as
;; `unspecified-bg' and falls through to the terminal's color; any non-pure-
;; black hex forces Emacs to actually paint it.
(defvar +my/tty-bg "#010101"
  "Background to paint on TTY frames. Near-black, deliberately off #000000:
exact #000000 gets treated as `unspecified-bg' and falls through to the
terminal's own background; a non-pure-black hex forces Emacs to actually
paint it.")

(defun +my/tty-apply-bg (&optional frame)
  "Paint FRAME's background with `+my/tty-bg'. No-op for GUI frames.
Treemacs sets its own face background (a dark slate) that ignores
`default', so we override that too — along with a few other sidebar/
hl-line faces that visibly diverge in TTY."
  (let ((frame (or frame (selected-frame))))
    (unless (display-graphic-p frame)
      (dolist (face '(default
                      fringe
                      ;; treemacs-window-background-face
                      ;; treemacs-hl-line-face
                      hl-line
                      solaire-default-face
                      solaire-hl-line-face
                      solaire-fringe-face))
        (when (facep face)
          (set-face-background face +my/tty-bg frame))))))

(add-hook 'after-make-frame-functions #'+my/tty-apply-bg)
(add-hook 'doom-load-theme-hook #'+my/tty-apply-bg)
(add-hook 'window-setup-hook #'+my/tty-apply-bg)
