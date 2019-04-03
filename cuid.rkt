#lang racket/base

;
; A `cuid` is a secure, portable, and sequentially-ordered identifier
; designed for horizontal scalability and speed -- the reference
; implementation is in Javascript at https://github.com/ericelliott/cuid
;"""
(require racket/random)
(require math/base)
(require racket/os)
(require racket/generator)

; CONSTANTS
; ---------
(define base 36)
(define block 4)
(define discreteValues (expt 36 4))
(define prefix "c")
(define padding "000000000")

; HELPERS
; -------

; 'Pad' a string with leading zeroes to fit the given size, truncating
;  if necessary.
(define (pad s n)
  (let* ([padded (string-append padding s)]
        [len (string-length padded)])
    (substring padded (- len n) len)))

(define (padded-block b)
  (pad (base36-encode b) block))

; Convert a number to string with the specified radix
(define (num->str n radix)
  (let loop ([n n] [digits '()])
    (define-values [n1 d] (quotient/remainder n radix))
    (define digits1 (cons (integer->char (+ d (if (< d 10) 48 55))) digits))
    (if (zero? n) (list->string digits1) (loop n1 digits1))))

; Convert a number to base36 string
(define (base36-encode n)
  (num->str n base))

; Get the current timestamp
(define (timestamp)
  (padded-block (current-milliseconds)))

; Extract a unique fingerprint for the current process, using a
; combination of the process PID and the system's hostname.
(define (host-info)
  (let ([paddedPid (pad (base36-encode (getpid)) 2)]
        [paddedHost (pad (base36-encode (hash (gethostname))) 2)])
    (string-append paddedPid paddedHost)))

; Get a random unsigned int number
(define (random-number)
  (integer-bytes->integer (crypto-random-bytes 4) #f #t))

(define (random-discrete-number)
  (modulo (random-number) discreteValues))

(define (random-block)
  (padded-block (random-discrete-number)))

(define (padded-counter)
  (padded-block (counter)))

; Rolling counter that ensures same-machine and same-time
; cuids don't collide.
(define counter
  (sequence->generator
   (in-cycle (in-range discreteValues))))

(define (hash item)
  (let* ([len (string-length item)]
        [h (+ (for/sum ([s (map char->integer (string->list item))]) s)
               len
               base)]) h))

; PUBLIC API
; -------

(define (cuid)
  (string-append
   prefix              ; Prefix
   (timestamp)         ; Timestamp
   (padded-counter)    ; Counter
   (host-info)         ; Host information
   (random-block)      ; Random block
   (random-block)))    ; Random block

; Check if string is a cuid
(define (cuid? c)
  (if (and (string? c) (string=? (substring c 0 1) prefix))
      #t
      #f))

; Generate a short (10-character) cuid as a string.
(define (slug)
  (let* ([pt (base36-encode (current-milliseconds))]
        [len-pt (string-length pt)]
        [h (host-info)]
        [len-h (string-length h)]
        [r (random-block)]
        [len-r (string-length r)])
    (string-append
     (substring pt (- len-pt 2) len-pt)
     (pad (base36-encode (counter)) 4)
     (substring h 1 2)
     (substring h (- len-h 1) len-h)
     (substring r (- len-r 2) len-r)
    )))


; Check if string is a slug
(define (slug? s)
  (if (and (string? s) (eq? (string-length s) 10))
      #t
      #f))

(provide slug slug? cuid cuid?)