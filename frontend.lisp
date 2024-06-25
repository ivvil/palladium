;;;; frontend.lisp

(in-package #:palladium)


(define-page dbadd "palladium/dbadd" (:clip "dbadd.ctml")
  (r-clip:process T))


(define-page dbview "palladium/view/(.*)" (:uri-groups (id) :clip "dbview.ctml")
  (r-clip:process T))
