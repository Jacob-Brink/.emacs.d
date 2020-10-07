(require 'package) ; todo: don't know what this does

(setq package-archives  '(("elpa" . "http://tromey.com/elpa/")
                         ("gnu" . "http://elpa.gnu.org/packages/")
                         ("marmalade" . "http://marmalade-repo.org/packages/")
			 ("magit" . "")
			 ("MELPA" . "http://melpa.org/packages/")
			 )) ; todo: don't really know if this is necessary

; refresh packages
(unless package-archive-contents 
  (package-refresh-contents))

(package-refresh-contents)

(setq package-list '(org-journal eyebrowse org-ref pdf-tools org-noter magit htmlize use-package spacemacs-theme neotree))

(require 'use-package)

; ensure packages in package-list are always installed
(dolist (package package-list)
  (unless (package-installed-p package)
    (package-install package)))

(use-package pdf-tools   
:ensure t 
:config   (pdf-tools-install)   
(setq-default pdf-view-display-size 'fit-page))

(require 'popup)

(defun describe-thing-in-popup ()
  (interactive)
  (let* ((thing (symbol-at-point))
         (help-xref-following t)
         (description (save-window-excursion
                        (with-temp-buffer
                          (help-mode)
                          (help-xref-interned thing)
                          (buffer-string)))))
    (popup-tip description
               :point (point)
               :around t
               :height 20
               :scroll-bar t
               :margin t)))

(define-key global-map "\C-x9" 'describe-thing-in-popup)

; todo: cleanup
;(setq auto-save-file-name-transforms
;      `((".*" "~/.emacs-saves/\\2" t)))

(setq auto-save-file-name-transforms
      `((".*" "~/.emacs-saves/" t)))

(setq backup-directory-alist '(("." . "~/.emacs-backup")))

(define-minor-mode sensitive-mode
  "For sensitive files like password lists.
It disables backup creation and auto saving.

With no argument, this command toggles the mode.
Non-null prefix argument turns on the mode.
Null prefix argument turns off the mode."
  ;; The initial value.
  nil
  ;; The indicator for the mode line.
  " Sensitive"
  ;; The minor mode bindings.
  nil
  (if (symbol-value sensitive-mode)
      (progn
	;; disable backups
	(set (make-local-variable 'backup-inhibited) t)	
	;; disable auto-save
	(if auto-save-default
	    (auto-save-mode -1)))
					;resort to default value of backup-inhibited
    (kill-local-variable 'backup-inhibited)
					;resort to default auto save setting
    (if auto-save-default
      (auto-save-mode 1))))

(setq auto-mode-alist
      (append '(("\\.gpg$" . sensitive-mode))
	      auto-mode-alist))

(add-hook 'prog-mode-hook #'hs-minor-mode)
(global-set-key (kbd "C-c <right>") 'hs-show-block)
(global-set-key (kbd "C-c <left>") 'hs-hide-block)

(defun my_hideshow-ignore-setup-failure() (ignore-errors (hs-minor-mode)))

(define-globalized-minor-mode global-hs-minor-mode   hs-minor-mode my_hideshow-ignore-setup-failure)

(my_hideshow-ignore-setup-failure)

(when (string-equal system-type "windows-nt")
  (setq exec-path (split-string (getenv "PATH") path-separator))
)

; todo: is this necessary?
(add-hook 'org-mode-hook (lambda ()
                           (local-set-key (kbd "C-c s") 'org-show-subtree)))

(require 'org)
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(setq org-log-done t)

;(setq org-agenda-files (list "~/Dropbox/org-mode/tasks.org"
;                             "~/Dropbox/org-mode/school_tasks.org"))
(setq org-directory "~/Dropbox/org-mode")

(global-set-key (kbd "C-c l") 'org-store-link)
(global-set-key (kbd "C-c C-l") 'org-insert-link)

(global-set-key (kbd "C-c a") 'org-agenda)
(global-set-key (kbd "C-c c") 'org-capture)

(setq org-agenda-files '("~/Dropbox/org-mode/"))

(setq org-agenda-custom-commands '(
  ("1" "Events" agenda "display deadlines and exclude scheduled" (
    (org-agenda-span 'week)
    (org-agenda-time-grid nil)
    (org-agenda-show-all-dates nil)
    (org-agenda-entry-types '(:deadline)) ;; this entry excludes :scheduled
    (org-deadline-warning-days 1) ))
    ))

(defun template-factor (key description fileName header text)
  `(,key
    ,description
    entry
					; (file+headline ,(concat "~/org-mode/" fileName) ,header)
    (file+headline ,(concat org-directory "/" fileName) ,header)
    ,text
    :prepend t
    :empty-lines 1
    :created t)
  )

(setq org-capture-templates
      `(
	,(template-factor
	  "h"               ; key
	  "Miscellaneous Note With Link" ; description
	  "notes.org" ; file
	  "Notes" "***** %^{Project} %^{Description} \n:PROPERTIES:\n:Created: %U\nLink: %a\n:END:\n\n" ; text
	  )
	("s" "School Task Menu")
	,(template-factor
	  "sl"              
	  "School With Link"
	  "school_tasks.org"
	  "Tasks" "***** TODO %^{Todo} %? %^g%^g \n:PROPERTIES:\n:Created: %U\nLink: %a\n:END:\n\n"
	  )
	,(template-factor
	  "sk"
	  "School Without Link"
	  "school_tasks.org"
	  "Tasks"
	  "***** TODO %^{Todo} %? %^g%^g \n:PROPERTIES:\n:Created: %U\n:END:\n\n"
	  )
	,(template-factor
	 "s"
	 "School Tasks"
	 "school_tasks.org"
	 "TASKS"
	 "***** TODO %^{Todo} %? %^g \n:PROPERTIES:\n:Created: %U\n:END:\n\n"
	 )
	,
	(template-factor
	  "n"
	  "Generic Task"
	  "tasks.org"
	  "TASKS"
	  "***** TODO %^{Todo} %? %^g \n:PROPERTIES:\n:Created: %U\n:END:\n\n"
	  )
	,(template-factor
	  "z"
	  "Testing template-factorfff"
	  "template-factor.org"
	  "template-factorf"
	  "***** %^{template-factor-prompt}"
	  )
	("p" "Insert Useful Links")
	,(template-factor
	  "pe"
	  "Emacs Resources"
	  "resources.org"
	  "Emacs"
	  "***** %^{Description} \n:PROPERTIES:\n:Created: %U\n:ConfigLink: %a\n:WebLink: %^{Website URL} \n:END:\n\n"
	  )
	,(template-factor
	  "pm"
	  "Miscellaneous Resources"
	  "resources.org"
	  "Miscellaneous"
	  "***** %^{Description} \n:PROPERTIES:\n:Created: %U\n:WebLink: %^{Website URL} \n:END:\n\n"
	  )
	,(template-factor
	  "j"
	  "Journal Entry"
	  "journal.gpg"
	  "Journal"
	  "***** %U\n %^{Description}\n\n "
	  )
	,(template-factor
	  "f"
	  "Garbage Ideas"
	  "garbage.org"
	  "Stupid"
	  "***** %U\n %^{Description} \n:PROPERTIES:\n:Created: %U\n:END:\n\n "
	  )
	))

(if (string-equal system-type "windows-nt")
  (define-key global-map (kbd "C-c g") (lambda () (interactive) (message "magit is disabled on windows")))
  (define-key global-map (kbd "C-c g") 'magit-status)
)

(use-package eyebrowse
  :diminish eyebrowse-mode
  :config (progn
	    (define-key eyebrowse-mode-map (kbd "M-1") 'eyebrowse-switch-to-window-config-1)
	    (define-key eyebrowse-mode-map (kbd "M-2") 'eyebrowse-switch-to-window-config-2)
	    (define-key eyebrowse-mode-map (kbd "M-3") 'eyebrowse-switch-to-window-config-3)
	    (define-key eyebrowse-mode-map (kbd "M-4") 'eyebrowse-switch-to-window-config-4)
	    (eyebrowse-mode t)
	    (setq eyebrowse-new-workspace t)))

(defun open-terminal()
  (interactive)
  (start-process-shell-command (format "cmd(%s)" default-directory) nil "start cmd"))
(global-set-key (kbd "C-c e") 'open-terminal)

;; (require 'spacemacs-common)

;; (deftheme spacemacs-dark "Spacemacs theme, the dark version")

;; (create-spacemacs-theme 'dark 'spacemacs-dark)
(load-theme 'spacemacs-dark t)

(require 'neotree)
(global-set-key [f8] 'neotree-toggle)
(setq neo-theme 'ascii)
(setq-default neo-show-hidden-files t)
