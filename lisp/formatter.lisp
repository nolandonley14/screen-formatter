#!/usr/local/bin/sbcl --script
; this is a lisp file
;;; Want to avoid compiler warnings, so add defvar for these variables

; Screen Formatter in Ada
; Nolan Donley
; Input: any text file
; Output: text file formatter to maximum 60 chars per Line
;      and also the line with most and least words
;
; To compile and run:
;  sbcl --script formatter.lisp {absolute path}

(setq *print-pretty* 'nil)
(defvar fl "") ; file object
(defvar fileName (cadr *posix-argv*)) ; file name
(defvar line) ; line of input
(defparameter numlines 2) ; number of lines
(defvar listofstrings nil) ; line of input
(defvar numchars 0) ; number of characters in output
(defvar listofwords) ; list of tokenized words
(defvar buffer) ; buffer to output
(defvar tmp "") ; temp string to compare for longest and shortest lines
(defvar shortest "") ; shortest line
(defvar longest "") ; longest line
(defvar shortline 1) ; shortest line's line number
(defvar longline 1) ; longest line's line number
(defvar numWords 0) ; number of words in tmp
(defvar shortlineWordCount 0) ; number of words in shortest line
(defvar longlineWordCount 0) ; number of words in longest line

;; macro to concatenate n-number of strings together
(defmacro concatenatef (s &rest strs)
  "Append additional strings to the first string in-place."
  `(setf ,s (concatenate 'string ,s ,@strs)))

  (defun split-str (string &optional (separator " "))
    (split-1 string separator))

  (defun split-1 (string &optional (separator " ") (r nil))
    (let ((n (position separator string
  		     :from-end t
  		     :test #'(lambda (x y)
  			       (find y x :test #'string=)))))
      (if n
  	(split-1 (subseq string 0 n) separator (cons (subseq string (1+ n)) r))
        (cons string r))))

;; function to read the file into line
(defun read-file (filename)
  (with-open-file (stream filename)
    (loop for line = (read-line stream nil)
          while line
          collect line)))

;; main method
(defun mainmethod()
    (if (> (length fileName) 0)
      (setf fl fileName)
      (progn
        (format t "Please enter the absolute path of a text file to format as the last command line argument.~%~%")
        (exit)
      ))
    (format t "~%~8d  " 1)
    ;; read file into listofwords
    (setq listofwords (read-file fl))
    ;; for each word in listofwords, remove any numbers or newlines, then conditionally output the word
    (dolist (word listofwords)
      (setq word (string-trim '(#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9 #\Return) word))
      (newoutput word) (updateminmax tmp numlines numWords))
)

;; output each list of words one word at a time until 60 chars, then enter a new line
(defun newoutput(wordlist)
  (setf buffer (split-str wordlist))
  (dolist (word buffer)
    (if (and (>= (length word) 1) (not (equal (char word 0) #\Space)))
    (if (<= (+ numchars (length word)) 60)
      (progn
         (concatenatef tmp word " ")
         (incf numWords)
         (if (< (+ numchars (length word)) 60)
          (progn (format t "~a " word) (incf numchars) )
          (format t "~a" word))
          (setf numchars (+ numchars (length word)))
      )
      (progn
          (updateminmax tmp numlines numWords)
          (setf tmp "")
          (setf numWords 0)
          (concatenatef tmp word " ")
          (format t "~%~8d  ~a " numlines word)
          (setf numchars (length word)) (incf numchars) (incf numlines)))))
)

;; update the minimum and maximum lines and their line numbers
(defun updateminmax(sentence num numWords)
  (if (<= numWords shortlineWordCount)
    (progn
      (setq shortest sentence)
      (setf shortline (- num 1))
      (setf shortlineWordCount numWords)
    ))
  (if (>= numWords longlineWordCount)
    (progn
      (setq longest sentence)
      (setf longline (- num 1))
      (setf longlineWordCount numWords)
    ))
  (if (= numlines 2)
    (progn
      (setq shortest sentence)
      (setf shortlineWordCount numWords)
    ))
)

;; run the main method and then print out the longest and shortest lines
(mainmethod)
(format t "~2%LONG~7t~d~19t~a" longline longest)
(format t "~%SHORT~7t~d~19t~a~2%" shortline shortest)
;(format t "~%Number of lines: ~8a ~%~%" (- numlines 1))
