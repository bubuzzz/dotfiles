;;; early-init.el -*- lexical-binding: t; -*-
;; Runs before the GUI frame and the package system are initialized.

;; Crank the GC ceiling sky-high during startup, then restore a sane value
;; once we're up. This avoids dozens of GC pauses while loading packages.
(setq gc-cons-threshold most-positive-fixnum)
(add-hook 'emacs-startup-hook
          (lambda () (setq gc-cons-threshold (* 16 1024 1024))))

;; Kill UI chrome here so it never flashes on screen during startup.
(menu-bar-mode -1)
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)

;; We call `package-initialize' ourselves in init.el, so skip the implicit one.
(setq package-enable-at-startup nil)

;; Native-compilation warnings from third-party packages (e.g. flymake-ruff
;; referencing a not-yet-loaded flymake function) are harmless. Keep them in
;; the log but don't pop up the *Warnings* buffer on every compile.
(setq native-comp-async-report-warnings-errors 'silent)

;; Don't let the default theme's background flash white before our theme loads.
(setq inhibit-startup-screen t)
