#!/bin/bash
":"; exec emacs -Q  --script "$0" -f main -- "$@" # -*-emacs-lisp-*-

(require 'ox-publish)
(setq basedir "~/proyectos/ccompu/")
(setq org-publish-project-alist
      '(("ccompu"
        :base-directory "~/proyectos/ccompu/org/"
        :base-extension "org"
        :publishing-directory "~/proyectos/ccompu/jekyll/"
        :recursive t
        :publishing-function org-html-publish-to-html
        :headline-levels 4     ; Just the default for this project.
        :html-extension "html"
        :body-only t)

        ("ccompu" :components ("org"))))

(defun main ()
  (org-publish-project "ccompu" t))
