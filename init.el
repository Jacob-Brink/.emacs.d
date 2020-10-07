(package-initialize)

(add-to-list 'default-frame-alist '(fullscreen . maximized))

(org-babel-load-file "~/.emacs.d/config.org")
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-export-with-toc 10)
 '(package-selected-packages
   (quote
    (rjsx-mode neotree use-package spacemacs-theme org-ref org-noter org-journal magit hackernews eyebrowse))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
