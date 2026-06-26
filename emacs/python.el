;;; python.el -*- lexical-binding: t; -*-
;;
;; Python IDE setup:
;;   - eglot + pyright   : completion, navigation, hover, type diagnostics
;;   - ruff (apheleia)   : async format-on-save (format + import sorting)
;;   - ruff (flymake)    : lint diagnostics, alongside pyright's
;;
;; Project .venv auto-activation lives in notebook.el (`pyvenv-auto'); it runs
;; before eglot (hook depth below) so pyright inherits the venv.
;;
;; Loaded from init.el via `(load (locate-user-emacs-file "python") nil t)'.

;; ---------------------------------------------------------------------------
;; eglot + pyright (both built-in / already installed)
;; ---------------------------------------------------------------------------
(use-package eglot
  :ensure nil                          ; built into Emacs 29+
  :init
  ;; Start eglot at hook DEPTH 10 so it runs *after* `pyvenv-auto-run'
  ;; (notebook.el, default depth) has activated the project's .venv — pyright
  ;; then inherits VIRTUAL_ENV and resolves the project's packages.
  (dolist (h '(python-mode-hook python-ts-mode-hook))
    (add-hook h #'eglot-ensure 10))
  :config
  ;; Use pyright's language server for Python (prepended so it wins over
  ;; eglot's defaults).
  (add-to-list 'eglot-server-programs
               '((python-mode python-ts-mode)
                 . ("pyright-langserver" "--stdio")))
  ;; pyright analysis settings, mirroring the old Doom config.
  (setq-default eglot-workspace-configuration
                '(:python
                  (:analysis (:typeCheckingMode "basic"
                              :autoImportCompletions t
                              :useLibraryCodeForTypes t
                              :diagnosticMode "workspace"))))
  (setq eglot-autoshutdown t           ; stop server when last buffer closes
        eglot-sync-connect nil))       ; connect asynchronously

;; ---------------------------------------------------------------------------
;; ruff: formatting via apheleia (async, on save)
;; ---------------------------------------------------------------------------
(use-package apheleia
  :config
  ;; Sort imports, then format — both with ruff. (Uses ruff from the active
  ;; venv if present, else the system ruff.)
  (setf (alist-get 'python-mode apheleia-mode-alist)    '(ruff-isort ruff)
        (alist-get 'python-ts-mode apheleia-mode-alist) '(ruff-isort ruff))
  (apheleia-global-mode 1))

;; ---------------------------------------------------------------------------
;; ruff: linting via flymake, layered on top of eglot's diagnostics
;; ---------------------------------------------------------------------------
;; eglot resets the flymake backends when it takes over a buffer, so add the
;; ruff backend from `eglot-managed-mode-hook' (runs after eglot sets up).
(use-package flymake-ruff
  :hook (eglot-managed-mode . flymake-ruff-load))
