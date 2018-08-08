# Racket Machine Learning - Decision Trees

[![GitHub release](https://img.shields.io/github/release/johnstonskj/rml-decisiontrees.svg?style=flat-square)](https://github.com/johnstonskj/rml-decisiontrees/releases)
[![Travis Status](https://travis-ci.org/johnstonskj/rml-decisiontrees.svg)](https://www.travis-ci.org/johnstonskj/rml-decisiontrees)
[![Coverage Status](https://coveralls.io/repos/github/johnstonskj/rml-decisiontrees/badge.svg?branch=master)](https://coveralls.io/github/johnstonskj/rml-decisiontrees?branch=master)
[![raco pkg install rml-core](https://img.shields.io/badge/raco%20pkg%20install-rml--decisiontrees-blue.svg)](http://pkgs.racket-lang.org/package/rml-decisiontrees)
[![Documentation](https://img.shields.io/badge/raco%20docs-rml--decisiontrees-blue.svg)](http://docs.racket-lang.org/rml-decisiontrees/index.html)
[![GitHub stars](https://img.shields.io/github/stars/johnstonskj/rml-core.svg)](https://github.com/johnstonskj/rml-core/stargazers)
![MIT License](https://img.shields.io/badge/license-MIT-118811.svg)

This Package is part of a set of packages implementing machine learning capabilities for Racket.
This particular package implements support for classification of individuals using decision trees.

# Modules

* Support for classifying an individual against a known tree.

# Examples

```scheme
(require rml/individual
         rml-decision-trees)

(define test-tree
 (make-decision-tree
   (make-decision
    "size"
    (list [cons (curryr < 5) (make-terminal 'small)]
          [cons (curryr > 10) (make-terminal 'large)])
    #:else (make-decision
            "color"
            (list [cons (curry string=? "black") (make-terminal 'cocktail)])
                  #:else (make-terminal 'medium)))))

(define test-individual (make-hash (list (cons "size" 3) (cons "color" "black"))))

(tree-classify test-tree test-individual)
```

[![Racket Langaueg](https://racket-lang.org/logo-and-text-1-2.png)](https://racket-lang.org/)
