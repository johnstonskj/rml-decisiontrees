#lang racket
;;
;; Racket Machine Learning - Decision Trees.
;;
;;
;; ~ Simon Johnston 2018.

(provide
 (contract-out

  [tree-classify
   (-> decision-tree? individual? serializable?)]

  [make-decision-tree
   (-> decision-node? (or/c decision-tree? null?))]

  [make-decision
   (-> non-empty-string?
       (non-empty-listof (cons/c (-> any/c boolean?) tree-node?)) #:else tree-node?
       decision-node?)]

  [make-terminal
   (->* (serializable?) (#:error boolean?) terminal-node?)]

  [tree-trace
   (-> decision-tree? (listof string?))]

  [drop-through-error terminal-node?])

 sandbox-predicates)

;; ---------- Requirements

(require
  racket/sandbox
  racket/serialize
  rml/classify
  rml/individual)

;; ---------- Internal types

(struct decision-tree
  (root
   evaluator
   [history #:mutable]))

(struct tree-node ())

(struct decision-node tree-node
  (feature
   cond-pairs
   else-node))

(struct terminal-node tree-node
   (value
    is-error))

(struct trace-entry
  (feature-name
   value
   outcome))

;; ---------- Implementation

(define sandbox-predicates (make-parameter #t))

(define evaluator-memory-limit 16) ;; Mb

(define evaluator-time-limit 2.0) ;; seconds

(define (tree-classify tree individual)
  (evaluate-tree tree individual))

(define (tree-trace tree)
  (for/list ([trace (decision-tree-history tree)])
      (display-trace trace)))

(define (make-decision-tree root-decision)
  (if (tree-validate root-decision)
      (if (sandbox-predicates)
          (decision-tree root-decision (make-tree-evaluator) '())
          (decision-tree root-decision null '()))
      null))

(define (make-decision feature cond-pairs #:else [else-node null])
  (decision-node feature cond-pairs else-node))

(define (make-terminal terminal-value #:error [is-error #f])
  (terminal-node terminal-value is-error))

(define drop-through-error (make-terminal (gensym) #:error #t))

;; ---------- Internal procedures

(define (tree-validate tree)
  #t)

(define (make-tree-evaluator)
  (parameterize ([sandbox-output 'string]
                 [sandbox-propagate-exceptions #t]
                 [sandbox-eval-limits
                  (list evaluator-time-limit evaluator-memory-limit)])
    (make-evaluator 'racket/base '(define version 1.0) #:requires '(rml/individual))))

(define trace-root-value (gensym))

(define (evaluate-tree tree individual)
  ;; reset the history each time we evaluate.
  (set-decision-tree-history! tree (list (trace-entry "" trace-root-value (decision-tree-root tree))))
  (evaluate-tree-next tree (decision-tree-root tree) individual))

(define (evaluate-tree-next tree decision individual)
  (let ([trace (evaluate-decision tree decision individual)])
    (set-decision-tree-history! tree (cons trace (decision-tree-history tree)))
    (if (terminal-node? (trace-entry-outcome trace))
        (terminal-node-value (trace-entry-outcome trace))
        (evaluate-tree-next tree (trace-entry-outcome trace) individual))))

(define (evaluate-decision tree decision individual)
  (let* ([evaluator (decision-tree-evaluator tree)]
         [feature-name (decision-node-feature decision)]
         [feature-value (hash-ref individual feature-name)])
    (let ([outcome (for/or ([pair (decision-node-cond-pairs decision)])
                     (if (evaluate-predicate evaluator (car pair) feature-value)
                         (trace-entry feature-name feature-value (cdr pair))
                         #f))])
      (if (equal? outcome #f)
          (if (not (null? (decision-node-else-node decision)))
              (trace-entry feature-name feature-value (decision-node-else-node decision))
              (trace-entry feature-name feature-value drop-through-error))
          outcome))))

(define (evaluate-predicate evaluator predicate value)
  (if (null? evaluator)
      (predicate value)
      (evaluator `(,predicate ,value))))

(define (display-trace trace)
  (if (equal? (trace-entry-value trace) trace-root-value)
      (format "(root ~a)" (display-outcome (trace-entry-outcome trace)))
      (format "(~a ~s) -> ~a"
              (trace-entry-feature-name trace)
              (trace-entry-value trace)
              (display-outcome (trace-entry-outcome trace)))))

(define (display-outcome node)
  (if (decision-node? node)
      (format "(decision ~s [~a])"
              (decision-node-feature node)
              (length (decision-node-cond-pairs node)))
      (format "(terminal ~s~a)"
              (terminal-node-value node)
              (if (terminal-node-is-error node) " is-error" ""))))
