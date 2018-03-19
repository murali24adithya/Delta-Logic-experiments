(declare-sort Loc)
;Sets
(define-sort Set (T) (Array T Bool))

(declare-const empInt (Set Int))
(assert (= empInt ((as const (Set Int)) false)))

(declare-const empLoc (Set Loc))
(assert (= empLoc ((as const (Set Loc)) false)))

;; Multisets
(define-sort MultiSet (T) (Array T Int))

(define-fun mult-union ((first (MultiSet Int)) 
  (second (MultiSet Int)) ) (MultiSet Int)
  ((_ map (+ (Int Int) Int)) first second)
  )
(define-fun mult-store ((original (MultiSet Int))
(key Int) (value Int))	(MultiSet Int)
 (store original key (+ (select original key) value))
)
(declare-const mult-empInt (MultiSet Int))
(assert (= mult-empInt ((as const (MultiSet Int)) 0)) )

;;-----------------------------------------------------------
(declare-const n (Array Loc Loc))
(declare-const n2 (Array Loc Loc))
(declare-fun t (Loc) Loc )
(declare-fun key (Loc) Int )
(declare-fun ls (Loc Loc) Bool )
(declare-fun ls2 (Loc Loc) Bool )
(declare-fun hls (Loc Loc) (Set Loc) )
(declare-fun hls2 (Loc Loc) (Set Loc) )
(declare-fun mkeys (Loc Loc) (MultiSet Int) )
(declare-fun mkeys2 (Loc Loc) (MultiSet Int) )
(declare-fun lslen (Loc Loc) Int)
(declare-fun ls2len (Loc Loc) Int)
(declare-fun sorted (Loc Loc) Bool)
(declare-fun sorted2 (Loc Loc) Bool)
(declare-fun revsorted (Loc Loc) Bool)
(declare-fun revsorted2 (Loc Loc) Bool)
(declare-fun minls (Loc Loc) Int)
(declare-fun minls2 (Loc Loc) Int)
(declare-fun maxls (Loc Loc) Int)
(declare-fun maxls2 (Loc Loc) Int)
(declare-fun d (Loc Loc) Int)
(declare-fun d2 (Loc Loc) Int)
(declare-fun hlist_measure (Loc) (Set Loc) )
(declare-fun length_measure (Loc) Int )
(declare-fun max_measure (Loc) Int )
(declare-fun min_measure (Loc) Int )
(declare-fun sorted_measure (Loc) Bool )
(declare-fun revsorted_measure (Loc) Bool )
(define-fun circ_ls ((front Loc) (back Loc)) Bool
(and (ls front back) (= (select n back) front))
)
(define-fun circ_ls2 ((front Loc) (back Loc)) Bool
(and (ls2 front back) (= (select n2 back) front))
)
;;-----------------------------------------------------------
(define-fun hls_separate ((first Loc) (second Loc)) Bool
(=> (not (= first second)) 
   (= (intersect (hlist_measure first ) 
                 (hlist_measure second ) 
	  ) 
   empLoc)
))

;;-----------------------------------------------------------
(define-fun minInt ((first Int) (second Int)) Int
(ite (< first second) first second)
)
(define-fun maxInt ((first Int) (second Int)) Int
(ite (> first second) first second)
)
;;-----------------------------------------------------------


;;-----------------------------------------------------------
(define-fun t_structure_for_sorted_measure ((w Loc)) Bool
(=> (or (= (min_measure w) (max_measure w)) (= (length_measure w ) 1)) 
    (and 
	  (sorted_measure w )
	  (revsorted_measure w )
)))

;;-----------------------------------------------------------
;;nil node
(declare-const nil Loc)
(assert (= (key nil) -1))
;next node for nil defined in base
(assert (= (t nil) nil) )

;;-----------------------------------------------------------
(declare-const inDelta (Set Loc) )
(declare-const inVariables (Set Loc) )

;;------------------------------------------------------------------
;;Closed system assumptions and range restrictions for t
(define-fun closed-sys ((w Loc)) Bool
  (or (select inVariables w) (select inDelta w)) )

;;------------------------------------------------------------------

(define-fun base ((end Loc)) Bool
(and 
(= (select n nil) nil) 
(ls end end)
(= (hls end end) empLoc ) 
(= (d end end) 0) 
(= (mkeys end end) mult-empInt)
(= (lslen end end) 0)
(= (sorted end end) true) 
(= (revsorted end end) true) 
))
(define-fun base2 ((end Loc)) Bool
(and 
(= (select n2 nil) nil) 
(ls2 end end)
(= (hls2 end end) empLoc ) 
(= (d2 end end) 0) 
(= (mkeys2 end end) mult-empInt)
(= (ls2len end end) 0)
(= (sorted2 end end) true)
(= (revsorted2 end end) true)
))
;;------------------------------------------------------------------

(define-fun n_propagate ((w Loc) (end Loc)) Bool
  (=> (not (= w end) )
  (and
    ;;true case
      (=> (ls (select n w) end)
        (and (ls w end)
        (> (d w end) (d (select n w) end)) 
        (= (hls w end) 
			 (store (hls (select n w) end) w true) )
        (= (mkeys w end) 
                (store (mkeys (select n w) end) 
				(key w) 
				(+ (select (mkeys (select n w) end) (key w)) 1)) )
        (= (lslen w end) (+ (lslen (select n w) end) 1) )
		(= (minls w end) 
		     (ite (= (select n w) end)  
			   (key w)
			   (minInt (key w) (minls (select n w) end))))
        (= (maxls w end) 
		     (ite (= (select n w) end)  
			   (key w)
			   (maxInt (key w) (maxls (select n w) end))))		
		(iff (sorted w end)
		     (and (=> (not (= (select n w) end)) (<= (key w) (key (select n w))))
	              (sorted (select n w) end) ))
        (iff (revsorted w end)
		     (and (=> (not (= (select n w) end)) (>= (key w) (key (select n w))))
	              (revsorted (select n w) end) ))
	))
    ;;false case
      (=> (not (ls (select n w) end))
        (and (not (ls w end))
             (= (hls w end) empLoc)
             (= (mkeys w end) mult-empInt)
             (= (lslen w end) -1)
		     (not (sorted w end))
             (not (revsorted w end))
    ))
  )))

(define-fun n2_propagate ((w Loc) (end Loc)) Bool
  (=> (not (= w end) )
  (and
    ;;true case
      (=> (ls2 (select n2 w) end)
        (and (ls2 w end)
        (> (d2 w end) (d2 (select n2 w) end)) 
        (= (hls2 w end) 
			 (store (hls2 (select n2 w) end) w true) )
        (= (mkeys2 w end) 
                (store (mkeys2 (select n2 w) end) 
				(key w) 
				(+ (select (mkeys2 (select n2 w) end) (key w)) 1)) )
        (= (ls2len w end) (+ (ls2len (select n2 w) end) 1) )
		(= (minls2 w end) 
		     (ite (= (select n2 w) end)  
			   (key w)
			   (minInt (key w) (minls2 (select n2 w) end)))) 
		(= (maxls2 w end) 
		     (ite (= (select n2 w) end)  
			   (key w)
			   (maxInt (key w) (maxls2 (select n2 w) end))))
        (iff (sorted2 w end)
		     (and (=> (not (= (select n2 w) end)) (<= (key w) (key (select n2 w))))
	              (sorted2 (select n2 w) end) ))
        (iff (revsorted2 w end)
		     (and (=> (not (= (select n2 w) end)) (>= (key w) (key (select n2 w))))
	              (revsorted2 (select n2 w) end) ))
	))
    ;;false case
      (=> (not (ls2 (select n2 w) end))
        (and (not (ls2 w end))
             (= (hls2 w end) empLoc)
             (= (mkeys2 w end) mult-empInt)
             (= (ls2len w end) -1)
		     (not (sorted2 w end))
             (not (revsorted2 w end))
    ))
  )))
  
;;------------------------------------------------------------------

(define-fun t_propagate ((w Loc) (end Loc)) Bool
  (=> (and (not ( select inDelta w)) (not (= w end)) )
  (and
  ;;true case 
  (=> (ls (t w) end) 
    (and (ls w end)
    (> (d w end) (d (t w) end)) 
    (= (hls w end) 
	        (union 
		      (store (hlist_measure w ) w true ) 
			  (hls (t w) end)) )
    (= (lslen w end) 
	   (+ (+ (length_measure w ) (lslen (t w) end)) 1) )
	(= (minls w end) (minInt (key w) 
		     (ite (= (t w) end)  
			   (min_measure w )
			   (minInt (min_measure w ) (minls (t w) end)))))
    (= (maxls w end) (maxInt (key w) 
		     (ite (= (t w) end)  
			   (max_measure w )
			   (maxInt (max_measure w ) (maxls (t w) end)))))
    (iff (sorted w end)
		    (and (<= (key w) (min_measure w ))
                 (sorted_measure w )
                 (=> (not (= (t w) end)) (<= (max_measure w ) (key (t w))))
                 (sorted (t w) end) )) 				 
    (iff (revsorted w end)
		    (and (>= (key w) (max_measure w ))
                 (revsorted_measure w )
                 (=> (not (= (t w) end)) (>= (min_measure w ) (key (t w))))
                 (revsorted (t w) end) )) 				 
  ))
  ;;false case
    (=> (not (ls (t w) end)) 
      (and (not (ls w end))
           (= (hls w end) empLoc)
           (= (mkeys w end) mult-empInt)
           (= (lslen w end) -1)
	       (not (sorted w end))
           (not (revsorted w end))
    ))
  )))
  
(define-fun t_propagate2 ((w Loc) (end Loc)) Bool
  (=> (and (not ( select inDelta w)) (not (= w end)) )
  (and
  ;;true case 
  (=> (ls2 (t w) end) 
    (and (ls2 w end)
    (> (d2 w end) (d2 (t w) end)) 
    (= (hls2 w end) 
	        (union 
		      (store (hlist_measure w ) w true ) 
			  (hls2 (t w) end)) )
    (= (ls2len w end) 
	   (+ (+ (length_measure w ) (ls2len (t w) end)) 1) )
	(= (minls2 w end) (minInt (key w) 
		     (ite (= (t w) end)  
			   (min_measure w )
			   (minInt (min_measure w ) (minls2 (t w) end)))))
    (= (maxls2 w end) (maxInt (key w) 
		     (ite (= (t w) end)  
			   (max_measure w )
			   (maxInt (max_measure w ) (maxls2 (t w) end)))))
    (iff (sorted2 w end)
		    (and (<= (key w) (min_measure w ))
                 (sorted_measure w )
                 (=> (not (= (t w) end)) (<= (max_measure w ) (key (t w))))
                 (sorted2 (t w) end) )) 				 	   
    (iff (revsorted2 w end)
		    (and (>= (key w) (max_measure w ))
                 (revsorted_measure w )
                 (=> (not (= (t w) end)) (>= (min_measure w ) (key (t w))))
                 (revsorted2 (t w) end) )) 				 	   
  ))
  ;;false case
    (=> (not (ls2 (t w) end)) 
      (and (not (ls2 w end))
           (= (hls2 w end) empLoc)
           (= (mkeys2 w end) mult-empInt)
           (= (ls2len w end) -1)
	       (not (sorted2 w end))
           (not (revsorted2 w end))
    ))
  )))

;;------------------------------------------------------------------
;;------------------------------------------------------------------

(declare-const key1 Int)
(declare-const num_key1@v1seg Int)
(assert (>= num_key1@v1seg 0))
(declare-const num_key1@v2seg Int)
(assert (>= num_key1@v2seg 0))
(declare-const num_key1@v3seg Int)
(assert (>= num_key1@v3seg 0))
(declare-const num_key1@v4seg Int)
(assert (>= num_key1@v4seg 0))
(declare-const num_key1@v5seg Int)
(assert (>= num_key1@v5seg 0))
(declare-const key2 Int)
(declare-const num_key2@v1seg Int)
(assert (>= num_key2@v1seg 0))
(declare-const num_key2@v2seg Int)
(assert (>= num_key2@v2seg 0))
(declare-const num_key2@v3seg Int)
(assert (>= num_key2@v3seg 0))
(declare-const num_key2@v4seg Int)
(assert (>= num_key2@v4seg 0))
(declare-const num_key2@v5seg Int)
(assert (>= num_key2@v5seg 0))
(declare-const key3 Int)
(declare-const num_key3@v1seg Int)
(assert (>= num_key3@v1seg 0))
(declare-const num_key3@v2seg Int)
(assert (>= num_key3@v2seg 0))
(declare-const num_key3@v3seg Int)
(assert (>= num_key3@v3seg 0))
(declare-const num_key3@v4seg Int)
(assert (>= num_key3@v4seg 0))
(declare-const num_key3@v5seg Int)
(assert (>= num_key3@v5seg 0))
(declare-const key4 Int)
(declare-const num_key4@v1seg Int)
(assert (>= num_key4@v1seg 0))
(declare-const num_key4@v2seg Int)
(assert (>= num_key4@v2seg 0))
(declare-const num_key4@v3seg Int)
(assert (>= num_key4@v3seg 0))
(declare-const num_key4@v4seg Int)
(assert (>= num_key4@v4seg 0))
(declare-const num_key4@v5seg Int)
(assert (>= num_key4@v5seg 0))
(declare-const key5 Int)
(declare-const num_key5@v1seg Int)
(assert (>= num_key5@v1seg 0))
(declare-const num_key5@v2seg Int)
(assert (>= num_key5@v2seg 0))
(declare-const num_key5@v3seg Int)
(assert (>= num_key5@v3seg 0))
(declare-const num_key5@v4seg Int)
(assert (>= num_key5@v4seg 0))
(declare-const num_key5@v5seg Int)
(assert (>= num_key5@v5seg 0))
(declare-const key6 Int)
(declare-const num_key6@v1seg Int)
(assert (>= num_key6@v1seg 0))
(declare-const num_key6@v2seg Int)
(assert (>= num_key6@v2seg 0))
(declare-const num_key6@v3seg Int)
(assert (>= num_key6@v3seg 0))
(declare-const num_key6@v4seg Int)
(assert (>= num_key6@v4seg 0))
(declare-const num_key6@v5seg Int)
(assert (>= num_key6@v5seg 0))
(declare-const key7 Int)
(declare-const num_key7@v1seg Int)
(assert (>= num_key7@v1seg 0))
(declare-const num_key7@v2seg Int)
(assert (>= num_key7@v2seg 0))
(declare-const num_key7@v3seg Int)
(assert (>= num_key7@v3seg 0))
(declare-const num_key7@v4seg Int)
(assert (>= num_key7@v4seg 0))
(declare-const num_key7@v5seg Int)
(assert (>= num_key7@v5seg 0))

(define-fun inKeys ((key Int)) Bool
(or
(= key key1)
(= key key2)
(= key key3)
(= key key4)
(= key key5)
(= key key6)
(= key key7)
))

(declare-const v1 Loc)
(declare-const v2 Loc)
(declare-const v3 Loc)
(declare-const v4 Loc)
(declare-const v5 Loc)

(assert (= inVariables
(store (store (store (store (store empLoc
v1 true)
v2 true)
v3 true)
v4 true)
v5 true)
))

(assert (not (select inDelta v1)))
(assert (not (select inDelta v2)))
(assert (not (select inDelta v3)))
(assert (not (select inDelta v4)))
(assert (not (select inDelta v5)))

(assert (closed-sys (t v1)) )
(assert (closed-sys (t v2)) )
(assert (closed-sys (t v3)) )
(assert (closed-sys (t v4)) )
(assert (closed-sys (t v5)) )

(define-fun t-structure-for-hls ((w Loc)) Bool
(and (not (select (hlist_measure v1 ) w ))
(and (not (select (hlist_measure v2 ) w ))
(and (not (select (hlist_measure v3 ) w ))
(and (not (select (hlist_measure v4 ) w ))
(and (not (select (hlist_measure v5 ) w ))
))))))
(assert (t-structure-for-hls v1) )
(assert (t-structure-for-hls v2) )
(assert (t-structure-for-hls v3) )
(assert (t-structure-for-hls v4) )
(assert (t-structure-for-hls v5) )

(assert (t_structure_for_sorted_measure v1))
(assert (t_structure_for_sorted_measure v2))
(assert (t_structure_for_sorted_measure v3))
(assert (t_structure_for_sorted_measure v4))
(assert (t_structure_for_sorted_measure v5))

(assert (hls_separate v1 v2))
(assert (hls_separate v1 v3))
(assert (hls_separate v1 v4))
(assert (hls_separate v1 v5))
(assert (hls_separate v2 v3))
(assert (hls_separate v2 v4))
(assert (hls_separate v2 v5))
(assert (hls_separate v3 v4))
(assert (hls_separate v3 v5))
(assert (hls_separate v4 v5))

(assert (=> (= (hlist_measure v1) empLoc) (= (length_measure v1) 0)))
(assert (=> (= (hlist_measure v2) empLoc) (= (length_measure v2) 0)))
(assert (=> (= (hlist_measure v3) empLoc) (= (length_measure v3) 0)))
(assert (=> (= (hlist_measure v4) empLoc) (= (length_measure v4) 0)))
(assert (=> (= (hlist_measure v5) empLoc) (= (length_measure v5) 0)))

(assert (<= (min_measure v1) key1))
(assert (<= (min_measure v1) key2))
(assert (<= (min_measure v1) key3))
(assert (<= (min_measure v1) key4))
(assert (<= (min_measure v1) key5))
(assert (<= (min_measure v1) key6))
(assert (<= (min_measure v1) key7))
(assert (>= (max_measure v1) key1))
(assert (>= (max_measure v1) key2))
(assert (>= (max_measure v1) key3))
(assert (>= (max_measure v1) key4))
(assert (>= (max_measure v1) key5))
(assert (>= (max_measure v1) key6))
(assert (>= (max_measure v1) key7))
(assert (<= (min_measure v2) key1))
(assert (<= (min_measure v2) key2))
(assert (<= (min_measure v2) key3))
(assert (<= (min_measure v2) key4))
(assert (<= (min_measure v2) key5))
(assert (<= (min_measure v2) key6))
(assert (<= (min_measure v2) key7))
(assert (>= (max_measure v2) key1))
(assert (>= (max_measure v2) key2))
(assert (>= (max_measure v2) key3))
(assert (>= (max_measure v2) key4))
(assert (>= (max_measure v2) key5))
(assert (>= (max_measure v2) key6))
(assert (>= (max_measure v2) key7))
(assert (<= (min_measure v3) key1))
(assert (<= (min_measure v3) key2))
(assert (<= (min_measure v3) key3))
(assert (<= (min_measure v3) key4))
(assert (<= (min_measure v3) key5))
(assert (<= (min_measure v3) key6))
(assert (<= (min_measure v3) key7))
(assert (>= (max_measure v3) key1))
(assert (>= (max_measure v3) key2))
(assert (>= (max_measure v3) key3))
(assert (>= (max_measure v3) key4))
(assert (>= (max_measure v3) key5))
(assert (>= (max_measure v3) key6))
(assert (>= (max_measure v3) key7))
(assert (<= (min_measure v4) key1))
(assert (<= (min_measure v4) key2))
(assert (<= (min_measure v4) key3))
(assert (<= (min_measure v4) key4))
(assert (<= (min_measure v4) key5))
(assert (<= (min_measure v4) key6))
(assert (<= (min_measure v4) key7))
(assert (>= (max_measure v4) key1))
(assert (>= (max_measure v4) key2))
(assert (>= (max_measure v4) key3))
(assert (>= (max_measure v4) key4))
(assert (>= (max_measure v4) key5))
(assert (>= (max_measure v4) key6))
(assert (>= (max_measure v4) key7))
(assert (<= (min_measure v5) key1))
(assert (<= (min_measure v5) key2))
(assert (<= (min_measure v5) key3))
(assert (<= (min_measure v5) key4))
(assert (<= (min_measure v5) key5))
(assert (<= (min_measure v5) key6))
(assert (<= (min_measure v5) key7))
(assert (>= (max_measure v5) key1))
(assert (>= (max_measure v5) key2))
(assert (>= (max_measure v5) key3))
(assert (>= (max_measure v5) key4))
(assert (>= (max_measure v5) key5))
(assert (>= (max_measure v5) key6))
(assert (>= (max_measure v5) key7))

(define-fun mkeys_propagate_for_vars ((end Loc)) Bool
(and
(=> (and (ls (t v1) end) (not (select inDelta v1)) (not (= v1 end)))(= (mkeys v1 end)
(mult-union
(mult-store (mult-store (mult-store (mult-store (mult-store (mult-store (mult-store (mult-store mult-empInt
(key v1) 1)
key1 num_key1@v1seg)
key2 num_key2@v1seg)
key3 num_key3@v1seg)
key4 num_key4@v1seg)
key5 num_key5@v1seg)
key6 num_key6@v1seg)
key7 num_key7@v1seg)
(mkeys (t v1) end) )))

(=> (and (ls (t v2) end) (not (select inDelta v2)) (not (= v2 end)))(= (mkeys v2 end)
(mult-union
(mult-store (mult-store (mult-store (mult-store (mult-store (mult-store (mult-store (mult-store mult-empInt
(key v2) 1)
key1 num_key1@v2seg)
key2 num_key2@v2seg)
key3 num_key3@v2seg)
key4 num_key4@v2seg)
key5 num_key5@v2seg)
key6 num_key6@v2seg)
key7 num_key7@v2seg)
(mkeys (t v2) end) )))

(=> (and (ls (t v3) end) (not (select inDelta v3)) (not (= v3 end)))(= (mkeys v3 end)
(mult-union
(mult-store (mult-store (mult-store (mult-store (mult-store (mult-store (mult-store (mult-store mult-empInt
(key v3) 1)
key1 num_key1@v3seg)
key2 num_key2@v3seg)
key3 num_key3@v3seg)
key4 num_key4@v3seg)
key5 num_key5@v3seg)
key6 num_key6@v3seg)
key7 num_key7@v3seg)
(mkeys (t v3) end) )))

(=> (and (ls (t v4) end) (not (select inDelta v4)) (not (= v4 end)))(= (mkeys v4 end)
(mult-union
(mult-store (mult-store (mult-store (mult-store (mult-store (mult-store (mult-store (mult-store mult-empInt
(key v4) 1)
key1 num_key1@v4seg)
key2 num_key2@v4seg)
key3 num_key3@v4seg)
key4 num_key4@v4seg)
key5 num_key5@v4seg)
key6 num_key6@v4seg)
key7 num_key7@v4seg)
(mkeys (t v4) end) )))

(=> (and (ls (t v5) end) (not (select inDelta v5)) (not (= v5 end)))(= (mkeys v5 end)
(mult-union
(mult-store (mult-store (mult-store (mult-store (mult-store (mult-store (mult-store (mult-store mult-empInt
(key v5) 1)
key1 num_key1@v5seg)
key2 num_key2@v5seg)
key3 num_key3@v5seg)
key4 num_key4@v5seg)
key5 num_key5@v5seg)
key6 num_key6@v5seg)
key7 num_key7@v5seg)
(mkeys (t v5) end) )))

))
(define-fun mkeys2_propagate_for_vars ((end Loc)) Bool
(and
(=> (and (ls2 (t v1) end) (not (select inDelta v1)) (not (= v1 end)))(= (mkeys2 v1 end)
(mult-union
(mult-store (mult-store (mult-store (mult-store (mult-store (mult-store (mult-store (mult-store mult-empInt
(key v1) 1)
key1 num_key1@v1seg)
key2 num_key2@v1seg)
key3 num_key3@v1seg)
key4 num_key4@v1seg)
key5 num_key5@v1seg)
key6 num_key6@v1seg)
key7 num_key7@v1seg)
(mkeys2 (t v1) end) )))

(=> (and (ls2 (t v2) end) (not (select inDelta v2)) (not (= v2 end)))(= (mkeys2 v2 end)
(mult-union
(mult-store (mult-store (mult-store (mult-store (mult-store (mult-store (mult-store (mult-store mult-empInt
(key v2) 1)
key1 num_key1@v2seg)
key2 num_key2@v2seg)
key3 num_key3@v2seg)
key4 num_key4@v2seg)
key5 num_key5@v2seg)
key6 num_key6@v2seg)
key7 num_key7@v2seg)
(mkeys2 (t v2) end) )))

(=> (and (ls2 (t v3) end) (not (select inDelta v3)) (not (= v3 end)))(= (mkeys2 v3 end)
(mult-union
(mult-store (mult-store (mult-store (mult-store (mult-store (mult-store (mult-store (mult-store mult-empInt
(key v3) 1)
key1 num_key1@v3seg)
key2 num_key2@v3seg)
key3 num_key3@v3seg)
key4 num_key4@v3seg)
key5 num_key5@v3seg)
key6 num_key6@v3seg)
key7 num_key7@v3seg)
(mkeys2 (t v3) end) )))

(=> (and (ls2 (t v4) end) (not (select inDelta v4)) (not (= v4 end)))(= (mkeys2 v4 end)
(mult-union
(mult-store (mult-store (mult-store (mult-store (mult-store (mult-store (mult-store (mult-store mult-empInt
(key v4) 1)
key1 num_key1@v4seg)
key2 num_key2@v4seg)
key3 num_key3@v4seg)
key4 num_key4@v4seg)
key5 num_key5@v4seg)
key6 num_key6@v4seg)
key7 num_key7@v4seg)
(mkeys2 (t v4) end) )))

(=> (and (ls2 (t v5) end) (not (select inDelta v5)) (not (= v5 end)))(= (mkeys2 v5 end)
(mult-union
(mult-store (mult-store (mult-store (mult-store (mult-store (mult-store (mult-store (mult-store mult-empInt
(key v5) 1)
key1 num_key1@v5seg)
key2 num_key2@v5seg)
key3 num_key3@v5seg)
key4 num_key4@v5seg)
key5 num_key5@v5seg)
key6 num_key6@v5seg)
key7 num_key7@v5seg)
(mkeys2 (t v5) end) )))

))
(define-fun t_propagate_for_vars ((end Loc)) Bool
(and (mkeys_propagate_for_vars end)
(and (t_propagate v1 end)
(and (t_propagate v2 end)
(and (t_propagate v3 end)
(and (t_propagate v4 end)
(and (t_propagate v5 end)
)))))))

(define-fun t_propagate2_for_vars ((end Loc)) Bool
(and (mkeys2_propagate_for_vars end)
(and (t_propagate2 v1 end)
(and (t_propagate2 v2 end)
(and (t_propagate2 v3 end)
(and (t_propagate2 v4 end)
(and (t_propagate2 v5 end)
)))))))

;;-----------------------------------------------------------
;;-----------------------------------------------------------

;;sorted_merge(x, y): merges two sorted lists into another
(declare-const x Loc)
(assert (inKeys (key x)))
(assert (closed-sys x))
(declare-const y Loc)
(assert (inKeys (key y)))
(assert (closed-sys y))
(declare-const ret Loc)
(assert (inKeys (key ret)))
(assert (closed-sys ret))
(declare-const temp Loc)
(assert (inKeys (key temp)))
(assert (closed-sys temp))
(declare-const oldhls (Set Loc))
(declare-const oldmkeys (MultiSet Int))

(push)
;;if x == nil
(assert (= x nil))
;;return y

;;--delta is nothing
(assert (= inDelta empLoc))

;@precondition: list(x) && list(y) && sorted(x) && sorted(y) 
;;&& hls(x) \intersect hls(y) = emp && oldhls = hls(x, nil) \union hls(y, nil)
;;&& oldmkeys = mkeys(x, nil) \union mkeys(y, nil)
(assert (and 
(ls x nil) (sorted x nil) 
(ls y nil) (sorted y nil)
(= (intersect (hls x nil) (hls y nil)) empLoc)
(= oldhls (union (hls x nil) (hls y nil)))
(= oldmkeys (mult-union (mkeys x nil) (mkeys y nil)))
))
(assert (base nil))
(assert (t_propagate_for_vars nil))

;negate@postcondition: list(y) && sorted(y) && oldhls = hls(y, nil)
;;&& oldmkeys = mkeys(y, nil)
(assert (not (and
(ls y nil) (sorted y nil)
(= oldhls (hls y nil))
(= oldmkeys (mkeys y nil))
)))
(check-sat)
(get-model)
(pop)

(push)
;;if y == nil
(assert (= y nil))
;;return x

;;--delta is nothing
(assert (= inDelta empLoc))

;@precondition: list(x) && list(y) && sorted(x) && sorted(y) 
;;&& hls(x) \intersect hls(y) = emp && oldhls = hls(x, nil) \union hls(y, nil)
;;&& oldmkeys = mkeys(x, nil) \union mkeys(y, nil)
(assert (and 
(ls x nil) (sorted x nil) 
(ls y nil) (sorted y nil)
(= (intersect (hls x nil) (hls y nil)) empLoc)
(= oldhls (union (hls x nil) (hls y nil)))
(= oldmkeys (mult-union (mkeys x nil) (mkeys y nil)))
))
(assert (base nil))
(assert (t_propagate_for_vars nil))

;negate@postcondition: list(x) && sorted(x) && oldhls = hls(x, nil)
;;&& oldmkeys = mkeys(x, nil)
(assert (not (and
(ls x nil) (sorted x nil)
(= oldhls (hls x nil))
(= oldmkeys (mkeys x nil))
)))
(check-sat)
(get-model)
(pop)


(push)
;;x =/= nil && y =/= nil
(assert (and (not (= x nil)) (not (= y nil))))
;;if x.key <= y.key
(assert (<= (key x) (key y)))
;;ret = x
(assert (= ret x))
;;temp = ret
(assert (= temp ret))
;;x = x.next
(declare-const x2 Loc)
(assert (inKeys (key x2)))
(assert (= x2 (select n x)))
;;temp.next = nil
(assert (= n2 (store n temp nil)))

;;--delta is x and temp
(assert (= inDelta
(store (store empLoc
x true)
temp true)
))
(assert (closed-sys (select n x)))
(assert (t-structure-for-hls x))
(assert (closed-sys (select n temp)))
(assert (t-structure-for-hls temp))

;@precondition: list(x) && list(y) && sorted(x) && sorted(y) 
;;&& hls(x) \intersect hls(y) = emp && oldhls = hls(x, nil) \union hls(y, nil)
;;&& oldmkeys = mkeys(x, nil) \union mkeys(y, nil)
(assert (and 
(ls x nil) (sorted x nil) 
(ls y nil) (sorted y nil)
(= (intersect (hls x nil) (hls y nil)) empLoc)
(= oldhls (union (hls x nil) (hls y nil)))
(= oldmkeys (mult-union (mkeys x nil) (mkeys y nil)))
))
(assert (base nil))
(assert (n_propagate x nil))
(assert (n_propagate temp nil))
(assert (t_propagate_for_vars nil))

;negate@list(x) && list(y) && ls(ret, temp) && temp.next ==nil
;;&& sorted(x) && sorted(y) && sorted(ret) 
;;&& hls(x) \intersect hls(y) = emp 
;;&& oldhls = hls(x, nil) \union hls(y, nil) \union hls(ret, nil)
;;&& oldmkeys = mkeys(x, nil) \union mkeys(y, nil) \union mkeys(ret, nil)
(assert (not (and
(ls2 x2 nil) (sorted2 x2 nil)
(ls2 y nil) (sorted2 y nil)
(ls2 ret temp) (= (select n2 temp) nil) (sorted2 ret nil)
(=> (not (= x2 nil)) (<= (maxls2 ret nil) (minls2 x2 nil)))
(=> (not (= y nil)) (<= (maxls2 ret nil) (minls2 y nil)))
(= (intersect (hls2 x2 nil) (hls2 y nil)) empLoc)
(= (intersect (hls2 ret nil) (hls2 y nil)) empLoc)
(= (intersect (hls2 ret nil) (hls2 x2 nil)) empLoc)
(= oldhls (union (union (hls2 x2 nil) (hls2 y nil)) (hls2 ret nil)))
(= oldmkeys (mult-union (mult-union (mkeys2 x2 nil) (mkeys2 y nil)) (mkeys2 ret nil)))
)))
(assert (base2 nil))
(assert (n2_propagate x nil))
(assert (n2_propagate temp nil))
(assert (t_propagate2_for_vars nil))
(assert (base2 temp))
(assert (n2_propagate x temp))
(assert (n2_propagate temp temp))
(assert (t_propagate2_for_vars temp))
(check-sat)
(get-model)
(pop)

(push)
;;x =/= nil && y =/= nil
(assert (and (not (= x nil)) (not (= y nil))))
;;if x.key > y.key
(assert (> (key x) (key y)))
;;ret = y
(assert (= ret y))
;;temp = ret
(assert (= temp ret))
;;y = y.next
(declare-const y2 Loc)
(assert (inKeys (key y2)))
(assert (= y2 (select n y)))
;;temp.next = nil
(assert (= n2 (store n temp nil)))

;;--delta is y and temp
(assert (= inDelta
(store (store empLoc
y true)
temp true)
))
(assert (closed-sys (select n y)))
(assert (t-structure-for-hls y))
(assert (closed-sys (select n temp)))
(assert (t-structure-for-hls temp))

;@precondition: list(x) && list(y) && sorted(x) && sorted(y) 
;;&& hls(x) \intersect hls(y) = emp && oldhls = hls(x, nil) \union hls(y, nil)
;;&& oldmkeys = mkeys(x, nil) \union mkeys(y, nil)
(assert (and 
(ls x nil) (sorted x nil) 
(ls y nil) (sorted y nil)
(= (intersect (hls x nil) (hls y nil)) empLoc)
(= oldhls (union (hls x nil) (hls y nil)))
(= oldmkeys (mult-union (mkeys x nil) (mkeys y nil)))
))
(assert (base nil))
(assert (n_propagate y nil))
(assert (n_propagate temp nil))
(assert (t_propagate_for_vars nil))

;negate@list(x) && list(y) && ls(ret, temp) && temp.next ==nil
;;&& sorted(x) && sorted(y) && sorted(ret) 
;;&& hls(x) \intersect hls(y) = emp 
;;&& oldhls = hls(x, nil) \union hls(y, nil) \union hls(ret, nil)
;;&& oldmkeys = mkeys(x, nil) \union mkeys(y, nil) \union mkeys(ret, nil)
(assert (not (and
(ls2 x nil) (sorted2 x nil)
(ls2 y2 nil) (sorted2 y2 nil)
(ls2 ret temp) (= (select n2 temp) nil) (sorted2 ret nil)
(=> (not (= x nil)) (<= (maxls2 ret nil) (minls2 x nil)))
(=> (not (= y2 nil)) (<= (maxls2 ret nil) (minls2 y2 nil)))
(= (intersect (hls2 x nil) (hls2 y2 nil)) empLoc)
(= (intersect (hls2 ret nil) (hls2 y2 nil)) empLoc)
(= (intersect (hls2 ret nil) (hls2 x nil)) empLoc)
(= oldhls (union (union (hls2 x nil) (hls2 y2 nil)) (hls2 ret nil)))
(= oldmkeys (mult-union (mult-union (mkeys2 x nil) (mkeys2 y2 nil)) (mkeys2 ret nil)))
)))
(assert (base2 nil))
(assert (n2_propagate y nil))
(assert (n2_propagate temp nil))
(assert (t_propagate2_for_vars nil))
(assert (base2 temp))
(assert (n2_propagate y temp))
(assert (n2_propagate temp temp))
(assert (t_propagate2_for_vars temp))
(check-sat)
(get-model)
(pop)

(push)
;;while x =/= nil && y =/= nil
(assert (and (not (= x nil)) (not (= y nil))))
;;if x.key <= y.key
(assert (<= (key x) (key y)))
;;temp.next = x
(declare-const n3 (Array Loc Loc))
(assert (= n3 (store n temp x)))
;;x = x.next
(declare-const x2 Loc)
(assert (inKeys (key x2)))
(assert (= x2 (select n3 x)))
;;temp = temp.next
(declare-const temp2 Loc)
(assert (inKeys (key temp2)))
(assert (= temp2 (select n3 temp)))
;temp.next = nil
(assert (= n2 (store n3 temp2 nil)))

;;--delta is x, temp and temp2
(assert (= inDelta
(store (store (store empLoc
x true)
temp true)
temp2 true)
))
(assert (closed-sys (select n x)))
(assert (t-structure-for-hls x))
(assert (closed-sys (select n temp)))
(assert (t-structure-for-hls temp))
(assert (closed-sys (select n temp2)))
(assert (t-structure-for-hls temp2))

;@list(x) && list(y) && ls(ret, temp) && temp.next ==nil
;;&& sorted(x) && sorted(y) && sorted(ret) 
;;&& hls(x) \intersect hls(y) = emp 
;;&& oldhls = hls(x, nil) \union hls(y, nil) \union hls(ret, nil)
;;&& oldmkeys = mkeys(x, nil) \union mkeys(y, nil) \union mkeys(ret, nil)
(assert (and
(ls x nil) (sorted x nil)
(ls y nil) (sorted y nil)
(ls ret temp) (= (select n temp) nil) (sorted ret nil)
(=> (not (= x nil)) (<= (maxls ret nil) (minls x nil)))
(=> (not (= y nil)) (<= (maxls ret nil) (minls y nil)))
(= (intersect (hls x nil) (hls y nil)) empLoc)
(= (intersect (hls ret nil) (hls y nil)) empLoc)
(= (intersect (hls ret nil) (hls x nil)) empLoc)
(= oldhls (union (union (hls x nil) (hls y nil)) (hls ret nil)))
(= oldmkeys (mult-union (mult-union (mkeys x nil) (mkeys y nil)) (mkeys ret nil)))
))
(assert (base nil))
(assert (n_propagate x nil))
(assert (n_propagate temp nil))
(assert (n_propagate temp2 nil))
(assert (t_propagate_for_vars nil))
(assert (base temp))
(assert (n_propagate x temp))
(assert (n_propagate temp temp))
(assert (n_propagate temp2 temp))
(assert (t_propagate_for_vars temp))
(assert (base temp2))
(assert (n_propagate x temp2))
(assert (n_propagate temp temp2))
(assert (n_propagate temp2 temp2))
(assert (t_propagate_for_vars temp2))

;negate@list(x) && list(y) && ls(ret, temp) && temp.next ==nil
;;&& sorted(x) && sorted(y) && sorted(ret) 
;;&& hls(x) \intersect hls(y) = emp 
;;&& oldhls = hls(x, nil) \union hls(y, nil) \union hls(ret, nil)
;;&& oldmkeys = mkeys(x, nil) \union mkeys(y, nil) \union mkeys(ret, nil)
(assert (not (and
(ls2 x2 nil) (sorted2 x2 nil)
(ls2 y nil) (sorted2 y nil)
(ls2 ret temp2) (= (select n2 temp2) nil) (sorted2 ret nil)
(=> (not (= x2 nil)) (<= (maxls2 ret nil) (minls2 x2 nil)))
(=> (not (= y nil)) (<= (maxls2 ret nil) (minls2 y nil)))
(= (intersect (hls2 x2 nil) (hls2 y nil)) empLoc)
(= (intersect (hls2 ret nil) (hls2 y nil)) empLoc)
(= (intersect (hls2 ret nil) (hls2 x2 nil)) empLoc)
(= oldhls (union (union (hls2 x2 nil) (hls2 y nil)) (hls2 ret nil)))
(= oldmkeys (mult-union (mult-union (mkeys2 x2 nil) (mkeys2 y nil)) (mkeys2 ret nil)))
)))
(assert (base2 nil))
(assert (n2_propagate x nil))
(assert (n2_propagate temp nil))
(assert (n2_propagate temp2 nil))
(assert (t_propagate2_for_vars nil))
(assert (base2 temp))
(assert (n2_propagate x temp))
(assert (n2_propagate temp temp))
(assert (n2_propagate temp2 temp))
(assert (t_propagate2_for_vars temp))
(assert (base2 temp2))
(assert (n2_propagate x temp2))
(assert (n2_propagate temp temp2))
(assert (n2_propagate temp2 temp2))
(assert (t_propagate2_for_vars temp2))
(check-sat)
(get-model)
(pop)

(push)
;;while x =/= nil && y =/= nil
(assert (and (not (= x nil)) (not (= y nil))))
;;if x.key > y.key
(assert (> (key x) (key y)))
;;temp.next = y
(declare-const n3 (Array Loc Loc))
(assert (= n3 (store n temp y)))
;;y = y.next
(declare-const y2 Loc)
(assert (inKeys (key y2)))
(assert (= y2 (select n3 y)))
;;temp = temp.next
(declare-const temp2 Loc)
(assert (inKeys (key temp2)))
(assert (= temp2 (select n3 temp)))
;temp.next = nil
(assert (= n2 (store n3 temp2 nil)))

;;--delta is y, temp and temp2
(assert (= inDelta
(store (store (store empLoc
y true)
temp true)
temp2 true)
))
(assert (closed-sys (select n y)))
(assert (t-structure-for-hls y))
(assert (closed-sys (select n temp)))
(assert (t-structure-for-hls temp))
(assert (closed-sys (select n temp2)))
(assert (t-structure-for-hls temp2))

;@list(x) && list(y) && ls(ret, temp) && temp.next ==nil
;;&& sorted(x) && sorted(y) && sorted(ret) 
;;&& hls(x) \intersect hls(y) = emp 
;;&& oldhls = hls(x, nil) \union hls(y, nil) \union hls(ret, nil)
;;&& oldmkeys = mkeys(x, nil) \union mkeys(y, nil) \union mkeys(ret, nil)
(assert (and
(ls x nil) (sorted x nil)
(ls y nil) (sorted y nil)
(ls ret temp) (= (select n temp) nil) (sorted ret nil)
(=> (not (= x nil)) (<= (maxls ret nil) (minls x nil)))
(=> (not (= y nil)) (<= (maxls ret nil) (minls y nil)))
(= (intersect (hls x nil) (hls y nil)) empLoc)
(= (intersect (hls ret nil) (hls y nil)) empLoc)
(= (intersect (hls ret nil) (hls x nil)) empLoc)
(= oldhls (union (union (hls x nil) (hls y nil)) (hls ret nil)))
(= oldmkeys (mult-union (mult-union (mkeys x nil) (mkeys y nil)) (mkeys ret nil)))
))
(assert (base nil))
(assert (n_propagate y nil))
(assert (n_propagate temp nil))
(assert (n_propagate temp2 nil))
(assert (t_propagate_for_vars nil))
(assert (base temp))
(assert (n_propagate y temp))
(assert (n_propagate temp temp))
(assert (n_propagate temp2 temp))
(assert (t_propagate_for_vars temp))
(assert (base temp2))
(assert (n_propagate y temp2))
(assert (n_propagate temp temp2))
(assert (n_propagate temp2 temp2))
(assert (t_propagate_for_vars temp2))

;negate@list(x) && list(y) && ls(ret, temp) && temp.next ==nil
;;&& sorted(x) && sorted(y) && sorted(ret) 
;;&& hls(x) \intersect hls(y) = emp 
;;&& oldhls = hls(x, nil) \union hls(y, nil) \union hls(ret, nil)
;;&& oldmkeys = mkeys(x, nil) \union mkeys(y, nil) \union mkeys(ret, nil)
(assert (not (and
(ls2 x nil) (sorted2 x nil)
(ls2 y2 nil) (sorted2 y2 nil)
(ls2 ret temp2) (= (select n2 temp2) nil) (sorted2 ret nil)
(=> (not (= x nil)) (<= (maxls2 ret nil) (minls2 x nil)))
(=> (not (= y2 nil)) (<= (maxls2 ret nil) (minls2 y2 nil)))
(= (intersect (hls2 x nil) (hls2 y2 nil)) empLoc)
(= (intersect (hls2 ret nil) (hls2 y2 nil)) empLoc)
(= (intersect (hls2 ret nil) (hls2 x nil)) empLoc)
(= oldhls (union (union (hls2 x nil) (hls2 y2 nil)) (hls2 ret nil)))
(= oldmkeys (mult-union (mult-union (mkeys2 x nil) (mkeys2 y2 nil)) (mkeys2 ret nil)))
)))
(assert (base2 nil))
(assert (n2_propagate y nil))
(assert (n2_propagate temp nil))
(assert (n2_propagate temp2 nil))
(assert (t_propagate2_for_vars nil))
(assert (base2 temp))
(assert (n2_propagate y temp))
(assert (n2_propagate temp temp))
(assert (n2_propagate temp2 temp))
(assert (t_propagate2_for_vars temp))
(assert (base2 temp2))
(assert (n2_propagate y temp2))
(assert (n2_propagate temp temp2))
(assert (n2_propagate temp2 temp2))
(assert (t_propagate2_for_vars temp2))
(check-sat)
(get-model)
(pop)

;;end-of-while
(push)
;;x == nil or y == nil
;;if x == nil
(assert (= x nil))
;;temp.next = y
(assert (= n2 (store n temp y)))
;;return ret

;;--delta is temp
(assert (= inDelta
(store empLoc
temp true)
))
(assert (closed-sys (select n temp)))
(assert (t-structure-for-hls temp))

;@list(x) && list(y) && ls(ret, temp) && temp.next ==nil
;;&& sorted(x) && sorted(y) && sorted(ret) 
;;&& hls(x) \intersect hls(y) = emp 
;;&& oldhls = hls(x, nil) \union hls(y, nil) \union hls(ret, nil)
;;&& oldmkeys = mkeys(x, nil) \union mkeys(y, nil) \union mkeys(ret, nil)
(assert (and
(ls x nil) (sorted x nil)
(ls y nil) (sorted y nil)
(ls ret temp) (= (select n temp) nil) (sorted ret nil)
(=> (not (= x nil)) (<= (maxls ret nil) (minls x nil)))
(=> (not (= y nil)) (<= (maxls ret nil) (minls y nil)))
(= (intersect (hls x nil) (hls y nil)) empLoc)
(= (intersect (hls ret nil) (hls y nil)) empLoc)
(= (intersect (hls ret nil) (hls x nil)) empLoc)
(= oldhls (union (union (hls x nil) (hls y nil)) (hls ret nil)))
(= oldmkeys (mult-union (mult-union (mkeys x nil) (mkeys y nil)) (mkeys ret nil)))
))
(assert (base nil))
(assert (n_propagate temp nil))
(assert (t_propagate_for_vars nil))
(assert (base temp))
(assert (n_propagate temp temp))
(assert (t_propagate_for_vars temp))

;negate@list(ret) && sorted(ret) && oldhls = hls(ret, nil)
;;&& oldmkeys = mkeys(ret, nil)
(assert (not (and
(ls2 ret nil) (sorted2 ret nil)
(= oldhls (hls2 ret nil))
(= oldmkeys (mkeys2 ret nil))
)))
(assert (base2 nil))
(assert (n2_propagate temp nil))
(assert (t_propagate2_for_vars nil))
(assert (base2 temp))
(assert (n2_propagate temp temp))
(assert (t_propagate2_for_vars temp))
(check-sat)
(get-model)
(pop)

(push)
;;x == nil or y == nil
;;if y == nil
(assert (= y nil))
;;temp.next = x
(assert (= n2 (store n temp x)))
;;return ret

;;--delta is temp
(assert (= inDelta
(store empLoc
temp true)
))
(assert (closed-sys (select n temp)))
(assert (t-structure-for-hls temp))

;@list(x) && list(y) && ls(ret, temp) && temp.next ==nil
;;&& sorted(x) && sorted(y) && sorted(ret) 
;;&& hls(x) \intersect hls(y) = emp 
;;&& oldhls = hls(x, nil) \union hls(y, nil) \union hls(ret, nil)
;;&& oldmkeys = mkeys(x, nil) \union mkeys(y, nil) \union mkeys(ret, nil)
(assert (and
(ls x nil) (sorted x nil)
(ls y nil) (sorted y nil)
(ls ret temp) (= (select n temp) nil) (sorted ret nil)
(=> (not (= x nil)) (<= (maxls ret nil) (minls x nil)))
(=> (not (= y nil)) (<= (maxls ret nil) (minls y nil)))
(= (intersect (hls x nil) (hls y nil)) empLoc)
(= (intersect (hls ret nil) (hls y nil)) empLoc)
(= (intersect (hls ret nil) (hls x nil)) empLoc)
(= oldhls (union (union (hls x nil) (hls y nil)) (hls ret nil)))
(= oldmkeys (mult-union (mult-union (mkeys x nil) (mkeys y nil)) (mkeys ret nil)))
))
(assert (base nil))
(assert (n_propagate temp nil))
(assert (t_propagate_for_vars nil))
(assert (base temp))
(assert (n_propagate temp temp))
(assert (t_propagate_for_vars temp))

;@list(ret) && sorted(ret) && oldhls = hls(ret, nil)
;;&& oldmkeys = mkeys(ret, nil)
(assert (not (and
(ls2 ret nil) (sorted2 ret nil)
(= oldhls (hls2 ret nil))
(= oldmkeys (mkeys2 ret nil))
)))
(assert (base2 nil))
(assert (n2_propagate temp nil))
(assert (t_propagate2_for_vars nil))
(assert (base2 temp))
(assert (n2_propagate temp temp))
(assert (t_propagate2_for_vars temp))
(check-sat)
(get-model)
(pop)
