;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Fonts, theme, treemacs icon variant, nerd-icons colors, and the TTY
;; background hack all live in theme.el — pulled out to keep this file focused
;; on behavior rather than appearance.
(load! "theme")
(load! "notebook")
(load! "extension")

;; GUI Emacs.app on macOS launches without the shell's PATH, so binaries from
;; homebrew, uv-managed venvs, and ~/.local/bin aren't visible. Pull PATH from
;; an interactive shell once at startup so `jupyter', `uv', `ipython', lsp
;; servers, etc. are discoverable. Skip in TTY (we already have shell env).
(use-package! exec-path-from-shell
  :when (memq window-system '(mac ns x))
  :config
  (setq exec-path-from-shell-variables '("PATH" "MANPATH" "VIRTUAL_ENV"))
  (exec-path-from-shell-initialize))

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; Soft-wrap long lines at word boundaries in every buffer. File contents are
;; unchanged — just visual. Toggle per-buffer with `SPC t w'.
(+global-word-wrap-mode +1)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/Projects/org-notes/")

;; Central task scratchpad. `SPC X' (capture) drops a quick TODO under
;; * Inbox; `SPC n t' jumps straight to the file for longer notes that
;; include src blocks. Both flows file into the same place so nothing
;; gets stranded in a project-local notes file.
(setq +tasks-file (expand-file-name "tasks.org" org-directory))

(after! org
  (setq org-capture-templates
        (append
         (or (bound-and-true-p org-capture-templates) '())
         `(("t" "Task note (Inbox)" entry
            (file+headline ,+tasks-file "Inbox")
            "* TODO %?\n  :PROPERTIES:\n  :CAPTURED: %U\n  :FROM:     %a\n  :END:\n"
            :empty-lines 1)))))

(defun +tasks/visit ()
  "Open the central tasks.org for longer notes / src blocks."
  (interactive)
  (find-file +tasks-file))

(map! :leader
      :desc "Jump to tasks.org" "n t" #'+tasks/visit)

(use-package! xclip
  :unless (display-graphic-p)
  :config (xclip-mode +1))

(after! vterm
  (set-popup-rule! "*doom:vterm-popup:main" :size 0.4 :vslot -4 :select t :quit nil :ttl 0 :side 'right))

;; Org-capture on the RIGHT instead of the bottom. Doom's default rule
;; (lang/org/config.el) gives the capture buffer no `:side', so it opens
;; along the bottom and takes 42% of the frame *height* — which shrinks a
;; PDF/book buffer you're reading from. Re-pointing it to the right side
;; makes `:size' a *width* fraction, so the note sits beside the PDF.
;; The `*Org Select*' template-chooser menu is moved too, so the whole
;; flow stays on the right. Our config loads after Doom's, so these
;; overrides win.
(after! org
  (set-popup-rule! "^\\*Capture\\*$\\|^CAPTURE-.*$"
    :side 'right :size 0.4 :select t :quit nil :ttl 0 :autosave 'ignore)
  (set-popup-rule! "^\\*Org Select"
    :side 'right :size 0.4 :select t :ttl 0))

(add-to-list 'initial-frame-alist '(fullscreen . maximized))

;; LSP: keep each language server scoped to a single project.
;; By default lsp-mode persists every project root you've ever visited in
;; `lsp-session' and re-attaches them all as additional workspace folders
;; on every new server start — so opening one .py file boots ruff against
;; 10 unrelated repos at once. These settings disable that:
;;   - `lsp-auto-guess-root nil' makes lsp ask once per project and not
;;     silently merge sibling roots into the same server.
;;   - `lsp-keep-workspace-alive nil' shuts a server down when its last
;;     buffer closes, so stale roots don't accumulate across the session.
;;   - `lsp-restart 'auto-restart' avoids prompting when a server dies.
;; If lsp-session still has stale roots, delete it once:
;;   rm ~/.config/emacs/.local/cache/lsp-session
(after! lsp-mode
  (setq lsp-auto-guess-root nil
        lsp-keep-workspace-alive nil
        lsp-restart 'auto-restart))

;; Ruff's lsp-mode client registers as multi-root by default, which means a
;; single ruff process is reused across every project root you visit — open
;; assistant after algo and the minibuffer reports `Connected to [ruff:NNNN
;; .../algo]' for the assistant buffer. Flip it to single-root so each
;; project spawns its own ruff scoped to that root.
;;
;; Note: we use `eval' + a quoted `setf' form so the macro expansion happens
;; at call time, after `lsp-mode' has loaded the `cl-defstruct' that defines
;; the `lsp--client-multi-root' setter. Doing `(setf ...)' at the top level
;; of an `after!' block expands too early in some load orders and errors
;; with `(void-function \(setf\ lsp--client-multi-root\))'.
(after! lsp-ruff
  (require 'lsp-mode)
  (when-let ((client (gethash 'ruff lsp-clients)))
    (eval `(setf (lsp--client-multi-root ,client) nil) t)))

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `with-eval-after-load' block, otherwise Doom's defaults may override your
;; settings. E.g.
;;
;;   (with-eval-after-load 'PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look them up).
;;   - Setting doom variables (which start with 'doom-' or '+').
