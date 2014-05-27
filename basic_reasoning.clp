(clear)

(deftemplate available_slot (slot week) (slot day) (slot period) (slot room))
(deftemplate blocked_slot (slot week) (slot day) (slot period) (slot room))
(deftemplate booked_lecture (slot week) (slot day) (slot period) (slot room) (slot course) (slot num))
(deftemplate lecturer_busy (slot week) (slot day) (slot period) (slot lecturer))
(deftemplate lectures (slot course) (slot lecturer) (slot count))
(deftemplate lecture (slot course) (slot lecturer) (slot num))

; create all of the available slots
(defrule create_available_slots
	; a slot
	(week ?w) (day ?d) (period ?p) (room ?r)

	; that is free and not blocked
	(not (blocked_slot (week ?w|*) (day ?d|*) (period ?p|*) (room ?r)))
	=>
	(assert 
		(available_slot (week ?w) (day ?d) (period ?p) (room ?r))
	)
)

(defrule place_a_lecture
	; theres a lecture
	?f1 <- (lecture (course ?course) (lecturer ?lecturer) (num ?n))
	; that has not been placed
	(not (booked_lecture (course ?course) (num ?n)))

	; and an available venue slot
	?f2 <- (available_slot (week ?w) (day ?d) (period ?p) (room ?r))

	; and no other lecture from the same course is on that day
	(not (booked_lecture (week ?w) (day ?d) (course ?course)))
	
	; and the lecturer isn't already busy during that period
	(not (lecturer_busy (week ?w|*) (day ?d|*) (period ?p|*) (lecturer ?lecturer)))

	=>
	; no longer need these and they clutter fact list
	(retract ?f1 ?f2)
	
	(assert
		; book the lecture
		(booked_lecture (week ?w) (day ?d) (period ?p) (room ?r) (course ?course) (num ?n))
		; block the slot
		(blocked_slot (week ?w) (day ?d) (period ?p) (room ?r))
		
		; lecturer busy during that period
		(lecturer_busy (week ?w) (day ?d) (period ?p) (lecturer ?lecturer))
	)
)

(defrule split_course
	?f <- (lectures (course ?c) (lecturer ?l) (count ?n))
	=>
	(retract ?f)
	(loop-for-count (?s ?n) do		
		(assert		
			(lecture (course ?c) (lecturer ?l) (num ?s))
		)
	)
)

(deffacts startup
	; there are 6 weeks
	(week 1)
	(week 2)
	(week 3)
	(week 4)
	(week 5)
	(week 6)

	; with 5 days
	(day monday)
	(day tuesday)
	(day wednesday)
	(day thursday)
	(day friday)

	; with 7 periods
	(period h0800)
	(period h0900)
	(period h1000)
	(period h1100)
	(period h1200)
	(period h1300)
	(period h1400)
	(period h1500)

	; and there are rooms
	(room CSC303)

	; and lecturers with the modules they teach X times
	(lectures (course VIS) (lecturer "Michelle Kuttel") (count 20))
	(lectures (course IR) (lecturer "Hussein Suleman") (count 20))
	
	; student advisors have their open office hours where they can't have lectures
	(lecturer_busy (week *) (day monday) (period h0900) (lecturer "Michelle Kuttel"))
	(lecturer_busy (week *) (day tuesday) (period h1400) (lecturer "Hussein Suleman"))
	
	; Room CSC303 is booked every Thursday during meridian for colloqiums
	(blocked_slot (week *) (day thursday) (period h1300) (room CSC303))
)
(deffunction find_unplaced_lectures()
	(printout t crlf)
	(printout t "List of lectures that could not be scheduled:" crlf)
	(printout t "---------------------------------------------" crlf)
	
	(if (> (length (find-all-facts ((?m lecture)) TRUE)) 0) 
		then
			(do-for-fact ((?l lecture)) TRUE 
				(printout t ?l:course " lecture #" ?l:num crlf)
			)
			(printout t crlf)
		else
			(printout t "None." crlf crlf)
	)
	
)
		 
(reset)
(run)
(find_unplaced_lectures)
