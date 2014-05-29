(assert
	
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
	(room (value "CS LT 2A"))
	(room (value "CS302"))
	(room (value "CS303"))

	; and lecturers with the modules they teach X times

	; VIS is double and triple lectures
	(lecture (course "VIS") (lecturer "Michelle Kuttel") (num 1) (length 2))
	(lecture (course "VIS") (lecturer "Michelle Kuttel") (num 2) (length 2))
	(lecture (course "VIS") (lecturer "Michelle Kuttel") (num 3) (length 2))
	(lecture (course "VIS") (lecturer "Michelle Kuttel") (num 4) (length 2))
	(lecture (course "VIS") (lecturer "Michelle Kuttel") (num 5) (length 3))
	(lecture (course "VIS") (lecturer "Michelle Kuttel") (num 6) (length 3))
	(lecture (course "VIS") (lecturer "Michelle Kuttel") (num 7) (length 3))
	(lecture (course "VIS") (lecturer "Michelle Kuttel") (num 8) (length 3))
	(lecture (course "VIS") (lecturer "Michelle Kuttel") (num 9) (length 3))

	; IR is 16 singles
	(lectures (course "IR") (lecturer "Hussein Suleman") (count 16))
	; but not on fridays
	(lecturer_busy (week *) (day "Friday") (period *) (lecturer "Hussein Suleman"))

	; EC is also singles with some others at the end
	(lectures (course "EC") (lecturer "Geoff Nitschke") (count 10))
	(lecture (course "EC") (lecturer "Geoff Nitschke") (num 11) (length 3))
	(lecture (course "EC") (lecturer "Geoff Nitschke") (num 12) (length 2))
	(lecture (course "EC") (lecturer "Geoff Nitschke") (num 13) (length 2))

	; NIS is all doubles
	(lecture (course "NIS") (lecturer "Andrew Hutchison") (num 1) (length 2))
	(lecture (course "NIS") (lecturer "Andrew Hutchison") (num 2) (length 2))
	(lecture (course "NIS") (lecturer "Andrew Hutchison") (num 3) (length 2))
	(lecture (course "NIS") (lecturer "Andrew Hutchison") (num 4) (length 2))
	(lecture (course "NIS") (lecturer "Andrew Hutchison") (num 5) (length 2))
	(lecture (course "NIS") (lecturer "Andrew Hutchison") (num 6) (length 2))
	(lecture (course "NIS") (lecturer "Andrew Hutchison") (num 7) (length 2))

	; ICT4D is all singles
	(lectures (course "ICT4D") (lecturer "Edwin Blake") (count 24))
	; but not on fridays
	(lecturer_busy (week *) (day "Friday") (period *) (lecturer "Edwin Blake"))

	; student advisors have their open office hours where they can't have lectures
	(lecturer_busy (week *) (day "Friday") (period "09:00") (lecturer "Michelle Kuttel"))
	(lecturer_busy (week *) (day "Wednesday") (period "10:00") (lecturer "Hussein Suleman"))
	
	; Room CSC303 is booked every Thursday during meridian for colloqiums
	(blocked_slot (week *) (day "Thursday") (period "13:00") (room "CS303"))

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

	; sprinkle some blocked rooms around
	;(blocked_slot (week *) (day "Monday") (period *) (room "CS303"))

)
