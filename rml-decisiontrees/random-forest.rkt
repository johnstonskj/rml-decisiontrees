#lang racket
;;
;; Racket Machine Learning - Decision Trees.
;;
;;
;; ~ Simon Johnston 2018.

(provide
 (contract-out
))

;; ---------- Requirements

(require
  math/statistics
  rml/data
  rml/individual
  rml/gini
  rml-decisiontrees)

;; ---------- Internal types

;; ---------- Implementation

(define maximum-tree-depth (make-parameter 5))

(define minimum-sample-size (make-parameter 10))

(define (make-forest dataset) #f)

(define (make-tree dataset) #f)

(define (for-tree dataset (partition default-partition))
  (let-values ([(feature value score)
                (gini-find-optimal
                 (individuals dataset partition)
                 "feature"
                 (first (classifiers dataset))
                 (classifier-product dataset))])
    #f))

;; ---------- Internal procedures

(define (make-a-terminal sample classifier)
  (let ([class-counts (samples->hash (map (curryr hash-ref classifier) sample))])
    (let-values ([(count class) (for/fold ([max-count 0]
                                           [max-class #f])
                                          ([(class count) class-counts])
                                  (if (> count max-count)
                                      (values count class)
                                      (values max-count max-class)))])
      (displayln (format "~a ~a%" class (/ count (length sample))))
      (make-terminal class))))

;; ---------- Tests

(module+ test
  (require rackunit rackunit/docs-complete)

  (define XY-data
    (list
     (hash "X1" 2.771244718 "X2" 1.784783929 "Y" 0)
     (hash "X1" 1.728571309 "X2" 1.169761413 "Y" 0)
     (hash "X1" 3.678319846 "X2" 2.81281357 "Y" 0)
     (hash "X1" 3.961043357 "X2" 2.61995032 "Y" 0)
     (hash "X1" 2.999208922 "X2" 2.209014212 "Y" 0)
     (hash "X1" 7.497545867 "X2" 3.162953546 "Y" 1)
     (hash "X1" 9.00220326 "X2" 3.339047188 "Y" 1)
     (hash "X1" 7.444542326 "X2" 0.476683375 "Y" 1)
     (hash "X1" 10.12493903 "X2" 3.234550982 "Y" 1)
     (hash "X1" 6.642287351 "X2" 3.319983761 "Y" 1)))
  
  (test-case
   "test splits"
   (sample-partition-individuals XY-data "X1" 6)
   ;  sample feature classifier-key classifier-values
   (gini-find-optimal-value XY-data "X1" "Y" '(0 1)))
   (gini-find-optimal XY-data '("X1" "X2") "Y" '(0 1)))