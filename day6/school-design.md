\# School Database Design



\## Students Table



The students table stores information about each student. It contains the student's ID, name and email address. The ID is the primary key, and the email address must be unique.



\## Courses Table



The courses table stores information about the courses offered by the school. It contains the course ID and course name. The ID is the primary key.



\## Enrolments Table



The enrolments table records which students are enrolled in which courses. It contains the student ID, course ID and grade. It also has its own primary key.



\## Relationships



The relationship between students and enrolments is one-to-many because one student can have many enrolments, while each enrolment belongs to one student.



The relationship between courses and enrolments is one-to-many because one course can have many enrolments, while each enrolment belongs to one course.



Students and courses have a many-to-many relationship because one student can take many courses and one course can have many students. The enrolments table is needed as a join table to connect students and courses. It also stores information about the enrolment, such as the student's grade.



\## Index



I would add an index on `enrolments.student\_id` because it would make finding all enrolments belonging to a particular student faster, especially when the database becomes large.



\## SQL or NoSQL



I would choose SQL for this school system because the data has clear relationships between students, courses and enrolments. A relational database such as SQLite makes it easy to enforce primary keys, foreign keys, unique emails and other rules. SQL also makes it easy to use JOIN and GROUP BY queries to retrieve related information. Therefore, SQL is a good choice for this structured system.

