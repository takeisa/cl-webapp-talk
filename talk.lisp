(ql:quickload :hunchentoot)
(ql:quickload :trivial-shell)
(ql:quickload :cl-who)

(hunchentoot:start (make-instance 'hunchentoot:easy-acceptor :port 4242))

(hunchentoot:define-easy-handler (say-yo :uri "/yo") (name)
  "hunchentoot sample"
  (setf (hunchentoot:content-type*) "text/plain")
  (format nil "Hey~@[ ~A~]!" name))

(hunchentoot:define-easy-handler (say :uri "/talk") (sentence)
  (setf (hunchentoot:content-type*) "text/html")
  (prog1
    (talk-page sentence)
    (when (> (length sentence) 0)
      (talk sentence))))

(defun talk-page (sentence)
  (setf (cl-who:html-mode) :xml)
  (cl-who:with-html-output-to-string (*standard-output* nil :prologue t :indent t)
    (:html
     (:head (:title "Talk with Open JTalk")
	    (:meta :charset "UTF-8"))
     (:body
      (:h1 "Talk with Open JTalk")
      (:p
       (:form :method "get"
	      "Talk:"
	      (:input :type "text" :name "sentence"
		      :value (cl-who:escape-string sentence)
		      :size "80")
	      (:input :type "submit")
	      (:input :type "button" :value "消去"
		      :onclick "var elm = document.getElementsByName(\"sentence\")[0]; elm.value = \"\"; elm.focus();")))))))

(defparameter *talk-command* "/home/satoshi/workspace/talk/talk.sh")
(defparameter *talk-file-name* "/home/satoshi/workspace/talk/talk.txt")

(defun talk (s)
  (write-sentence s)
  (exec-talk-command))

(defun exec-talk-command ()
    (trivial-shell:shell-command
     (with-output-to-string (*standard-output*)
       (format t "~a ~a" *talk-command* *talk-file-name*))))

(defun write-sentence (s)
  (with-open-file (*standard-output*
		   *talk-file-name*
		   :direction :output
		   :if-exists :supersede)
    (format t "~a~%" s)))

