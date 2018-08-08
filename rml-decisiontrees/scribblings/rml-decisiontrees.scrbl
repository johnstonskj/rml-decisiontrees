#lang scribble/manual

@(require racket/sandbox
          scribble/eval
          rml/individual
          (for-label rml/individual
                     rml-decisiontrees
                     racket/contract
                     math/statistics))

@;{============================================================================}

@title[#:tag "ml" #:version "1.0"]{Racket Machine Learning --- Decision Trees}
@author[(author+email "Simon Johnston" "johnstonskj@gmail.com")]

Package Description Here

@;@table-of-contents[]

@;{============================================================================}
@;{============================================================================}
@section[]{Module rml-decisiontrees}
@defmodule[rml-decisiontrees]

Module Description Here

@;{============================================================================}
@subsection[]{Construction}

@defproc[(make-decision-tree
           [root-decision decision-node?])
         (or/c decision-tree? null?)]{
}

@defproc[(make-decision
           [feature non-empty-string?]
           [cond-pairs (non-empty-listof (cons/c (-> any/c boolean?) tree-node?))]
           [#:else else-node tree-node?])
         decision-node?]{
}

@defproc[(make-terminal
           [value serializable?]
           [#:error is-error boolean?])
         terminal-node?]{
}

@;{============================================================================}
@subsection[]{Classification}

@defproc[(tree-classify
           [tree decision-tree?]
           [individual individual?])
         serializable?]{
}

@defproc[(tree-trace
           [tree decision-tree?])
         (listof string?)]{
}

@defthing[drop-through-error terminal-node?]{
}

@defparam[sandbox-predicates sandbox-enable boolean? #:value #t]{
}
