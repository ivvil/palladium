;;;; palladium.asd

(in-package #:cl-user)
(asdf:defsystem #:palladium
  :description "Describe palladium here"
  :author "Iván Villagrasa <ivvil412@gmail.com>"
  :license  "Specify license here"
  :version "0.0.1"
  :defsystem-depends-on (:radiance)
  :class "radiance:virtual-module"
  :components ((:file "module")
               (:file "frontend"))
  :depends-on (:r-clip))
