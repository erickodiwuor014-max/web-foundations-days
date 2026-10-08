\# School Database Design



\## Students Table



The `students` table stores information about each student. It contains the student's ID, name and email address. The `student\_id` is the primary key and uniquely identifies each student. The email address is also UNIQUE so that two students cannot use the same email address.



\## Courses Table



The `courses` table stores the courses offered by the school. It contains a `course\_id` as the primary key and the `course\_name` of each course.



\## Enrolments Table



The `enrolments` table records the fact that a student is enrolled in a particular course. It contains the student's ID, the course ID and the student's grade. The `student\_id` and `course\_id` are foreign keys that connect the enrolments table to the students and courses tables. The combination of `student\_id` and `course\_id` is UNIQUE so that the same student cannot enrol in the same course twice.



\## Relationships



There is a one-to-many relationship between students and enrolments. One student can have many enrolments, while each enrolment belongs to one student.



There is also a one-to-many relationship between courses and enrolments. One course can have many enrolments, while each enrolment belongs to one course.



Students and courses have a many-to-many relationship because one student can take many courses and one course can have many students. The `enrolments` table is needed as a join table to represent this many-to-many relationship. It also stores information specific to the relationship, such as the student's grade.



\## Index



I would add an index on `enrolments.course\_id` because courses are frequently searched to find all students enrolled in a particular course. An index on this column can make those searches faster, especially when the database becomes larger.



For example:



```sql

CREATE INDEX idx\_enrolments\_course\_id

ON enrolments(course\_id);

