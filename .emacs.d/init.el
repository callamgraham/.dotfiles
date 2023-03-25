;;; package -- Summary
;; Commentary:
; Emacs configuration for cig

;; setup proxy information for windows
(when (eq system-type 'windows-nt)
  (setq proxy-file "~/.emacs.d/proxy.el")
  (load proxy-file))

;;; Code:
; Disable the startup message and screen ie.  Emacs welcome
(setq inhibit-startup-message t)
(setq inhibit-startup-screen t)
;; UI settings --------------------------------------------------------
; Disable visible scrollbar ie. scroll bar on the right
(scroll-bar-mode -1)

;; Disable the top of screen stuff
;; (tool-bar-mode -1) ; ie. the icons at the top
;; (tooltip-mode -1)  ; Disable tooltips
;; (menu-bar-mode -1) ; Disable the menu bar
;; (set-fringe-mode 10) ; Give some breathing room
(setq warning-minimum-level :error) ; only show warning buffer on errors
(set-default-coding-systems 'utf-8)

(setq visible-bell t); Set up the visible bell

; Line number settings
(column-number-mode) ; turn on line number mode
(global-display-line-numbers-mode t) ; display line numbers everywhere
(setq display-line-numbers-type 'relative) ; use relative line numbers
(define-key key-translation-map (kbd "ESC") (kbd "C-g")) ; use escape to quit stuff

; other general stuff
; use text-based prompts rather than using GUI windows
(setq use-dialog-box nil)

; turn off the ringing bell feature
(setq ring-bell-function 'ignore)

; window focusing - windows must be manually clicked to focus
(setq mouse-autoselect-window nil
      focus-follows-mouse nil)

; send deleted files to trash
(setq delete-by-moving-to-trash t
      create-lockfiles nil)

; recenter cursor on scroll
(setq scroll-preserve-screen-position t)

; windows settings ---------------------------------------------------
; enable CUA mode so hotkeys act like windows
(cua-mode t)

; use line for the cursor
(setq-default cursor-type 'bar)

; some other general keybindings
(global-set-key (kbd "<f4>")  'execute-extended-command)
(global-set-key (kbd "C-s")   'save-buffer)
(global-set-key (kbd "<f5>")  'delete-other-windows)
(global-set-key (kbd "<f6>")  'magit-status)
(global-set-key (kbd "<f8>")  'kill-buffer)
(global-set-key (kbd "C-M-d") 'dired)
(global-set-key (kbd "<f7>")  'eshell)
;(global-set-key (kbd "C-<tab>")  'indent-according-to-mode)
(global-set-key (kbd "C-M-b")  'comment-line)

; arrow keys --------------------------------------------------------
(defun move-right ()
  (interactive)
  (if mark-active
	(deactivate-mark))
  (forward-char)
  )
(global-set-key (kbd "<right>") 'move-right)

(defun move-left()
  (interactive)
  (if mark-active
      (deactivate-mark))
    (backward-char)
  )
(global-set-key (kbd "<left>") 'move-left)

; arrow and shift keys -----------------
(defun move-shift-right ()
  (interactive)
  (if (not mark-active)
      (set-mark-command nil))
  (forward-char)
  )
(global-set-key (kbd "S-<right>") 'move-shift-right)

(defun move-shift-left()
  (interactive)
  (if (not mark-active)
      (set-mark-command nil))
    (backward-char)
  )
(global-set-key (kbd "S-<left>") 'move-shift-left)

; arrow and control -------------------
(defun jump-right ()
  "Move forward one word and one space."
  (interactive)
  (if mark-active
	(deactivate-mark))
  (forward-word 1)
  (forward-char 1))
(global-set-key (kbd "C-<right>") 'jump-right)

(defun jump-left()
  "Move backward one word and one space."
  (interactive)
  (if mark-active
	(deactivate-mark))
  (backward-word 1)
  (backward-char 1))
(global-set-key (kbd "C-<left>") 'jump-left)

; arrow and control -------------------
(defun jump-shift-right ()
  "Move forward one word and one space while holding shift."
  (interactive)
  (forward-word 1)
  (forward-char 1)
  (if (not mark-active)
      (set-mark-command nil))
  (backward-word 1))
(global-set-key (kbd "C-S-<right>") 'jump-shift-right)

(defun jump-shift-left ()
  "Move backward one word and one space while holding shift."
  (interactive)
  (backward-word 1)
  (backward-char 1)
  (if (not mark-active)
      (set-mark-command nil))
  (forward-word 1))
(global-set-key (kbd "C-S-<left>") 'jump-shift-left)

;; Font Setup --------------------------------------------------------
; Linux font
(when (eq system-type 'gnu/linux)
  (set-face-attribute 'default nil
                    :family "Source Code Pro"
                    :height '140
                    :weight 'normal
                    :width 'normal))
; Windows font
(when (eq system-type 'windows-nt)
  (set-face-attribute 'default nil
                    :family "Consolas"
                    :height '120
                    :weight 'normal
                    :width 'normal))

; global prefix key:
(define-prefix-command 'my-prefix-map)
(global-set-key (kbd "C-M-c") 'my-prefix-map)

;; ------------------------------------------------------------------------------------
;; PACKAGES
;; ------------------------------------------------------------------------------------

; Make sure we have the "Package" package
(require 'package)

; Set up package repos
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

; initialize the package system
(package-initialize)

;; I'll be using "use-package" for package management
;; make sure the use-package package is installed
(setq use-package-always-ensure t)
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; a couple other settings for use-package to help with memory and start time
(eval-when-compile (require 'use-package))
(setq use-package-verbose t
      comp-async-report-warnings-errors nil
      comp-deferred-compilation t)

;;;; Packages -----------------------------------------------------------------------------

;; ASYNC
;; helps improve performance
(use-package async
  :defer t ; defer loading until needed, not sure if this line is necessary given use-package settings above
  :init
  (dired-async-mode 1) ; allow dired to load stuff asynchroniosly, which should help on windows
  (async-bytecomp-package-mode 1) ; allows emacs lisp code to be compiled asynchroniosly
  :custom (async-bytecomp-allowed-packages '(all))) ; all packages are allowed to use async

;;; COMPLETION ---------------------------------------------------
;; vertico provides the minibuffer completion framework
;; orderless, consult, and marginalia all make use of vertico and are
;; loaded along with it
(use-package vertico
  :init
  ; orderless allows for fuzzy completions
  (use-package orderless
    :commands (orderless)
    :custom (completion-styles '(orderless flex)))

  ;; Consult provides extra completion functions, such as buffer switching,
  ;; line searching, and general fuzzy finding
  (use-package consult
    :bind (("C-M-c C-M-c" . consult-buffer)           ;; buffer switchign
           ("C-M-m"       . consult-kmacro)           ;; run macro from the macro-rink
           ("M-y"         . consult-yank-pop)         ;; pull up the yank-pop list (ie. kill-ring)
           ("C-M-f"       . consult-flymake)          ;; TODO: change to flycheck?
           ("M-g i"       . consult-imenu)            ;; looks like object search? should look into this..
           ("C-f"         . consult-line)             ;; line searching
           ("M-s L"       . consult-line-multi)       ;; apparently allows selection of multiple lines?
           ("M-s u"       . consult-focus-lines)      ;; hides all lines except lines that fit a search
           ;; ("M-s M-g"     . consult-ripgrep)       ;; ripgrep - will need windows alternative
           ("C-x C-SPC"   . consult-global-mark)      ;; shows the global-mark-ring, will need to figure out
           ("C-x M-:"     . consult-complex-command)  ;; consult's version of C-x?
           ("C-c n"       . consult-org-agenda)       ;; consult's org agenda view
           :map dired-mode-map
           ("O" . consult-file-externally)
           :map help-map
           ("a" . consult-apropos)          ;; adds consult apropos to the help-map (C-h)
           :map minibuffer-local-map
           ("M-r" . consult-history))
    :custom
    (completion-in-region-function #'consult-completion-in-region)
    :config
    (add-hook 'completion-setup-hook #'hl-line-mode)
    (recentf-mode t))

  (use-package marginalia ; marginalia adds additional information to completions
    :custom
    (marginalia-annotators
     '(marginalia-annotators-heavy marginalia-annotators-light nil))
    :init
    (marginalia-mode))

;; Enable vertico using the vertico-flat-mode
  (require 'vertico-directory)
  (add-hook 'rfn-eshadow-update-overlay-hook #'vertico-directory-tidy)
  (vertico-mode t)
  :config
  ;; Used for the vertico-directory extension
  (add-hook 'rfn-eshadow-update-overlay-hook #'vertico-directory-tidy)
  ;; Do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)
  ;; Enable recursive minibuffers
  (setq enable-recursive-minibuffers t))

;;;; Code Completion
(use-package corfu
  ;; Optional customizations
  :custom
  (corfu-cycle t)                 ; Allows cycling through candidates
  (corfu-auto t)                  ; Enable auto completion
  (corfu-auto-prefix 2)           ; enable completion after 2 characters have been typed
  (corfu-auto-delay 0.0)          ; set the suggestion delay to 0
  (corfu-echo-documentation 0.25) ; Enable documentation for completions
  (corfu-preview-current 'insert) ; Do not preview current candidate
  (corfu-preselect-first nil)
  (corfu-on-exact-match nil)      ; Don't auto expand tempel snippets

  ;; Optionally use TAB for cycling, default is `corfu-complete'.
  :bind (:map corfu-map
              ("M-SPC" . corfu-insert-separator)
              ("TAB"     . corfu-next)
              ([tab]     . corfu-next)
              ("S-TAB"   . corfu-previous)
              ([backtab] . corfu-previous)
              ("S-<return>" . corfu-insert)
              ("RET"     . nil) ;; leave my enter alone!
              )

  :init
  (global-corfu-mode)
  (corfu-history-mode)
  :config
  (setq tab-always-indent 'complete)
  (add-hook 'eshell-mode-hook
            (lambda () (setq-local corfu-quit-at-boundary t ; Quits completion if the cursor is at the beginning or end of a word.
				   corfu-quit-no-match t ; Quits completion if no matches are found.
                              corfu-auto nil) ; Disables auto completion.
              (corfu-mode)))) ; enables corfu mode in eshell
; Add extensions
(use-package cape
  :defer 10
  :bind ("C-c f" . cape-file)
  :init
  ;; Add `completion-at-point-functions', used by `completion-at-point'.
  (defalias 'dabbrev-after-2 (cape-capf-prefix-length #'cape-dabbrev 2))
  (add-to-list 'completion-at-point-functions 'dabbrev-after-2 t)
  (cl-pushnew #'cape-file completion-at-point-functions)
  :config
  ;; Silence then pcomplete capf, no errors or messages!
  (advice-add 'pcomplete-completions-at-point :around #'cape-wrap-silent)

  ;; Ensure that pcomplete does not write to the buffer
  ;; and behaves as a pure `completion-at-point-function'.
  (advice-add 'pcomplete-completions-at-point :around #'cape-wrap-purify))

;; Templates takes advantage of emacs's tempo
(use-package tempel
  :ensure t
  :defer 10
  :hook ((prog-mode text-mode) . tempel-setup-capf)
  :bind (("M-+" . tempel-insert) ;; Alternative tempel-expand
         :map tempel-map
         ([remap keyboard-escape-quit] . tempel-done)
         ("TAB" . tempel-next)
         ("<backtab>" . tempel-previous)
         :map corfu-map
         ("C-M-i" . tempel-expand))
  :init


  ;; Setup completion at point
  (defun tempel-setup-capf ()
    (setq-local completion-at-point-functions
                (cons #'tempel-complete
                      completion-at-point-functions)))
  (add-hook 'prog-mode-hook 'tempel-setup-capf)
  (add-hook 'text-mode-hook 'tempel-setup-capf)
  (add-hook 'lsp-mode-hook 'tempel-setup-capf)
  (add-hook 'sly-mode-hook 'tempel-setup-capf)
  :config
  (defun tempel-include (elt)
    (when (eq (car-safe elt) 'i)
      (if-let (template (alist-get (cadr elt) (tempel--templates)))
          (cons 'l template)
        (message "Template %s not found" (cadr elt))
        nil)))
  (add-to-list 'tempel-user-elements #'tempel-include))

;; projectile helps navigate around "Projects" using some built-in heuristics
(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap
  ("C-M-c C-v" . projectile-command-map)
  :init
  ;; NOTE: Set this to the folder where you keep your Git repos!
(when (eq system-type 'gnu/linux)
  (when (file-directory-p "~/Projects")
    (setq projectile-project-search-path '("~/Projects/")))
  (setq projectile-switch-project-action #'projectile-dired))

(when (eq system-type 'windows-nt)
  (when (file-directory-p "~/Projects")
    (setq projectile-project-search-path '("~/Projects/")))
  (setq projectile-switch-project-action #'projectile-dired)))

; expand region - for selecting "inside stuff"
(use-package expand-region
  :bind ("C-M-n" . er/expand-region))

;; Theme stuff ------------------------------------------------------------------------------------

(use-package doom-themes
  :ensure t
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-gruvbox t)

  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Enable custom neotree theme (all-the-icons must be installed!)
  (doom-themes-neotree-config)
  ;; or for treemacs users
  (setq doom-themes-treemacs-theme "doom-atom") ; use "doom-colors" for less minimal icon theme
  (doom-themes-treemacs-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

;; also use the Doom mode line to make it a bit more pretty
(use-package doom-modeline
  :init (doom-modeline-mode 1) ; 1 is the default mode line - set to "t" for the alternative
  :custom ((doom-modeline-height 20)))

;; which key - shows key commands
(use-package which-key
  :defer 0
  :diminish which-key-mode
  :config
  (which-key-mode)
  (setq which-key-idle-delay 0.3))

;;
;; ;; hydra -- used to create quick functions assigned to keybindings this may be worth further exploration?
;; (use-package hydra)

;; ;; here's an example of a hydra that zooms in and out. ie. scales text
;; (defhydra hydra-text-scale (:timeout 4) ; this is the function with a timeout of 4 seconds (which is optional)
;;   "scale text"
;;   ("j" text-scale-increase "in")
;;   ("k" text-scale-decrease "out")
;;   ("f" nil "finished" :exit t))
;; ;; it is now bound to the leader key plus "ts" for text scale
;; (cig/leader-keys
;;   "ts" '(hydra-text-scale/body :which-key "scale text"))

;;Beacon - light up the cursor line on switches
(use-package beacon
  :config (beacon-mode 1))

;; magit for git
(use-package magit
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; Languages ------------------------------------------------------------------------------------

;; Tree Sitter for highlighting and navigation
(when (eq system-type 'gnu/linux)
(use-package tree-sitter-langs)
(use-package tree-sitter
  :config
  (require 'tree-sitter-langs)
  (global-tree-sitter-mode)
  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode)))

;; flycheck for checking errors
(use-package flycheck
  :ensure t
  :init (global-flycheck-mode))

(use-package eglot
  :config
  (add-to-list 'eglot-server-programs '(python-mode . ("pylsp")))
  :hook
  (python-mode . eglot-ensure)
  :bind ("C-M-c C-u" . xref-find-definitions)           ;; go to def
  )

;; Rust - only for linux
(when (eq system-type 'gnu/linux)
  (use-package rustic
    :ensure t))

;; Eshell ------------------------------------------------------------------------------------
(defun efs/configure-eshell ()
  ;; Save command history when commands are entered
  (add-hook 'eshell-pre-command-hook 'eshell-save-some-history)

  ;; Truncate buffer for performance
  (add-to-list 'eshell-output-filter-functions 'eshell-truncate-buffer)

  (setq eshell-history-size         10000
        eshell-buffer-maximum-lines 10000
        eshell-hist-ignoredups t
        eshell-scroll-to-bottom-on-input t))

(use-package eshell-git-prompt
  :after eshell)

(use-package eshell
  :hook (eshell-first-time-mode . efs/configure-eshell)
  :bind ("<f7>" . eshell)
  :config

  (with-eval-after-load 'esh-opt
    (setq eshell-destroy-buffer-when-process-dies t)
    (setq eshell-visual-commands '("htop" "zsh" "vim"))) ; these commands get run in an external terminal

  (eshell-git-prompt-use-theme 'powerline))

;; Dired Options ------------------------------------------------------------------------------------
(use-package dired
  :ensure nil
  :commands (dired dired-jump)
  :custom ((dired-listing-switches "-agho --group-directories-first")))

(use-package dired-single
  :commands (dired dired-jump))

(use-package all-the-icons-dired
  :hook (dired-mode . all-the-icons-dired-mode))

(use-package dired-open
  :commands (dired dired-jump)
  :config
  ;; Doesn't work as expected!
  ;;(add-to-list 'dired-open-functions #'dired-open-xdg t)
  (setq dired-open-extensions '(("png" . "feh")
                                ("mkv" . "mpv"))))

(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)
