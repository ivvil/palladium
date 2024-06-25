;;;; frontend.lisp

(in-package #:palladium)


(define-page dbadd "palladium/dbadd" (:clip "dbadd.ctml")
  (r-clip:process T))


(define-page dbview "palladium/dbview/(.*)" (:uri-groups (id) :clip "dbview.ctml")
  (r-clip:process
   T
   :action (ensure-event id)))

(defun ensure-event (evt-ish)
  (typecase evt-ish
	(dm:data-model evt-ish)
	(db:id (or (dm:get-one 'palladium-actions (db:query (:= '_id evt-ish)))
			   (error 'request-not-found :message (format nil "No action with ID ~a found." evt-ish))))
	(T (ensure-event (db:ensure-id evt-ish)))))

(defun create-event (event data)
  (let ((action (dm:hull 'palladium-actions)))
	(setf (dm:field action "event") event
		  (dm:field action "time") (get-universal-time)
		  (dm:field action "data") data)))

(define-api palladium/new (event data) ()
  (let ((evt (create-event event data)))
	(if (string= "true" (post/get "browser"))
		(redirect (make-uri :domains '("palladium")
							:path (format nil "dbview/~a" (dm:id evt))))
		(api-output `(("id" . ,(dm:id evt)))))))

(define-trigger db:connected ()
  (db:create 'palladium-actions '((event (:varchar 32))
								  (time (:integer 5))
								  (data :text))))
