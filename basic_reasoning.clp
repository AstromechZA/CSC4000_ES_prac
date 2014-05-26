; lecturers can have blocked periods
(deftemplate blocked_period (slot week) (slot day) (slot hour))




; create all of the available slots
(defrule create_available_slots
	; a slot
	(week ?w) (day ?d) (period ?p) (room ?r)
	; that is free and not blocked
	(not (available_slot ?w ?d ?p ?r))
	(not (blocked_slot ?w ?d ?p ?r))
	=>
	; m
	(assert 
		(available_slot ?w ?d ?p ?r)
	)
)

(defrule place_a_lecture
	; theres a lecture
	(lecture ?course ?lecturer ?n)
	; that has not been placed
	(not (booked_lecture ?wx ?dx ?px ?rx ?course ?n))

	; and an available slot
	(available_slot ?w ?d ?p ?r)
	; that hasnt been blocked
	(not (blocked_slot ?w ?d ?p ?r))

	; and no other lecture from the same course on that day
	(not (booked_lecture ?w ?d ?p2 ?r2 ?course ?n2))

	=>
	(assert
		; book the lecture
		(booked_lecture ?w ?d ?p ?r ?course ?n)
		; block the slot
		(blocked_slot ?w ?d ?p ?r)
	)
)

(defrule split_course
	?f <- (course ?course ?lecturer ?num_lectures)
	(test (> ?num_lectures 1))
	=>
	(retract ?f)
	(assert
		(lecture ?course ?lecturer ?num_lectures)
		(course ?course ?lecturer (- ?num_lectures 1))
	)
)
(defrule split_course2
	?f <- (course ?course ?lecturer ?num_lectures)
	(test (eq ?num_lectures 1))
	=>
	(retract ?f)
	(assert
		(lecture ?course ?lecturer ?num_lectures)
	)
)

(defrule startup
	=>
	(printout t "Startup" crlf)
	(assert
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
		(period h1400)
		(period h1500)

		; and there are rooms
		(room CSC303)

		(course VIS "Michelle Kuttel" 20)
		(course IR "Hussein Suleman" 20)
	)
)

(reset)
(run)
(facts)