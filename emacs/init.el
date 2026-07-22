;;; init.el --- -*- lexical-binding: t -*-

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(unless package-activated-list (package-initialize))

(defvar my/packages
  '(evil
    evil-collection
    general
    doom-themes
    kanagawa-themes
    org-superstar
    evil-org
    pyvenv
    jupyter
    xclip))

(dolist (pkg my/packages)
  (unless (package-installed-p pkg)
    (package-initialize)
    (unless package-archive-contents (package-refresh-contents))
    (package-install pkg)
    (package-quickstart-refresh)))

(add-to-list 'load-path (locate-user-emacs-file "lisp"))

(setq custom-file (locate-user-emacs-file "custom.el"))
(when (file-exists-p custom-file) (load custom-file nil t))

;;; ---------------------------------------------------
;;; ------------------ Configuration ------------------
;;; ---------------------------------------------------

(defvar my/cache-dir
  (expand-file-name "emacs/" (or (getenv "XDG_CACHE_HOME") "~/.cache/")))

(defvar my/font "JetBrainsMono Nerd Font-14")

(defvar my/leader "SPC")

(defvar my/shortcuts
  '("ee" dired-jump
    "ff" find-file
    "fs" save-buffer
    "bb" switch-to-buffer
    "bd" kill-current-buffer
    "va" pyvenv-activate
    "vd" pyvenv-deactivate
    "q"  save-buffers-kill-terminal))

(defvar my/mode-shortcuts
  '((org-mode-map
     "oj" my/org-insert-jupyter-python-block)))

(defvar my/themes '(kanagawa-dragon doom-homage-black))
(defvar my/theme-toggle-key "<f5>")

(defvar my/lsp-servers
  '(((python-mode python-ts-mode) . ("basedpyright-langserver" "--stdio"))))

(defvar my/lsp-keys
  '(("g d"   . xref-find-definitions)
    ("g r"   . xref-find-references)
    ("K"     . eldoc)
    ("C-c r" . eglot-rename)
    ("C-c a" . eglot-code-actions)))

(defvar my/org-headline-bullets '("◉" "○" "✸" "✿" "♦"))

(defvar my/org-item-bullets
  '((?+ . "•")
    (?- . "◦")
    (?* . "•")))

(defvar my/org-key-theme '(navigation insert textobjects additional calendar))

(defvar my/jupyter-header-args
  '((:session . "py")
    (:async . "yes")
    (:kernel . "python3")
    (:results . "raw drawer")
    (:pandoc . t)
    (:exports . "both")))

(defvar my/jupyter-resource-dir "./.ob-jupyter/")

;;; ---------------------------------------------------

(dolist (module '(config-backup
                  config-ui
                  config-evil
                  config-shortcut
                  config-theme
                  config-statusline
                  config-lsp
                  config-org
                  config-notebook))
  (require module))

(config-backup-set my/cache-dir)
(config-ui-set my/font)
(config-evil-set)
(config-shortcut-set my/leader my/shortcuts my/mode-shortcuts)
(config-theme-set my/themes my/theme-toggle-key)
(config-statusline-set)
(config-lsp-set my/lsp-servers my/lsp-keys)
(config-org-set my/org-headline-bullets my/org-item-bullets my/org-key-theme)
(config-notebook-set my/jupyter-header-args my/jupyter-resource-dir)
