#|--------------------------------- * 
|     OM-Data library functions     |
|   [www.felipe-tovar-henao.com]    |
|               2021                |
* --------------------------------- *
|#

(in-package :om)

; --------------- string-rewrite ---------------
(defun string-rewrite (axiom rules iterations)
    (setq axiom (flat (list axiom) 1))
    (loop for n from 0 to (- iterations 1) do
        (loop for a in axiom and i from 0 to (- (length axiom) 1) do
            (loop for r in rules do
                (if (equal a (first r))
                    (progn
                        (setf (nth i axiom) (second r))))))
        (setq axiom (flat axiom 1)))
    axiom)

; --------------- L-system ---------------
(defmethod! L-system ((axiom number) (rules list) (generations integer))
    :initvals '('(x f) '((x (x + y f + + y f - f x - - f x f x - y f +)) (y (- f x + y f y f + + y f + f x - - f x - y))) 3)
    :indoc '("atom" "list" "integer")
    :icon 000
    :doc "Outputs a deterministically generated sequence of elements, given an axiom, a list of production rules, and a number of generations." 
    (string-rewrite axiom rules generations))

(defmethod! L-system ((axiom string) (rules list) (generations integer))
    (string-rewrite axiom rules generations))

(defmethod! L-system ((axiom list) (rules list) (generations integer))
    (string-rewrite axiom rules generations))

; --------------- 2D-Turtle ---------------
(defmethod! 2D-Turtle ((lsys list) (mag-rules list) (theta-rules list) (memory-rules list) &optional (theta 0))
    :initvals '(([ f - f ] + f [ f - f ] + f [ f - f ] + f [ f - f ] + f [ f - f ] + f [ f - f ] + f) '((f 1)) '((+ 60) (- -60)) '(([ 1) (] 0)) 0)
    :indoc '("list" "list" "list" "list" "number")
    :icon 000
    :doc "2D Turtle graphics"
    (setq x 0)
    (setq y 0)
    (setq mag 0)
    (setq memory nil)
    (setq out (list (om-make-point x y)))
    (loop for s in lsys do
        (loop for mr in mag-rules do
            (if (equal s (first mr))
                (progn
                    (setq mag (second mr))
                    (setq x (+ x (* mag (cos (deg->rad theta)))))
                    (setq y (+ y (* mag (sin (deg->rad theta)))))
                    (setq out (append out (list (om-make-point x y)))))))
        (loop for tr in theta-rules do
            (if (equal s (first tr))
                (progn
                    (setq theta (+ theta (second tr))))))
        (loop for mr in memory-rules do
            (if (equal s (first mr))
                (progn 
                    (if (equal (second mr) 1)
                        (setq memory (append memory (list (list x y theta mag))))
                    )
                    (if (equal (second mr) 0)
                        (progn
                            (setq state (car (last memory)))
                            (setq x (first state))
                            (setq y (second state))
                            (setq theta (third state))
                            (setq mag (fourth state))
                            (setq memory (butlast memory))))))))
    (make-instance 'bpc :point-list out))

;--------------- Make-sieve ---------------
(defmethod! Make-sieve ((list list) (reps integer) sieve-mode sieve-type &optional (offset '0))
    :initvals '((2 3) 1 'union 'nil 0)
    :indoc '("list" "integer" "menu" "menu" "number")
    :menuins '(
        (2 (("union" 'union) ("diff" 'diff)))
        (3 (("nil" 'nil) ("complement" 'complement))))
    :icon 000
    :doc "Builds N full periods of a sieve, based on a list of integers. Make-sieve is meant to be a compact version of OM's native CRIBLE class and functions"
    (setq list (remove 0 list))
    (setq period (+ offset (* reps (list-lcm list))))
    (setq sieves (loop for l in list collect
        (arithm-ser offset period l)))
    (cond
        (
            (equal sieve-mode 'union)
            (setq out (list-union sieves)))
        (
            (equal sieve-mode 'diff)
            (setq out (list-diff sieves))))
    (if (equal sieve-type 'complement)
        (setq out (list-diff (list (arithm-ser offset period 1) (flat (list out))))))
    (stable-sort out #'<))

(defun list-union (list)
    (setq out (car list))
    (loop for l in (cdr list) do
        (setq out (x-union out l)))
    out)

(defun list-intersect (list)
    (setq out (car list))
    (loop for l in (cdr list) do
        (setq out (x-intersect out l)))
    out)

(defun list-diff (list)
    (setq out (car list))
    (loop for l in (cdr list) do
        (setq out (x-diff out l)))
    out)

(defun list-lcm (list)
    (setq out (car list))
    (loop for l in (cdr list) do
        (setq out (lcm out l)))
    out)

(defun list-gcd (list)
    (setq out (car list))
    (loop for l in (cdr list) do
        (setq out (gcd out l)))
    out)

;--------------- Vieru-sequence ---------------
(defmethod! Vieru-seq ((seq list) (n-tiers integer))
    :initvals '((4 1 2 1 4) 1)
    :indoc '("list" "integer" "integer")
    :icon 000
    :doc "Takes the ascending modular differences between adjacent values. Based on Anatol Vieru's modal sequences.

    Examples:
    (vieru-seq '(4 1 2 1 4) 1) => ((9 1 11 3 0))
    (vieru-seq '(2 1 4 1 2) 3) => ((9 3 7 1 0) (4 4 4 9 9) (0 0 5 0 5))
    "
    (setq mod-n (reduce #'+ seq))
    (setq seq (nth-value 1 (om// (append seq (list (car seq))) mod-n)))
    (setq out nil)
    (loop for x from 1 to n-tiers do
        (setq diff-seq nil)
        (loop for i from 0 to (- (length seq) 2) do
            (setq current (nth i seq))
            (setq next (nth (+ i 1) seq))
            (if (>= next current)
                (setq val (abs (- next current)))
                (setq val (abs (- (+ next mod-n) current))))
            (setq diff-seq (append diff-seq (list val))))
        (setq out (append out (list diff-seq)))
        (setq seq (append diff-seq (list (car diff-seq)))))
    out)