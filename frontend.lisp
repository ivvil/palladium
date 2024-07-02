;;;; frontend.lisp

(in-package #:palladium)

(defparameter *events-per-page* 25)

(define-page dbadd "palladium/dbadd" (:clip "dbadd.ctml")
  (r-clip:process T))

(define-page dbview "palladium/dbview/(.*)" (:uri-groups (id) :clip "dbview.ctml")
  (r-clip:process
   T
   :action (ensure-event id)))

(define-page raw "palladium/view/(.*)/raw" (:uri-groups (id))
  (setf (content-type *response*) "text/plain")
  (dm:field (ensure-event id) "data"))

(define-page list "palladium/list(?:/(.*))?" (:uri-groups (page) :clip "list.ctml")
  (let* ((page (or (when page (parse-integer page :junk-allowed T)) 0))
         (events (dm:get 'palladium-actions (db:query :all)
                         :sort '((time :DESC))
                         :skip (* page *events-per-page*)
                         :amount *events-per-page*)))
    (r-clip:process T :events events
                      :page page
                      :has-more (<= *events-per-page* (length events)))))

(defun ensure-event (evt-ish)
  (typecase evt-ish
	(dm:data-model evt-ish)
	(db:id (or (dm:get-one 'palladium-actions (db:query (:= '_id evt-ish)))
			   (error 'request-not-found :message (format nil "No action with ID ~a found." evt-ish))))
	(T (ensure-event (db:ensure-id evt-ish)))))

(defun create-event (event data)
  (let ((action (dm:hull 'palladium-actions)))
    (setf (dm:field action "event") event
          (dm:field action "data") data
          (dm:field action "time") (get-universal-time))
    (dm:insert action)))

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
