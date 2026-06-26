;;; init.el -*- lexical-binding: t; -*-
;;
;; A barebones-but-comfortable GNU Emacs config from scratch:
;;   - package.el + built-in use-package
;;   - completion stack (vertico / orderless / marginalia / consult / corfu / cape)
;;   - QoL (which-key, helpful, magit, rainbow-delimiters, doom-themes)
;;   - evil + evil-collection with a Doom-like SPC leader (via general.el)
;;
;; Reload after edits with `M-x eval-buffer' or restart Emacs.
;; Debug startup errors with:  emacs --debug-init

;;; ----------------------------------------------------------------------------
;;; Package system + use-package
;;; ----------------------------------------------------------------------------
(require 'package)
(setq package-archives
      '(("gnu"    . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa"  . "https://melpa.org/packages/")))
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; use-package ships with Emacs 29+. `:ensure t' everywhere by default; set
;; `:ensure nil' for packages built into Emacs (savehist, recentf, which-key).
(require 'use-package)
(setq use-package-always-ensure t)

;;; ----------------------------------------------------------------------------
;;; Sane defaults / quality-of-life settings
;;; ----------------------------------------------------------------------------
(setq inhibit-startup-screen t
      initial-scratch-message nil
      make-backup-files nil
      auto-save-default nil
      create-lockfiles nil
      ring-bell-function 'ignore
      use-short-answers t            ; y/n instead of yes/no
      scroll-conservatively 101
      scroll-margin 3)

(setq-default indent-tabs-mode nil
              tab-width 4)

(column-number-mode 1)
(global-display-line-numbers-mode 1)
(setq display-line-numbers-type 'relative)   ; vim-style relative numbers
(electric-pair-mode 1)                        ; auto-close brackets/quotes
(global-auto-revert-mode 1)                   ; reload files changed on disk
(add-to-list 'initial-frame-alist '(fullscreen . maximized))
(add-to-list 'default-frame-alist  '(fullscreen . maximized))

;; Built-in niceties (no download needed → :ensure nil)
(use-package savehist :ensure nil :init (savehist-mode 1))
(use-package recentf  :ensure nil :init (recentf-mode 1))

;;; ----------------------------------------------------------------------------
;;; Theme
;;; ----------------------------------------------------------------------------
;; Font, doom theme, and the TTY background hack live in theme.el.
(load (locate-user-emacs-file "theme") nil t)

;;; ----------------------------------------------------------------------------
;;; Completion stack
;;; ----------------------------------------------------------------------------
;; Minibuffer UI
(use-package vertico
  :init (vertico-mode 1))

;; Path-aware editing in the find-file minibuffer (bundled with vertico):
;;   RET on a dir descends into it, DEL deletes the whole directory component
;;   (i.e. navigates to the parent) — the Doom `SPC .' feel.
(use-package vertico-directory
  :ensure nil
  :after vertico
  :bind (:map vertico-map
         ("RET"   . vertico-directory-enter)
         ("DEL"   . vertico-directory-delete-char)
         ("M-DEL" . vertico-directory-delete-word))
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))

;; Fuzzy / out-of-order matching
(use-package orderless
  :init
  (setq completion-styles '(orderless basic)
        completion-category-overrides '((file (styles partial-completion)))))

;; Rich annotations in the minibuffer (file sizes, docstrings, ...)
(use-package marginalia
  :init (marginalia-mode 1))

;; Practical search/navigation commands
(use-package consult
  :bind (("C-s"   . consult-line)
         ("C-x b" . consult-buffer)
         ("M-y"   . consult-yank-pop)))

;; In-buffer completion popup (code completion UI)
(use-package corfu
  :init (global-corfu-mode 1)
  :custom
  (corfu-auto t)               ; popup as you type
  (corfu-auto-prefix 2)
  (corfu-cycle t))

;; Extra completion-at-point sources for corfu (file paths, dabbrev words)
(use-package cape
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file))

;;; ----------------------------------------------------------------------------
;;; QoL packages
;;; ----------------------------------------------------------------------------
;; which-key is built into Emacs 30+
(use-package which-key
  :ensure nil
  :init (which-key-mode 1)
  :config (setq which-key-idle-delay 0.4))

(use-package helpful
  :bind (([remap describe-function] . helpful-callable)
         ([remap describe-variable] . helpful-variable)
         ([remap describe-key]      . helpful-key)
         ([remap describe-command]  . helpful-command)))

(use-package magit
  :commands (magit-status magit-dispatch))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package projectile
  :init (projectile-mode 1)
  :config
  ;; Use the minibuffer completion stack (vertico) for project prompts.
  (setq projectile-completion-system 'default)
  ;; Directories to scan for projects with `projectile-discover-projects-in-search-path'.
  ;; (setq projectile-project-search-path '("~/Projects/"))
  :bind-keymap ("C-c p" . projectile-command-map))

;;; ----------------------------------------------------------------------------
;;; Evil (Vim keybindings)
;;; ----------------------------------------------------------------------------
(use-package evil
  :init
  (setq evil-want-integration t
        evil-want-keybinding nil        ; required by evil-collection
        evil-want-C-u-scroll t
        evil-undo-system 'undo-redo)
  :config
  (evil-mode 1))

;; Sensible evil bindings across Emacs' built-in modes (dired, magit, ...)
(use-package evil-collection
  :after evil
  :config (evil-collection-init))

;;; ----------------------------------------------------------------------------
;;; SPC leader keys (Doom-like) via general.el
;;; ----------------------------------------------------------------------------
(use-package general
  :config
  (general-create-definer my/leader
    :states '(normal visual motion)
    :keymaps 'override
    :prefix "SPC")
  ;; Major-mode-local leader (Doom's `SPC m'); bound per-mode via :keymaps.
  (general-create-definer my/localleader
    :states '(normal visual motion)
    :prefix "SPC m")
  (my/leader
    "SPC" '(execute-extended-command :which-key "M-x")
    "/"   '(consult-line             :which-key "search buffer")
    "."   '(find-file                :which-key "find file")

    "f"  '(:ignore t :which-key "file")
    "ff" #'find-file
    "fr" #'consult-recent-file
    "fs" #'save-buffer

    "b"  '(:ignore t :which-key "buffer")
    "bb" #'consult-buffer
    "bk" #'kill-current-buffer
    "bn" #'next-buffer
    "bp" #'previous-buffer

    "w"  '(evil-window-map :which-key "window")

    "p"  '(projectile-command-map :which-key "project")

    "c"  '(:ignore t :which-key "code")
    "ca" #'eglot-code-actions
    "cr" #'eglot-rename
    "cf" #'eglot-format-buffer
    "cd" #'xref-find-definitions
    "cR" #'xref-find-references

    "g"  '(:ignore t :which-key "git")
    "gg" #'magit-status

    "h"  '(help-command :which-key "help")

    "q"  '(:ignore t :which-key "quit")
    "qq" #'save-buffers-kill-terminal))

;;; ----------------------------------------------------------------------------
;;; Python IDE: eglot + pyright, ruff (format + lint)
;;; ----------------------------------------------------------------------------
(load (locate-user-emacs-file "python") nil t)

;;; ----------------------------------------------------------------------------
;;; Org + Jupyter inline notebook (pyvenv-auto, emacs-jupyter, org-babel)
;;; ----------------------------------------------------------------------------
(load (locate-user-emacs-file "notebook") nil t)

;;; ----------------------------------------------------------------------------
;;; Editor extensions (dired unified create, ...)
;;; ----------------------------------------------------------------------------
(load (locate-user-emacs-file "extension") nil t)

;;; ----------------------------------------------------------------------------
;;; Startup splash: centered cowsay (installs cowsay automatically)
;;; ----------------------------------------------------------------------------
(load (locate-user-emacs-file "cowsay") nil t)

;;; ----------------------------------------------------------------------------
;;; Keep `customize' out of init.el (writes to its own file)
;;; ----------------------------------------------------------------------------
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

;;; init.el ends here
