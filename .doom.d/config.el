;;; .doom.d/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here
(add-hook 'python-mode-hook 'python-black-on-save-mode)
(setq gofmt-command "goimports")
(add-hook 'before-save-hook 'gofmt-before-save)
