#lang scribble/manual

@(require racket/sandbox
          scribble/eval
          rml/individual
          (for-label rml/individual
                     rml-decisiontrees
                     racket/contract
                     math/statistics))

@;{============================================================================}

@(define example-eval (make-base-eval
                      '(require racket/function rml/individual rml-decisiontrees)))

@;{============================================================================}

@title[#:tag "ml" #:version "1.0"]{Racket Machine Learning --- Decision Trees}
@author[(author+email "Simon Johnston" "johnstonskj@gmail.com")]

This Package is part of a set of packages implementing machine learning capabilities
for Racket. This particular package implements support for classification of
individuals using decision trees.

From @hyperlink["https://en.wikipedia.org/wiki/Decision_tree" "Wikipedia"] (note
that as this implementation is focused on classification we do not include
@italic{chance nodes}):

@italic{A decision tree is a flowchart-like structure in which each internal node
represents a "test" on an attribute (e.g. whether a coin flip comes up heads or
tails), each branch represents the outcome of the test, and each leaf node
represents a class label (decision taken after computing all attributes). The paths
from root to leaf represent classification rules.}

The intention is also to provide capabilities for random forest trees and other
supervised learning capabilities that generate the trees to be used by the classifier
described below.

@;{============================================================================}
@;{============================================================================}
@section[]{Module rml-decisiontrees}
@defmodule[rml-decisiontrees]

The notion of a decision tree is to encode a set of tests and outcomes that should
result in a classification value. This module builds a @racket[decision-tree] from
a root @racket[decision-node] that represents a set of tests against the value of a
specified feature on an @racket[individual]. The outcome of a particular test is
either the next @racket[decision-node], or a @racket[terminal-node] that holds a
classification value.

@examples[ #:eval example-eval
(define test-tree
  (make-decision-tree
    (make-decision
     "size"
     (list [cons (curryr < 5) (make-terminal 'small)]
           [cons (curryr > 10) (make-terminal 'large)])
     #:else (make-decision
             "color"
             (list [cons (curry string=? "black")
                         (make-terminal 'cocktail)])
                   #:else (make-terminal 'medium)))))

(define test-individual (make-hash (list (cons "size" 6)
                                         (cons "color" "black"))))

(tree-classify test-tree test-individual)
(for-each displayln (reverse (tree-trace test-tree)))
]

The example above classifies some individuals that represent dresses, and will
primarily use the size to identify @italic{small}, @italic{medium}, or
@italic{large}. However, it will further classify medium sized dresses as
@italic{cocktail} dresses if they are black. Clearly, this is not a terribly
good, or realistic, classifier!

@;{============================================================================}
@subsection[]{Construction}

@defproc[(make-decision-tree
           [root-decision decision-node?])
         decision-tree?]{
Construct a new @racket[decision-tree] using @racket[root-decision] as the initial
evaluation. The procedure will raise exceptions if the tree is malformed in any way,
for example:
@itemlist[
  @item{Every path through the tree should result in a @racket[terminal-node].}
  @item{No loops are allowed.}
]
}

@defproc[(make-decision
           [feature non-empty-string?]
           [cond-pairs (non-empty-listof
                         (cons/c
                           (-> serializable? boolean?)
                           tree-node?))]
           [#:else else-node tree-node? null])
         decision-node?]{
Construct a new @racket[decision-node], where @racket[cond-pairs] represents
a set of condition/outcome pairs that test the value of the specified feature.

The specific @racket[feature] value will be passed into each condition predicate
in order. For the first condition to return @racket[#t], the corresponding
@racket[tree-node] is the outcome of the decision and will be evaluated in turn.
If no condition predicate returns @racket[#t] and a value exists for
@racket[else-node], it will be treated as the outcome of the decision.
}

@defproc[(make-terminal
           [value serializable?]
           [#:error is-error boolean? #t])
         terminal-node?]{
Construct a new @racket[terminal-node] to return @racket[value] as the classification
result. If @racket[is-error] is @racket[#t] the result is treated as an error
condition.
}

@;{============================================================================}
@subsection[]{Classification}

@defproc[(tree-classify
           [tree decision-tree?]
           [individual individual?])
         serializable?]{
Return the classification value(s) represented by the @racket[terminal-node]
at the end of a path through the decision tree.

Note that the value @racket[drop-through-error] may be returned in the case that
a decision does not have a predicate for the given feature value and no
@racket[else-node] was specified.
}

@defproc[(tree-trace
           [tree decision-tree?])
         (listof string?)]{
Returns a list of strings that represent the path through the decision tree and
denote the feature names, values, and so forth that were selected to reach a
classification value. Note that values are returned with the latest decision first
and the root decision last.
}

@defthing[drop-through-error symbol?]{
A specific classification value that denotes a non-exhaustive decision (a decision node
did not have a matching outcome for the feature's value).
}

@defparam[sandbox-predicates sandbox-enable boolean? #:value #t]{
This parameter determines whether the predicates invoked by @racket[tree-classify]
within a @racket[decision-node] will be evaluated within a restricted sandbox
environment (see @secref["Sandboxed_Evaluation" #:doc '(lib "scribblings/reference/reference.scrbl")]).
This ensures that the predicates do not perform either long-running actions or rely on
file-system or network resources.
}
