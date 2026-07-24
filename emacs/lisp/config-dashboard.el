;;; config-dashboard.el --- -*- lexical-binding: t -*-

(defun config-dashboard-set (items widgets)
  "Show the dashboard on startup with ITEMS and WIDGETS.
ITEMS is a `dashboard-items' alist like ((recents . 5) (projects . 5)).
WIDGETS is a `dashboard-startupify-list' of insert functions."
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

  (add-hook 'server-after-make-frame-hook #'dashboard-open)

  (dashboard-setup-startup-hook))

(provide 'config-dashboard)
