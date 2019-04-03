#lang racket/base
(require rackunit/text-ui)
(require rackunit "./cuid.rkt")

(define cuid-tests
  (test-suite
   "Tests for cuid.rkt"

   (test-case
    "Creates a valid cuid"
    (for ([i (in-range 10000)])
      (check-not-false (cuid? (cuid)))))

   (test-case
    "Creates a valid slug"
      (for ([i (in-range 10000)])
      (check-not-false (slug? (slug)))))
   ))

(run-tests cuid-tests)
