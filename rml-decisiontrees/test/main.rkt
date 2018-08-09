#lang racket
;;
;; Racket Machine Learning - Decision Trees.
;;
;;
;; ~ Simon Johnston 2018.

;; ---------- Requirements

(require
  rackunit

  rml-decisiontrees)

(define test-decision
  (make-decision
   "size"
   (list [cons (curryr < 5) (make-terminal 'small)]
         [cons (curryr > 10) (make-terminal 'large)])
   #:else (make-decision
           "color"
           (list [cons (curry string=? "black") (make-terminal 'cocktail)])
           #:else (make-terminal 'medium))))

(define test-tree (make-decision-tree test-decision))

;; ---------- Test Cases

(test-case
 "test a very simple decision tree"
 (let ([individual (make-hash (list (cons "size" 3) (cons "color" "black")))])
   (check-eq? (tree-classify test-tree individual) 'small)
   (check-eq? (length (tree-trace test-tree)) 2))
 (let ([individual (make-hash (list (cons "size" 12) (cons "color" "black")))])
   (check-eq? (tree-classify test-tree individual) 'large)
   (check-eq? (length (tree-trace test-tree)) 2))
 (let ([individual (make-hash (list (cons "size" 6) (cons "color" "black")))])
   (check-eq? (tree-classify test-tree individual) 'cocktail)
   (check-eq? (length (tree-trace test-tree)) 3))
 (let ([individual (make-hash (list (cons "size" 6) (cons "color" "blue")))])
   (check-eq? (tree-classify test-tree individual) 'medium)
   (check-eq? (length (tree-trace test-tree)) 3)))

(test-case
 "fail on fall-through"
 (let* ([decision (make-decision
                 "size"
                 (list [cons (curryr < 5) (make-terminal 'small)]
                       [cons (curryr > 10) (make-terminal 'large)]))]
        [tree (make-decision-tree decision)]
        [individual (make-hash (list (cons "size" 6) (cons "color" "black")))]
        [classifier (tree-classify tree individual)])
   (check-equal? classifier drop-through-error)))
