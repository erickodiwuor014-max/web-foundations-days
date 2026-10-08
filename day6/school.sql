-- Day 6: School Database

CREATE TABLE students (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE
);

CREATE TABLE courses (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL
);

CREATE TABLE enrolments (
    id INTEGER PRIMARY KEY,
    student_id INTEGER NOT NULL,
    course_id INTEGER NOT NULL,
    grade TEXT,
    FOREIGN KEY (student_id) REFERENCES students(id),
    FOREIGN KEY (course_id) REFERENCES courses(id),
    UNIQUE (student_id, course_id)
);

INSERT INTO students (id, name, email) VALUES
(1, 'Erick Odiwuor', 'erick@example.com'),
(2, 'Brian Otieno', 'brian@example.com'),
(3, 'Mary Achieng', 'mary@example.com');

INSERT INTO courses (id, name) VALUES
(1, 'Database Systems'),
(2, 'Web Development'),
(3, 'Computer Networks');

INSERT INTO enrolments (id, student_id, course_id, grade) VALUES
(1, 1, 1, 'A'),
(2, 1, 2, 'B'),
(3, 2, 1, 'B'),
(4, 2, 3, 'A'),
(5, 3, 2, 'A');

-- All courses for one student
SELECT
    students.name AS student_name,
    courses.name AS course_name,
    enrolments.grade
FROM students
JOIN enrolments ON students.id = enrolments.student_id
JOIN courses ON courses.id = enrolments.course_id
WHERE students.name = 'Erick Odiwuor';

-- All students on one course
SELECT
    courses.name AS course_name,
    students.name AS student_name
FROM courses
JOIN enrolments ON courses.id = enrolments.course_id
JOIN students ON students.id = enrolments.student_id
WHERE courses.name = 'Database Systems';

-- Number of students per course
SELECT
    courses.name AS course_name,
    COUNT(enrolments.student_id) AS student_count
FROM courses
LEFT JOIN enrolments ON courses.id = enrolments.course_id
GROUP BY courses.id, courses.name;

-- Students who have no enrolments
SELECT
    students.id,
    students.name,
    students.email
FROM students
LEFT JOIN enrolments ON students.id = enrolments.student_id
WHERE enrolments.id IS NULL;

-- Update one enrolment's grade
UPDATE enrolments
SET grade = 'A+'
WHERE student_id = 1
  AND course_id = 2;