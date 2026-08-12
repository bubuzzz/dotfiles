;;; config-dashboard.el --- -*- lexical-binding: t -*-

(defun config-dashboard-set (items widgets title-height)
  "Show the dashboard on startup with ITEMS and WIDGETS.
ITEMS is a `dashboard-items' alist like ((recents . 5) (projects . 5)).
WIDGETS is a `dashboard-startupify-list' of insert functions.
TITLE-HEIGHT scales the banner title against the frame font."
  (require 'dashboard)
  (setq dashboard-startupify-list  widgets
        dashboard-center-content   t
        dashboard-vertically-center-content t
        dashboard-items            items
        dashboard-projects-backend 'project-el
        dashboard-set-heading-icons nil
        dashboard-set-file-icons   nil
        initial-major-mode         'fundamental-mode
        initial-scratch-message    nil)

  ;; Themes give this face an absolute `:height'; a relative one scales with
  ;; the frame font instead.
  (face-spec-set 'dashboard-banner-logo-title
                 `((t (:height ,title-height :weight bold)))
                 'face-override-spec)

  (add-hook 'server-after-make-frame-hook #'dashboard-open)

  (dashboard-setup-startup-hook))

(provide 'config-dashboard)
