(clear)

(deftemplate n-v (slot name) (slot value))
(deftemplate available_slot (slot week) (slot day) (slot period) (slot room))
(deftemplate blocked_slot (slot week) (slot day) (slot period) (slot room))
(deftemplate booked_lecture (slot week) (slot day) (slot period) (slot room) (slot course) (slot num))
(deftemplate lecturer_busy (slot week) (slot day) (slot period) (slot lecturer))
(deftemplate lectures (slot course) (slot lecturer) (slot count))
(deftemplate lecture (slot course) (slot lecturer) (slot num))

; create all of the available slots
(defrule create_available_slots
	; a slot
	(n-v (name week) (value ?w))
	(n-v (name day) (value ?d))
	(n-v (name period) (value ?p))
	(n-v (name room) (value ?r))
	;(week ?w) (day ?d) (period ?p) (room ?r)

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
	(n-v (name week) (value 1))
	(n-v (name week) (value 2))
	(n-v (name week) (value 3))
	(n-v (name week) (value 4))
	(n-v (name week) (value 5))
	(n-v (name week) (value 6))

	; with 5 days
	(n-v (name day) (value monday))
	(n-v (name day) (value tuesday))
	(n-v (name day) (value wednesday))
	(n-v (name day) (value thursday))
	(n-v (name day) (value friday))

	; with 7 periods
	(n-v (name period) (value h0800))
	(n-v (name period) (value h0900))
	(n-v (name period) (value h1000))
	(n-v (name period) (value h1100))
	(n-v (name period) (value h1200))
	(n-v (name period) (value h1300))
	(n-v (name period) (value h1400))
	(n-v (name period) (value h1500))

	; and there are rooms
	(n-v (name room) (value CSC303))

	; and lecturers with the modules they teach X times
	(lectures (course VIS) (lecturer "Michelle Kuttel") (count 20))
	(lectures (course IR) (lecturer "Hussein Suleman") (count 20))
	
	; student advisors have their open office hours where they can't have lectures
	(lecturer_busy (week *) (day friday) (period h0900) (lecturer "Michelle Kuttel"))
	(lecturer_busy (week *) (day wednesday) (period h0800) (lecturer "Hussein Suleman"))
	
	; Room CSC303 is booked every Thursday during meridian for colloqiums
	(blocked_slot (week *) (day thursday) (period h1300) (room CSC303))
)

(deffunction print_timetable()
	(printout t crlf)
	(do-for-all-facts ((?week n-v)) (eq ?week:name week)
		(printout t crlf "Week " ?week:value crlf)
		(printout t "---------------------------------------------------------------------------" crlf)
		
		; print out day names
		(printout t "|        |")
		(do-for-all-facts ((?day n-v)) (eq ?day:name day)
			(format t " %-10s |" ?day:value)
		)
		(printout t crlf "---------------------------------------------------------------------------" crlf)

		; loop table rows
		(do-for-all-facts ((?period n-v)) (eq ?period:name period)

			; print out period and course in columns
			(format t "|%-8s|" ?period:value)			
			(do-for-all-facts ((?day n-v)) (eq ?day:name day)				
				(if (not(do-for-fact ((?bl booked_lecture)) (and (= ?bl:week ?week:value) (eq ?bl:period ?period:value) (eq ?bl:day ?day:value))
						(format t " %-10s |" ?bl:course)
					))
					then
						(printout t "            |")
				)
			)
			(printout t crlf "|        |")			
			; print out room name in colums
			(do-for-all-facts ((?day n-v)) (eq ?day:name day)				
				(if (not(do-for-fact ((?bl booked_lecture)) (and (= ?bl:week ?week:value) (eq ?bl:period ?period:value) (eq ?bl:day ?day:value))
						(format t " %-10s |" ?bl:room)
					))
					then
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
		 
(reset)
(run)
(print_timetable)
(find_unplaced_lectures)
