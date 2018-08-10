#lang info
;;
;; Racket Machine Learning - Core.
;;
;; ~ Simon Johnston 2018.
;;

(define collection 'multi)

(define pkg-desc "Racket Machine Learning - Decision Trees")
(define version "1.0")
(define pkg-authors '(johnstonskj))

(define deps '(
  "base"
  "rml-core"
  "math-lib"
  "sandbox-lib"
  "racket-index"
  "rackunit-lib"))
(define build-deps '(
  "scribble-lib"
  "racket-doc"
  "cover-coveralls"))
