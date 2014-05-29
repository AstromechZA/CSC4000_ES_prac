(clear)

(deftemplate week (slot value) (slot startdate))
(deftemplate day (slot value))
(deftemplate period (slot value) (slot timestring))
(deftemplate room (slot value))
(deftemplate available_slot (slot week) (slot day) (slot period) (slot room))
(deftemplate blocked_slot (slot week) (slot day) (slot period) (slot room))
(deftemplate booked_lecture (slot week) (slot day) (slot period) (slot room) (slot course) (slot num))
(deftemplate lecturer_busy (slot week) (slot day) (slot period) (slot lecturer))
(deftemplate lectures (slot course) (slot lecturer) (slot count))
(deftemplate lecture (slot course) (slot lecturer) (slot num) (slot length))

; create all of the available slots
(defrule create_available_slots
	; a slot
	(week (value ?w))
	(day (value ?d))
	(period (value ?p) (timestring ?ts))
	(room (value ?r))

	; that is free and not blocked
	(not (blocked_slot (week ?w|*) (day ?d|*) (period ?p|*|?ts) (room ?r|*)))
	=>
	(assert 
		(available_slot (week ?w) (day ?d) (period ?p) (room ?r))
	)
)

(defrule place_a_lecture
	; theres a lecture
	?f1 <- (lecture (course ?course) (lecturer ?lecturer) (num ?n) (length 1))
	; that has not been placed
	(not (booked_lecture (course ?course) (num ?n)))

	; and an available venue slot
	?avslot1 <- (available_slot (week ?w) (day ?d) (period ?p) (room ?r))

	; convert period value to ts
	(period (value ?p) (timestring ?ts1))

	; and no other lecture from the same course is on that day
	(not (booked_lecture (week ?w) (day ?d) (course ?course)))
	
	; and the lecturer isn't already busy during that period
	(not (lecturer_busy (week ?w|*) (day ?d|*) (period ?ts1|*) (lecturer ?lecturer)))

	=>
	; no longer need these and they clutter fact list
	(retract ?f1 ?avslot1)
	
	(assert
		; book the lecture
		(booked_lecture (week ?w) (day ?d) (period ?ts1) (room ?r) (course ?course) (num ?n))

		; block the slot
		(blocked_slot (week ?w) (day ?d) (period ?ts1) (room ?r))
		
		; lecturer busy during that period
		(lecturer_busy (week ?w) (day ?d) (period ?ts1) (lecturer ?lecturer))
	)
)

(defrule place_double_lecture
	?f1 <- (lecture (course ?course) (lecturer ?lecturer) (num ?n) (length 2))
	; that has not been placed
	(not (booked_lecture (course ?course) (num ?n)))

	; and an available venue slot
	?avslot1 <- (available_slot (week ?w) (day ?d) (period ?p1) (room ?r))
	?avslot2 <- (available_slot (week ?w) (day ?d) (period ?p2) (room ?r))

	(test (eq (+ ?p1 1) ?p2))

	(period (value ?p1) (timestring ?ts1))
	(period (value ?p2) (timestring ?ts2))

	(not (booked_lecture (week ?w) (day ?d) (course ?course)))

	(not (lecturer_busy (week ?w|*) (day ?d|*) (period ?ts1|*) (lecturer ?lecturer)))
	(not (lecturer_busy (week ?w|*) (day ?d|*) (period ?ts2|*) (lecturer ?lecturer)))

	=>
	(retract ?f1 ?avslot1 ?avslot2)

	(assert
		; book the lecture
		(booked_lecture (week ?w) (day ?d) (period ?ts1) (room ?r) (course ?course) (num ?n))
		(booked_lecture (week ?w) (day ?d) (period ?ts2) (room ?r) (course ?course) (num ?n))

		; block the slot
		(blocked_slot (week ?w) (day ?d) (period ?ts1) (room ?r))
		(blocked_slot (week ?w) (day ?d) (period ?ts2) (room ?r))
		
		; lecturer busy during that period
		(lecturer_busy (week ?w) (day ?d) (period ?ts1) (lecturer ?lecturer))
		(lecturer_busy (week ?w) (day ?d) (period ?ts2) (lecturer ?lecturer))
	)
)

(defrule place_triple_lecture
	?f1 <- (lecture (course ?course) (lecturer ?lecturer) (num ?n) (length 3))
	; that has not been placed
	(not (booked_lecture (course ?course) (num ?n)))

	; and an available venue slot
	?avslot1 <- (available_slot (week ?w) (day ?d) (period ?p1) (room ?r))
	?avslot2 <- (available_slot (week ?w) (day ?d) (period ?p2) (room ?r))
	?avslot3 <- (available_slot (week ?w) (day ?d) (period ?p3) (room ?r))

	(test (eq (+ ?p1 1) ?p2))
	(test (eq (+ ?p1 2) ?p3))

	(period (value ?p1) (timestring ?ts1))
	(period (value ?p2) (timestring ?ts2))
	(period (value ?p3) (timestring ?ts3))

	(not (booked_lecture (week ?w) (day ?d) (course ?course)))

	(not (lecturer_busy (week ?w|*) (day ?d|*) (period ?ts1|*) (lecturer ?lecturer)))
	(not (lecturer_busy (week ?w|*) (day ?d|*) (period ?ts2|*) (lecturer ?lecturer)))
	(not (lecturer_busy (week ?w|*) (day ?d|*) (period ?ts3|*) (lecturer ?lecturer)))

	=>
	(retract ?f1 ?avslot1 ?avslot2 ?avslot3)

	(assert
		; book the lecture
		(booked_lecture (week ?w) (day ?d) (period ?ts1) (room ?r) (course ?course) (num ?n))
		(booked_lecture (week ?w) (day ?d) (period ?ts2) (room ?r) (course ?course) (num ?n))
		(booked_lecture (week ?w) (day ?d) (period ?ts3) (room ?r) (course ?course) (num ?n))

		; block the slot
		(blocked_slot (week ?w) (day ?d) (period ?ts1) (room ?r))
		(blocked_slot (week ?w) (day ?d) (period ?ts2) (room ?r))
		(blocked_slot (week ?w) (day ?d) (period ?ts3) (room ?r))
		
		; lecturer busy during that period
		(lecturer_busy (week ?w) (day ?d) (period ?ts1) (lecturer ?lecturer))
		(lecturer_busy (week ?w) (day ?d) (period ?ts2) (lecturer ?lecturer))
		(lecturer_busy (week ?w) (day ?d) (period ?ts3) (lecturer ?lecturer))
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
			(lecture (course ?c) (lecturer ?l) (num ?s) (length 1))
		)
	)
)

(deffunction print_timetable()
	(printout t crlf)
	(do-for-all-facts ((?week week)) TRUE
		(printout t crlf "Week " ?week:value " - " ?week:startdate crlf)
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
			(format t "|%-8s|" ?period:timestring)			
			(do-for-all-facts ((?day day)) TRUE	
				(bind ?slot_lectures (find-fact ((?bl booked_lecture)) (and (eq ?bl:week ?week:value) (eq ?bl:period ?period:timestring) (eq ?bl:day ?day:value))))	
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
				(bind ?slot_lectures (find-fact ((?bl booked_lecture)) (and (eq ?bl:week ?week:value) (eq ?bl:period ?period:timestring) (eq ?bl:day ?day:value))))	
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
	(week (value 1) (startdate "17 February"))
	(week (value 2) (startdate "24 February"))
	(week (value 3) (startdate "03 March"))
	(week (value 4) (startdate "10 March"))
	(week (value 5) (startdate "17 March"))
	(week (value 6) (startdate "24 March"))
	(week (value 7) (startdate "31 March"))

	; with 5 days
	(day (value "Monday"))
	(day (value "Tuesday"))
	(day (value "Wednesday"))
	(day (value "Thursday"))
	(day (value "Friday"))

	; with 7 periods
	(period (value 1) (timestring "08:00"))
	(period (value 2) (timestring "09:00"))
	(period (value 3) (timestring "10:00"))
	(period (value 4) (timestring "11:00"))
	(period (value 5) (timestring "12:00"))
	(period (value 6) (timestring "13:00"))
	(period (value 7) (timestring "14:00"))
	(period (value 8) (timestring "15:00"))
	(period (value 9) (timestring "16:00"))

	; and there are rooms
	(room (value "CSC LT 2A"))
	(room (value "CSC302"))
	(room (value "CSC303"))

	; and lecturers with the modules they teach X times
	(lectures (course "VIS") (lecturer "Michelle Kuttel") (count 20))
	(lectures (course "IR") (lecturer "Hussein Suleman") (count 16))
	(lectures (course "EC") (lecturer "Geoff Nitschke") (count 13))
	(lectures (course "NIS") (lecturer "Andrew Hutchison") (count 16))
	(lectures (course "ICT4D") (lecturer "Edwin Blake") (count 20))

	(lecture (course "IR") (lecturer "Hussein Suleman") (num 21) (length 3))
	
	; student advisors have their open office hours where they can't have lectures
	(lecturer_busy (week *) (day "Friday") (period "09:00") (lecturer "Michelle Kuttel"))
	(lecturer_busy (week *) (day "Wednesday") (period "10:00") (lecturer "Hussein Suleman"))
	
	; Room CSC303 is booked every Thursday during meridian for colloqiums
	(blocked_slot (week *) (day "Thursday") (period "13:00") (room "CSC303"))

	; in fact, nothing can happen at meridian 13:00
	(blocked_slot (week *) (day *) (period "13:00") (room *))
	
	; and students REALLY hate 8AM lectures
	(blocked_slot (week *) (day *) (period "08:00") (room *))

	; block things according to other timetables
	; CSC1015F
	(lecturer_busy (week *) (day "Monday") (period "11:00") (lecturer "Hussein Suleman"))
	(lecturer_busy (week *) (day "Tuesday") (period "11:00") (lecturer "Hussein Suleman"))
	(lecturer_busy (week *) (day "Wednesday") (period "11:00") (lecturer "Hussein Suleman"))
	(lecturer_busy (week *) (day "Thursday") (period "11:00") (lecturer "Hussein Suleman"))
	(lecturer_busy (week *) (day "Monday") (period "12:00") (lecturer "Hussein Suleman"))
	(lecturer_busy (week *) (day "Tuesday") (period "12:00") (lecturer "Hussein Suleman"))
	(lecturer_busy (week *) (day "Wednesday") (period "12:00") (lecturer "Hussein Suleman"))
	(lecturer_busy (week *) (day "Thursday") (period "12:00") (lecturer "Hussein Suleman"))

	; CSC1017F
	(lecturer_busy (week *) (day "Monday") (period "11:00") (lecturer "Audrey Mbogho"))
	(lecturer_busy (week *) (day "Tuesday") (period "11:00") (lecturer "Audrey Mbogho"))
	(lecturer_busy (week *) (day "Thursday") (period "11:00") (lecturer "Audrey Mbogho"))

	; CSC2001F
	(lecturer_busy (week 1) (day *) (period "09:00") (lecturer "Patrick Marais"))
	(lecturer_busy (week 2) (day *) (period "09:00") (lecturer "Audrey Mbogho"))
	(lecturer_busy (week 3) (day *) (period "09:00") (lecturer "Audrey Mbogho"))
	(lecturer_busy (week 4) (day *) (period "09:00") (lecturer "Audrey Mbogho"))
	(lecturer_busy (week 5) (day *) (period "09:00") (lecturer "Anne Kayem"))
	(lecturer_busy (week 6) (day *) (period "09:00") (lecturer "Anne Kayem"))
	(lecturer_busy (week 7) (day *) (period "09:00") (lecturer "Anne Kayem"))

	; CSC3002F
	(lecturer_busy (week 1) (day "Monday") (period "09:00") (lecturer "Anne Kayem"))
	(lecturer_busy (week 1) (day "Tuesday") (period "09:00") (lecturer "Anne Kayem"))
	(lecturer_busy (week 1) (day "Wednesday") (period "09:00") (lecturer "Anne Kayem"))
	(lecturer_busy (week 2) (day *) (period "09:00") (lecturer "Anne Kayem"))
	(lecturer_busy (week 3) (day "Monday") (period "09:00") (lecturer "Anne Kayem"))
	(lecturer_busy (week 3) (day "Tuesday") (period "09:00") (lecturer "Anne Kayem"))
	(lecturer_busy (week 3) (day "Wednesday") (period "09:00") (lecturer "Anne Kayem"))
	(lecturer_busy (week 3) (day "Thursday") (period "09:00") (lecturer "Anne Kayem"))
	(lecturer_busy (week 4) (day *) (period "09:00") (lecturer "Anne Kayem"))
	(lecturer_busy (week 5) (day *) (period "09:00") (lecturer "Edwin Blake"))
	(lecturer_busy (week 6) (day "Tuesday") (period "09:00") (lecturer "Edwin Blake"))
	(lecturer_busy (week 6) (day "Wednesday") (period "09:00") (lecturer "Edwin Blake"))
	(lecturer_busy (week 6) (day "Thursday") (period "09:00") (lecturer "Edwin Blake"))
	(lecturer_busy (week 6) (day "Friday") (period "09:00") (lecturer "Edwin Blake"))
	(lecturer_busy (week 7) (day "Monday") (period "09:00") (lecturer "Edwin Blake"))
	(lecturer_busy (week 7) (day "Tuesday") (period "09:00") (lecturer "Edwin Blake"))
	(lecturer_busy (week 7) (day "Wednesday") (period "09:00") (lecturer "Edwin Blake"))
	(lecturer_busy (week 7) (day "Thursday") (period "09:00") (lecturer "Edwin Blake"))

	; CSC3020H
	(lecturer_busy (week 1) (day "Monday") (period "10:00") (lecturer "Patrick Marais"))
	(lecturer_busy (week 1) (day "Wednesday") (period "10:00") (lecturer "Patrick Marais"))
	(lecturer_busy (week 2) (day "Monday") (period "10:00") (lecturer "Patrick Marais"))
	(lecturer_busy (week 2) (day "Wednesday") (period "10:00") (lecturer "Patrick Marais"))
	(lecturer_busy (week 3) (day "Monday") (period "10:00") (lecturer "Patrick Marais"))
	(lecturer_busy (week 3) (day "Wednesday") (period "10:00") (lecturer "Patrick Marais"))
	(lecturer_busy (week 4) (day "Monday") (period "10:00") (lecturer "Patrick Marais"))
	(lecturer_busy (week 4) (day "Wednesday") (period "10:00") (lecturer "Patrick Marais"))
	(lecturer_busy (week 5) (day "Monday") (period "10:00") (lecturer "Patrick Marais"))
	(lecturer_busy (week 5) (day "Wednesday") (period "10:00") (lecturer "Patrick Marais"))
	(lecturer_busy (week 6) (day "Monday") (period "10:00") (lecturer "Patrick Marais"))
	(lecturer_busy (week 6) (day "Wednesday") (period "10:00") (lecturer "Patrick Marais"))
	(lecturer_busy (week 7) (day "Monday") (period "10:00") (lecturer "Patrick Marais"))
	(lecturer_busy (week 7) (day "Wednesday") (period "10:00") (lecturer "Patrick Marais"))

	; CSC3022H
	(lecturer_busy (week 1) (day "Tuesday") (period "10:00") (lecturer "Simon Perkins"))
	(lecturer_busy (week 1) (day "Thursday") (period "10:00") (lecturer "Simon Perkins"))
	(lecturer_busy (week 2) (day "Tuesday") (period "10:00") (lecturer "Simon Perkins"))
	(lecturer_busy (week 2) (day "Thursday") (period "10:00") (lecturer "Simon Perkins"))
	(lecturer_busy (week 3) (day "Tuesday") (period "10:00") (lecturer "Simon Perkins"))
	(lecturer_busy (week 3) (day "Thursday") (period "10:00") (lecturer "Simon Perkins"))
	(lecturer_busy (week 4) (day "Tuesday") (period "10:00") (lecturer "Simon Perkins"))
	(lecturer_busy (week 4) (day "Thursday") (period "10:00") (lecturer "Simon Perkins"))
	(lecturer_busy (week 5) (day "Tuesday") (period "10:00") (lecturer "Simon Perkins"))
	(lecturer_busy (week 5) (day "Thursday") (period "10:00") (lecturer "Simon Perkins"))
	(lecturer_busy (week 6) (day "Tuesday") (period "10:00") (lecturer "Simon Perkins"))
	(lecturer_busy (week 6) (day "Thursday") (period "10:00") (lecturer "Simon Perkins"))
	(lecturer_busy (week 7) (day "Tuesday") (period "10:00") (lecturer "Simon Perkins"))
	(lecturer_busy (week 7) (day "Thursday") (period "10:00") (lecturer "Simon Perkins"))

	; HOLIDAYS!
	(blocked_slot (week 5) (day "Friday") (period *) (room *))






)

; reset all facts		 
(reset)
; load facts, run reasoning
(run)
; print the final timetable
(print_timetable)
; show any unscheduled lectures
(find_unplaced_lectures)
