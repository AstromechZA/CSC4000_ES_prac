(clear)

(deftemplate week (slot value))
(deftemplate day (slot value))
(deftemplate period (slot value))
(deftemplate room (slot value))
(deftemplate available_slot (slot week) (slot day) (slot period) (slot room))
(deftemplate blocked_slot (slot week) (slot day) (slot period) (slot room))
(deftemplate booked_lecture (slot week) (slot day) (slot period) (slot room) (slot course) (slot num))
(deftemplate lecturer_busy (slot week) (slot day) (slot period) (slot lecturer))
(deftemplate lectures (slot course) (slot lecturer) (slot count))
(deftemplate lecture (slot course) (slot lecturer) (slot num))

; create all of the available slots
(defrule create_available_slots
	; a slot
	(week (value ?w))
	(day (value ?d))
	(period (value ?p))
	(room (value ?r))

	; that is free and not blocked
	(not (blocked_slot (week ?w|*) (day ?d|*) (period ?p|*) (room ?r|*)))
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

; Because we cen define lecture's in batches as 'lectures' 
; we need to split these into their individual lecture periods.
(defrule split_course
	; if there are any lecture batches defined
	?f <- (lectures (course ?c) (lecturer ?l) (count ?n))
	=>
	; retract the fact
	(retract ?f)
	; add n lectures
	(loop-for-count (?s ?n) do		
		(assert		
			(lecture (course ?c) (lecturer ?l) (num ?s))
		)
	)
)

(deffunction print_timetable()
	(printout t crlf)
	(do-for-all-facts ((?week week)) TRUE
		(printout t crlf "Week " ?week:value crlf)
		(printout t "---------------------------------------------------------------------------" crlf)
		
		; print out day names
		(printout t "|        |")
		(do-for-all-facts ((?day day)) TRUE
			(format t " %-10s |" ?day:value)
		)
		(printout t crlf "---------------------------------------------------------------------------" crlf)

		; loop table rows
		(do-for-all-facts ((?period period)) TRUE

			; print out period and course in columns
			(format t "|%-8s|" ?period:value)			
			(do-for-all-facts ((?day day)) TRUE	
				(bind ?slot_lectures (find-fact ((?bl booked_lecture)) (and (eq ?bl:week ?week:value) (eq ?bl:period ?period:value) (eq ?bl:day ?day:value))))	
				(if (> (length$ ?slot_lectures) 0) then
					(bind ?slot_lecture (nth$ 1 ?slot_lectures))
					(format t " %-10s |" (fact-slot-value ?slot_lecture course))
				else
					(printout t "            |")
				)
			)
			(printout t crlf "|        |")	

			; print out room name in colums
			(do-for-all-facts ((?day day)) TRUE	
				(bind ?slot_lectures (find-fact ((?bl booked_lecture)) (and (eq ?bl:week ?week:value) (eq ?bl:period ?period:value) (eq ?bl:day ?day:value))))	
				(if (> (length$ ?slot_lectures) 0) then
					(bind ?slot_lecture (nth$ 1 ?slot_lectures))
					(format t " %-10s |" (fact-slot-value ?slot_lecture room))
				else
					(printout t "            |")
				)
			)		
			(printout t crlf "|--------|------------|------------|------------|------------|------------|" crlf)						
		)
		
		(printout t crlf)
	)
)

(deffunction find_unplaced_lectures()
	(printout t crlf)
	(printout t "List of lectures that could not be scheduled:" crlf)
	(printout t "---------------------------------------------" crlf)
	
	; there should be no (lecture) templates left
	(if (> (length (find-all-facts ((?m lecture)) TRUE)) 0) 
		then
			(do-for-all-facts ((?l lecture)) TRUE 
				(printout t ?l:course " lecture #" ?l:num crlf)
			)
			(printout t crlf)
		else
			(printout t "None." crlf crlf)
	)	
)
		 
(deffacts startup
	; there are 6 weeks
	(week (value 1))
	(week (value 2))
	(week (value 3))
	(week (value 4))
	(week (value 5))
	(week (value 6))

	; with 5 days
	(day (value "Monday"))
	(day (value "Tuesday"))
	(day (value "Wednesday"))
	(day (value "Thursday"))
	(day (value "Friday"))

	; with 7 periods
	(period (value "08:00"))
	(period (value "09:00"))
	(period (value "10:00"))
	(period (value "11:00"))
	(period (value "12:00"))
	(period (value "13:00"))
	(period (value "14:00"))
	(period (value "15:00"))

	; and there are rooms
	(room (value "CSC LT 2A"))
	(room (value "CSC302"))
	(room (value "CSC303"))

	; and lecturers with the modules they teach X times
	(lectures (course "VIS") (lecturer "Michelle Kuttel") (count 20))
	(lectures (course "IR") (lecturer "Hussein Suleman") (count 20))
	
	; student advisors have their open office hours where they can't have lectures
	(lecturer_busy (week *) (day "Friday") (period "09:00") (lecturer "Michelle Kuttel"))
	(lecturer_busy (week *) (day "Wednesday") (period "10:00") (lecturer "Hussein Suleman"))
	
	; Room CSC303 is booked every Thursday during meridian for colloqiums
	(blocked_slot (week *) (day "Thursday") (period "13:00") (room "CSC303"))

	; in fact, nothing can happen at meridian 13:00
	(blocked_slot (week *) (day *) (period "13:00") (room *))
)

; reset all facts		 
(reset)
; load facts, run reasoning
(run)
; print the final timetable
(print_timetable)
; show any unscheduled lectures
(find_unplaced_lectures)
