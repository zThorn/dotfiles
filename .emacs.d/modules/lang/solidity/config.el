;;; lang/solidity/config.el -*- lexical-binding: t; -*-

;;
;; Packages

;; `solidity-mode'
(setq solidity-comment-style 'slash)


(use-package! solidity-flycheck  ; included with solidity-mode
  :when (featurep! :tools flycheck)
  :after solidity-mode
  :config
  (setq flycheck-solidity-solc-addstd-contracts t)
  (when (funcall flycheck-executable-find solidity-solc-path)
    (add-to-list 'flycheck-checkers 'solidity-checker nil #'eq))
  (when (funcall flycheck-executable-find solidity-solium-path)
    (add-to-list 'flycheck-checkers 'solium-checker nil #'eq)))


(use-package! company-solidity
  :when (featurep! :completion company)
  :after solidity-mode
  :config
  (setq company-backends (delq 'company-solidity company-backends))
  (set-company-backend! 'solidity-mode 'company-solidity))
