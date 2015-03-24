;;; #path系
;; elispロードパスの設定
(defun flat-list (obj &rest rest)
  (cond (rest (append (flat-list obj) (flat-list rest)))
        ((null obj) nil)
        ((listp obj) (append (flat-list (car obj)) (flat-list (cdr obj))))
        (t (list obj))))
(defun path-concat (&rest rest)
  (mapconcat #'identity (apply #'flat-list rest) path-separator))

(setq load-path
      (flat-list load-path
                 (expand-file-name "~/.emacs.d/elisp")
                 (file-expand-wildcards "~/.emacs.d/lisp/*")))

;; 実行パスの設定
(setq exec-path
      (append
       exec-path
       (mapcar 'expand-file-name
               (list "~/.emacs.d/bin/"
                     "~/.lein/bin/"
                     "~/.shelly/bin/"
                     "~/.cabal/bin/"))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; #環境変数の設定 #env
(setenv "PATH" (path-concat (getenv "PATH") exec-path))
(setenv "LD_LIBRARY_PATH"
        (path-concat
         (getenv "LD_LIBRARY_PATH")
         "./" "/usr/local/lib"))
(setenv "JAVA_HOME" "/usr/lib/jvm/default-java")
(setenv "CLASSPATH"
        (path-concat
         (getenv "CLASSPATH")
         "/home/kim/android-sdk-linux/platforms/android-11/android.jar"))
(setenv "XDG_CONFIG_DIRS" (expand-file-name "~/.config"))
(setenv "XDG_DATA_DIRS" "/usr/local/share/:/usr/share/")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; #compat
(fset 'parse-integer 'cl-parse-integer)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; #日本語
(eval-after-load 'kkc
  '(progn
     (define-key kkc-keymap (kbd "C-g") #'kkc-cancel)
     (define-key kkc-keymap (kbd "C-h") #'kkc-cancel)))
(eval-after-load 'quail
  '(progn
     (setq-default quail-japanese-use-double-n t)
     (define-key quail-conversion-keymap (kbd "C-g")
       #'(lambda ()
           (interactive)
           (quail-conversion-beginning-of-region)
           (quail-conversion-delete-tail)))
     (define-key quail-conversion-keymap (kbd "C-h") #'quail-conversion-backward-delete-char)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; #package
(require 'package)
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)
(package-initialize)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; #keybind
(global-set-key (kbd "C-h") #'backward-delete-char)
(global-set-key (kbd "C-x C-q") #'view-mode)
(global-set-key (kbd "C-x 4 k") #'kill-buffer-other-window)
(global-set-key (kbd "<C-return>") #'newline-on-structure)
(global-set-key (kbd "<C-S-right>") #'next-buffer)
(global-set-key (kbd "<C-S-left>") #'previous-buffer)
(global-set-key (kbd "C-M-g") (lambda (str)
                                (interactive (lexical-let ((word (word-at-point)))
                                               (setq word (if word
                                                              word
                                                            ""))
                                               (list (read-string "Seach Word: " word t))))
                                (browse-url (format "%s%s" eww-search-prefix str))))
(define-key isearch-mode-map (kbd "C-h") #'isearch-delete-char)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; #commands
(defvar newline-on-structure-delimiter-re "\\( \\|\\.\\|->\\)")
(defun newline-on-structure ()
  "'default' function for C-RET."
  (interactive)
  (let ((pos (point)) (word) (beg) (end))
    (save-excursion
      (back-to-indentation)
      (setq beg (point))
      (narrow-to-region beg pos)
      (unwind-protect (search-forward-regexp newline-on-structure-delimiter-re nil t 1)
        (widen))
      (setq end (point)))
    (setq word (buffer-substring beg end))
    (goto-char pos)
    (newline)
    (when word (insert word))
    (indent-for-tab-command)
    (end-of-line)))

(defadvice forward-page (after ad-forward-page activate)
  "Top of the page is to be top of window."
  (recenter-top-bottom 0))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; #misc
;; テーマを設定
(load-theme 'alect-dark t)
;; .elと.elcの新しい方をロードする
(setq load-prefer-newer t)
;; メニューバーを消す
(menu-bar-mode -1)
;; ツールバーを消す
(tool-bar-mode -1)
;; スクロールバーを消す
(scroll-bar-mode -1)
(horizontal-scroll-bar-mode -1)
;; 主張しないスクロールバーを使う
(global-yascroll-bar-mode +1)
;; スタートアップになにもしない
(setq inhibit-startup-screen t)
(setq inhibit-startup-echo-area-message t)
;; スクロールを等速に
(setq mouse-wheel-progressive-speed nil)
;; 補完候補を随時表示
(icomplete-mode)
;; ファイルが外部から変更されたら自動でrevert
(global-auto-revert-mode)
;; バックアップファイルとオートセーブファイルを作らない
(setq backup-inhibited t)
(setq delete-auto-save-files t)
;; 対応する括弧を自動で挿入
(electric-pair-mode 1)
(electric-indent-mode 1)
;; 対応する括弧を光らせる
(show-paren-mode)
;; ビーブ音を鳴らさない
(if (bound-and-true-p ring-bell-function)
    (setq ring-bell-function nil))
;; yes or noを全てy or nに
(fset 'yes-or-no-p #'y-or-n-p)
;; C-x C-f のデフォルトをポイントに応じて変更する
(ffap-bindings)
;; windowサイズが100桁以上なら左右に分割、それ以外なら上下に分割。
(setq split-height-threshold nil)
(setq split-width-threshold 100)
;; ミニバッファの履歴を終了後も保存
(savehist-mode)
;; recentf-modeのセットアップ
(recentf-mode)
;; ;; フルスクリーンで起動する
;; (toggle-frame-maximized)
;; インデントにタブを許さない
(setq-default indent-tabs-mode nil)
;; リンク先がvcされてたらvcされてるファイルとして扱う
(setq-default vc-follow-symlinks t)
;; minibufferからminibufferを使うコマンドを許す
(setq-default enable-recursive-minibuffers t)
;; 余分な空白をハイライト
(setq show-trailing-whitespace t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; #dired
;; diredのファイルサイズ単位をhuman-readbleに
(setq dired-listing-switches (purecopy "-Ahl"))
;; 左右にdiredを開いたときにcp, mvをdwimに
(setq-default dired-dwim-target t)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; #auto-complete
;; (require 'auto-complete-config)
;; (require 'ac-ja)
;; (ac-config-default)
;; (setq ac-disable-faces nil)
;; (setq ac-delay 0.02)
;; (setq ac-auto-show-menu 0.1)
;; (setq ac-menu-height 12)
;(add-to-list 'ac-sources 'ac-source-symbols)
;(global-auto-complete-mode t)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; #company
(add-hook 'after-init-hook '(lambda ()
                              (global-company-mode)
                              (define-key company-active-map (kbd "C-h") 'backward-delete-char)))
(setq-default company-idle-delay 0.02)
(setq-default company-minimum-prefix-length 3)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; #irc #erc
(autoload #'erc "erc" nil t)
(eval-after-load 'erc
  '(progn
     (setq erc-modules
           '(autojoin button completion fill ;irccontrols list; match
                      menu move-to-prompt netsplit networks noncommands notifications readonly ring stamp track
                      ))
     (setq-default erc-server "192.168.1.4:6667")
     (setq-default erc-nick "keen")
     (setq-default erc-hide-list '("JOIN"  "PART" "QUIT"))
     (setq-default erc-timestamp-format "%Y-%m-%d %H:%M")))
(autoload #'tiarra-conf-mode "tiarra-conf")
(add-to-list 'auto-mode-alist '("tiarra.conf" . tiarra-conf-mode))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; #Octopress
(load "octomacs-autoloads" nil t)
(setq-default octomacs-workdir-alist '(("default" . "~/Ruby/octopress")))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;#twittering-mode
(autoload #'twit "twittering-mode" nil t)
(setq-default twittering-username "blackenedgold")
(setq-default twittering-use-master-password t)
(setq-default twittering-icon-mode t)
(setq-default twittering-edit-skeleton 'inherit-mentions)
;;詳細はtwittering-mode.elでC-s %T
(setq-default twittering-status-format "%FOLD{%i%S[%s]%p%@\n%T\n%Rfrom %f%L}")
(setq-default twittering-retweet-format '(nil _ " QT %s: %t"))
(eval-after-load 'twittering-mode
  '(progn
     (define-key twittering-mode-map (kbd "C-c F") #'twittering-follow)
     (define-key twittering-mode-map (kbd "F")     #'twittering-favorite)))
(setq-default twittering-use-native-retweet t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; #speedbar
(eval-after-load 'speedbar
  '(progn
    (global-set-key (kbd "<C-S-up>")
                   (lambda ()
                     (interactive)
                     (speedbar-get-focus)
                     (speedbar-prev 1)
                     (speedbar-item-info)
                     (speedbar-edit-line)))
   (global-set-key (kbd "<C-S-down>")
                   (lambda ()
                     (interactive)
                     (speedbar-get-focus)
                     (speedbar-next 1)
                     (speedbar-edit-line)))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; #yasnippet
(require 'yasnippet)
(eval-after-load 'yasnippet
  '(progn
     (defun yas/advise-indent-function (function-symbol)
       (eval `(defadvice ,function-symbol (around yas/try-expand-first activate)
                ,(format
                  "Try to expand a snippet before point, then call `%s' as usual"
                  function-symbol)
                (let ((yas/fallback-behavior nil))
                  (unless (and (called-interactively-p)
                               (yas/expand))
                    ad-do-it)))))
     (yas/advise-indent-function #'indent-for-tab-command)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; #org-mode
(setq-default org-mobile-directory "~/Dropbox/アプリ/MobileOrg")
(setq-default org-mobile-inbox-for-pull org-mobile-directory)
(setq-default org-directory "~/Dropbox/memo/")

;;capture
(setq-default org-default-notes-file (concat org-directory "agenda.org"))
(setq-default org-agenda-files (list org-default-notes-file))
(setq-default org-capture-templates
              '(("t" "Todo" entry
                 (file+headline nil "Inbox")
                 "** TODO %?\n   %i\n   %a\n   %t")
                ("c" "Capture" entry
                 (file+headline nil "Capture")
                 "** %?\n   %i\n   %a\n   %t")
                ("a" "Agenda" entry
                 (file+headline nil "Agendas")
                 "** %?\n   %i\n   %t")))
(eval-after-load 'org
  '(progn
     (require 'ox-latex)
     (require 'org-capture)
     (org-babel-do-load-languages
      'org-babel-load-languages
      '((ruby . t)
        (emacs-lisp . t)
        (lisp . t)
        (clojure . t)
        (java . t)
        (sh . t)
        (scheme . t)))

     (setq-default org-latex-custom-lang-environments
                   '((emacslisp "emacs-lispcode")
                     (ruby "rubycode")
                     (clojure "clojurecode")
                     (java "javacode")
                     (shell "shcode")))
     (setq-default org-latex-listings-options
                   '(("frame" "lines")
                     ("basicstyle" "\\small")
                     ("numbers" "left")
                     ("numberstyle" "\\tiny")))
     (setq-default org-latex-date-format "%Y-%m-%d")
     (setq-default org-latex-listings 'listings)
     (setq-default org-latex-default-class "jsarticle")
     (unless (boundp 'org-export-latex-classes)
       (setq-default org-export-latex-classes nil))
     (add-to-list 'org-latex-classes
                  '("jsarticle"
                    "\\documentclass[11pt,a4paper]{jsarticle}"
                    ("\\section{%s}" . "\\section*{%s}")
                    ("\\subsection{%s}" . "\\subsection*{%s}")
                    ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                    ("\\paragraph{%s}" . "\\paragraph*{%s}")
                    ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))
     (setq-default org-latex-to-pdf-process '("platex %b" "dvipdfmx %b"))))

;;yaspnippetを有効化する
(eval-after-load 'yassnipet
  '(yas/advise-indent-function #'org-cycle))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; #newsticker #RSS
(setq-default newsticker-url-list '(("Rust" "http://blog.rust-lang.org/feed.xml")
                                    ("reddit" "http://www.reddit.com/.rss?feed=a33076ca1206de00a91f1e190a437abede27a042&user=blackenedgold")
                                    ("朝日-IT/Sci" "http://rss.asahi.com/rss/asahi/science.rdf")
                                    ("技術評論社" "http://rss.rssad.jp/rss/gihyo/feed/rss2?rss")
                                    ("Planet Lisp" "http://planet.lisp.org/rss20.xml")
                                    ("Hacker News" "https://news.ycombinator.com/rss")))
(setq-default newsticker-url-list-defaults
              '(("LWN (Linux Weekly News)" "http://lwn.net/headlines/rss")))
(setq-default newsticker-retrieval-interval 0)
(setq newsticker-html-renderer #'shr-render-region)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; #Web #Mail
(setq-default eww-search-prefix "https://www.google.co.jp/search?q=")
(autoload #'eww-list-bookmarks "eww" nil t)
;;;メール設定
(setq user-mail-address "3han5chou7@gmail.com")
(setq user-full-name "金舜琳")
(setq mail-use-rfc822 t)
(setq-default message-send-mail-function #'smtpmail-send-it
              smtpmail-default-smtp-server "smtp.gmail.com"
              smtpmail-smtp-service 587)

;;; #wanderlust #wl
;;主な物は~/.wlと~/.foldersにある。
(autoload 'wl "wl" "Wanderlust" t)
(autoload 'wl-draft "wl" "Write draft with Wanderlust." t)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; #HTML
;;; #web-mode
(add-to-list 'auto-mode-alist '("\\.htm[l]" . web-mode))
(add-hook 'web-mode-hook #'(lambda ()
                             (require 'yasnippet)
                             (yas/minor-mode)))

;;; #emmet
(add-hook 'sgml-mode-hook #'emmet-mode)
(add-hook 'web-mode-hook #'emmet-mode)
(add-hook 'css-mode-hook #'emmet-mode)
(eval-after-load 'emmet-mode
  '(progn (define-key emmet-mode-keymap (kbd "C-j") #'newline-and-indent)
          (setq-default emmet-indentation 2)
          (setq-default emmet-preview-default nil)))

(add-hook 'css-mode-hook #'css-eldoc-enable)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; #xml
;; for Java development
;; options
(setq-default nxml-slash-auto-complete-flag t)
(setq-default nxml-sexp-element-flag t)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; #yaml
(autoload #'yaml-mode "yaml-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.ya?ml" . yaml-mode))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; #markdown
(add-hook 'markdown-mode-hook (lambda () (electric-indent-mode -1)))
(add-to-list 'auto-mode-alist '("\\.markdown$" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.md$" . gfm-mode))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; #flymake 文法チェック
(global-flycheck-mode)
(dolist (mode '(emacs-lisp emacs-lisp-checkdoc))
  (delete mode flycheck-checkers))
(global-set-key (kbd "C-c d") #'flymake-display-err-menu-for-current-line)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; #Shell
(autoload #'ansi-color-for-comint-mode-on "ansi-color"
  "Set `ansi-color-for-comint-mode' to t." t)
(add-hook 'shell-mode-hook #'ansi-color-for-comint-mode-on)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; #Eshell
(setq-default eshell-banner-message "")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; #Lisp
(load (expand-file-name "~/.cim/init.esh") nil t)
;;括弧の対応を取る
(eval-after-load 'paredit
  '(define-key paredit-mode-map (kbd "C-h") #'paredit-backward-delete))
(dolist (hook '(emacs-lisp-mode-hook
                ielm-mode-hook
                lisp-mode-hook
                inferior-lisp-mode-hook
                slime-repl-mode-hook
                REPL-mode-hook
                clojure-mode-hook
                scheme-mode-hook
                inferior-scheme-mode-hook))
  (add-hook hook #'enable-paredit-mode)
  (add-hook hook #'eldoc-mode)
  (add-hook hook #'prettify-symbols-mode))

;;; #Common Lisp #slime
(slime-setup '(slime-fancy))
(setq-default slime-autodoc-delay 0.1)
;; M-- M-x slime で起動する処理系を選択できる
(setq-default slime-lisp-implementations
              '((sbcl ("~/.cim/bin/sbcl"))
                (clisp ("~/.cim/bin/clisp"))
                (ccl ("~/.cim/bin/ccl"))
                (ecl ("~/.cim/bin/ecl"))))
;;; #Clojure
(add-hook 'clojure-mode-hook (lambda ()
                               (durendal-enable-auto-compile)
                               (add-to-list (make-local-variable 'company-backends) '(company-cider :with company-yasnippet))))
(add-hook 'sldb-mode-hook #'durendal-dim-sldb-font-lock)
(add-hook 'slime-compilation-finished-hook #'durendal-hide-successful-compile)

;;; #Scheme #Gauche
(setq-default scheme-program-name "gosh -i")
(autoload #'scheme-mode "cmuscheme" "Major mode for Scheme." t)
(autoload #'run-scheme "cmuscheme" "Run an inferior Scheme process." t)

;;; #EmacsLisp
(defun eldoc-documentation-function-default ())
(dolist (hook '(emacs-lisp-mode-hook lisp-interaction-mode-hook ielm-mode-hook))
  (add-hook hook #'(lambda ()
                     (require 'eldoc-extension)
                     (eldoc-mode))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; #ruby系
(setq-default ruby-deep-indent-paren-style nil)

;;; デバッガ
(autoload #'rubydb "rubydb3x" "ruby debug" t)

(add-hook 'ruby-mode-hook #'(lambda ()
                              (require 'smartparens-ruby)
                              (robe-mode)
                              (add-to-list (make-local-variable 'company-backends) '(company-robe :with company-yasnippet))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; #mirah
(autoload #'mirah-mode "mirah-mode" "major-mode for mirah" t)
(add-to-list 'auto-mode-alist '("\\.mirah$" . mirah-mode))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; #PHP
;; Debug a simple PHP script.
;; Change the session key my-php-54 to any session key text you like
(defun my-php-debug ()
  "Run current PHP script for debugging with geben."
  (interactive)
  (call-interactively #'geben)
  (shell-command
   (concat "php " (buffer-file-name) " &")))
(setq-default php-manual-path "/usr/local/share/php/doc/html")
(setq-default php-manual-url "http://www.phppro.jp/phpmanual")
(add-hook 'php-mode-hook
          #'(lambda ()
              (php-eldoc-enable)
              (require 'php-completion)
              (php-completion-mode t)
              (add-to-list 'ac-sources 'ac-source-php-completion)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; #Java #eclim

(setq eclimd-default-workspace (expand-file-name "~/Java"))
(add-hook 'java-mode-hook (lambda ()
                            (eclim-mode)
                            (setq-default c-basic-offset 4)))

(eval-after-load 'eclim
  '(progn
     (setq-default eclimd-wait-for-process nil)
     (require 'eclimd)
     (start-eclimd eclimd-default-workspace)
     (require 'company-emacs-eclim)
     (company-emacs-eclim-setup)))
(autoload 'javadoc-help         "javadoc-help" "Open up the Javadoc-help menu."   t)
(autoload 'javadoc-set-predefined-urls  "javadoc-help" "Set pre-defined urls."    t)
(setq-default *jdh-predefined-urls* '("/usr/lib/jvm/default-java/docs/api"))

;;;#android
(eval-after-load 'malabar-mode
  '(progn
;     (android-mode)
     (add-to-list 'load-path (expand-file-name "~/android-sdk-linux/tools/lib"))
;     (require 'android)
     (setq-default android-mode-sdk-dir "~/android-sdk-linux")))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; #OCaml #Caml #ML
;; (dolist (cons (car (read-from-string (shell-command-to-string "opam config env --sexp"))))
;;   (setenv (car cons) (cadr cons)))

;; Update the emacs path
(setq exec-path (split-string (getenv "PATH") path-separator))

;; Update the emacs load path
(add-to-list 'load-path (concat (getenv "OCAML_TOPLEVEL_PATH") "/../../share/emacs/site-lisp"))
(add-to-list 'load-path (concat (getenv "OCAML_TOPLEVEL_PATH") "/../../build/ocaml/emacs"))

;; Automatically load utop.el
(autoload #'utop "utop" "Toplevel for OCaml" t)
(autoload #'utop-setup-ocaml-buffer "utop" "Toplevel for OCaml" t)
(add-hook #'tuareg-mode-hook 'utop-setup-ocaml-buffer)
(setq-default utop-edit-command nil)


(defun ocp-index-show-type-at-point ()
  (lexical-let* ((sym (ocp-index-symbol-at-point))
                 (out (shell-command-to-string
                       (format "ocp-index type %s --full-open %s. -I."
                               sym
                               (upcase-initials
                                (file-name-nondirectory
                                 (file-name-sans-extension (buffer-file-name))))))))
    (if (not (string-equal out ""))
        (format "%s: %s" sym (substitute ?\; ?\n out))
      "")))

(add-hook 'tuareg-mode-hook 'enable-company-ocp-index)
(add-hook 'caml-mode-hook 'enable-company-ocp-index)
(autoload 'ocamlspot-query "ocamlspot" "OCamlSpot")
(add-hook 'tuareg-mode-hook #'(lambda ()
                                (require 'ocp-index)
                                (define-key tuareg-mode-map (kbd "C-j") #'reindent-then-newline-and-indent)
                                (setq-default tuareg-library-path (concat (getenv "OCAML_TOPLEVEL_PATH") "/../"))
                                (flymake-tuareg-load)
                                (flymake-mode-on)
                                (eldoc-mode)
                                (set (make-local-variable 'eldoc-documentation-function
                                                          )
                                     #'ocp-index-show-type-at-point)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; #Coq
(load (expand-file-name "~/.emacs.d/lisp/ProofGeneral/generic/proof-site") nil t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; #Haskell
(add-hook 'haskell-mode-hook #'flymake-haskell-multi-load)

(autoload #'ghc-init "ghc" nil t)
(dolist (hook '(haskell-mode-hook literate-haskell-mode-hook))
  (add-hook hook (lambda ()
                   (add-to-list (make-local-variable 'company-backends) '(company-ghc :with company-yasnippet)))))
(add-hook 'haskell-mode-hook #'ghc-init)
(add-hook 'haskell-mode-hook #'haskell-indentation-mode)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; #Scilab
(setq-default scilab-shell-command (expand-file-name "~/Downloads/scilab-5.5.0/bin/scilab"))
(autoload 'scilab-mode "scilab" "Enter Scilab editing mode." t)
(setq auto-mode-alist (cons '("\\(\\.sci$\\|\\.sce$\\)" . scilab-mode)
                            auto-mode-alist))
(autoload 'scilab-shell "scilab" "Interactive Scilab Shell mode." t)
(autoload 'scilab-mode-setup "scilab" "Scilab modes Setup." t)
(autoload 'scilab-help "scilab" "Scilab Topic Browser." t)
(autoload 'scilab-help-function "scilab" "Scilab Help Function." t)
(autoload 'scilab-apropos-function "scilab" "Scilab Apropos Function." t)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; #C
(add-hook 'c-mode-hook (lambda ()
                         (add-to-list (make-local-variable 'company-backends) '(company-c-headers :with company-yasnippet))
                         (add-to-list (make-local-variable 'company-backends) '(company-clang :with company-yasnippet))
                         (c-turn-on-eldoc-mode)
                         (setq-default c-basic-offset 2)))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; #CMake
(add-hook 'cmake-mode-hook (lambda ()
-                             (require 'company-cmake)
-                             (add-to-list (make-local-variable 'company-backends) 'company-cmake)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; #nginx
(add-to-list 'auto-mode-alist '("nginx.conf" . nginx-mode))

(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'capitalize-region 'disabled nil)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; #rust
(load "~/.emacs.d/lisp/racer/editors/racer.el" t t)
(setq racer-cmd "/home/kim/.emacs.d/lisp/racer/bin/racer")
(setq rust-srcpath "/home/kim/compile/rust/src")
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(safe-local-variable-values
   (quote
    ((Package . CL-USER)
     (Base . 10)
     (Package . CL-PPCRE-TEST)
     (Syntax . COMMON-LISP)))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
