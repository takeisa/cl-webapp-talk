(ql:quickload :hunchentoot)
(ql:quickload :trivial-shell)
(ql:quickload :cl-who)

(hunchentoot:start (make-instance 'hunchentoot:easy-acceptor :port 4242))

(hunchentoot:define-easy-handler (say-yo :uri "/yo") (name)
  "hunchentoot sample"
  (setf (hunchentoot:content-type*) "text/plain")
  (format nil "Hey~@[ ~A~]!" name))

(hunchentoot:define-easy-handler (talk-handler :uri "/talk") (message)
  (setf (hunchentoot:content-type*) "text/html")
  (prog1
    (talk-page message)
    (when (> (length message) 0)
      (talk message))))

(defun talk-page (message)
  (setf (cl-who:html-mode) :html5)
  (cl-who:with-html-output-to-string (*standard-output* nil :prologue t :indent t)
    (:html
     (:head (:title "Talk with Open JTalk")
	    (:meta :charset "UTF-8"))
     (:body
      (:h1 "Talk with Open JTalk")
      (:p
       (:form :method "get"
	      "Talk:"
	      (:input :type "text" :name "message"
		      :value (cl-who:escape-string message)
		      :size "80")
	      (:input :type "submit")
	      (:input :type "button" :value "Clear message"
		      :onclick "var elm = document.getElementsByName(\"message\")[0]; elm.value = \"\"; elm.focus();")))))))

;;; edit your own environment
(defparameter *talk-command* "/home/satoshi/workspace/talk/talk.sh")
(defparameter *message-file-name* "/home/satoshi/workspace/talk/message.txt")

(defun talk (message)
  (write-message message)
  (exec-talk-command))

(defun exec-talk-command ()
    (trivial-shell:shell-command
     (with-output-to-string (*standard-output*)
       (format t "~a ~a" *talk-command* *message-file-name*))))

(defun write-message (message)
  (with-open-file (*standard-output*
		   *message-file-name*
		   :direction :output
		   :if-exists :supersede)
    (format t "~a~%" message)))

