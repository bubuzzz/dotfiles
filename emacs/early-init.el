;;; early-init.el --- -*- lexical-binding: t -*-

(defvar my/gc-runtime-threshold (* 32 1024 1024))

(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold my/gc-runtime-threshold
                  gc-cons-percentage 0.1)))

(defvar my/cache-dir
  (expand-file-name "emacs/" (or (getenv "XDG_CACHE_HOME") "~/.cache/")))

(defvar my/startup-background "#181616")
(defvar my/startup-foreground "#c5c9c5")

(make-directory my/cache-dir t)

(setq package-user-dir (expand-file-name "elpa/" my/cache-dir))

(setq package-quickstart t
      package-quickstart-file (expand-file-name "package-quickstart.el" my/cache-dir))

(when (and (fboundp 'startup-redirect-eln-cache)
           (fboundp 'native-comp-available-p)
           (native-comp-available-p))
  (startup-redirect-eln-cache (expand-file-name "eln-cache/" my/cache-dir)))

(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)

(when initial-window-system
  (push `(background-color . ,my/startup-background) default-frame-alist)
  (push `(foreground-color . ,my/startup-foreground) default-frame-alist))
