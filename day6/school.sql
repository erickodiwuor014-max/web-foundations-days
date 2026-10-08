PRAGMA foreign_keys = ON;

-- =========================================
-- DAY 6: SCHOOL DATABASE
-- =========================================

-- Students table
CREATE TABLE students (
    student_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE
);

-- Courses table
CREATE TABLE courses (
    course_id INTEGER PRIMARY KEY,
    course_name TEXT NOT NULL
);

-- Enrolments table
-- Links students and courses.
-- A student cannot enrol in the same course twice.
CREATE TABLE enrolments (
    enrolment_id INTEGER PRIMARY KEY,
    student_id INTEGER NOT NULL,
    course_id INTEGER NOT NULL,
    grade TEXT,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id),
    UNIQUE (student_id, course_id)
);

-- =========================================
-- SAMPLE STUDENTS
-- =========================================

INSERT INTO students (student_id, name, email)
VALUES
    (1, 'Erick Odiwuor', 'erick@example.com'),
    (2, 'Brian Otieno', 'brian@example.com'),
    (3, 'Mary Achieng', 'mary@example.com'),
    (4, 'John Onyango', 'john@example.com');

-- =========================================
-- SAMPLE COURSES
-- =========================================

INSERT INTO courses (course_id, course_name)
VALUES
    (1, 'Introduction to Programming'),
    (2, 'Database Systems'),
    (3, 'Web Development');

-- =========================================
-- SAMPLE ENROLMENTS
-- =========================================

INSERT INTO enrolments (enrolment_id, student_id, course_id, grade)
VALUES
    (1, 1, 1, 'A'),
    (2, 1, 2, 'B'),
    (3, 2, 1, 'B'),
    (4, 2, 3, 'A'),
    (5, 3, 2, 'C');

-- =========================================
-- QUERY 1:
-- All courses for one student by name
-- =========================================

SELECT
    students.name AS student_name,
    courses.course_name,
    enrolments.grade
FROM students
JOIN enrolments
    ON students.student_id = enrolments.student_id
JOIN courses
    ON enrolments.course_id = courses.course_id
WHERE students.name = 'Erick Odiwuor';

-- =========================================
-- QUERY 2:
-- All students on one course
-- =========================================

SELECT
    courses.course_name,
    students.name AS student_name
FROM courses
JOIN enrolments
    ON courses.course_id = enrolments.course_id
JOIN students
    ON enrolments.student_id = students.student_id
WHERE courses.course_name = 'Introduction to Programming';

-- =========================================
-- QUERY 3:
-- Number of students per course
-- =========================================

SELECT
    courses.course_name,
    COUNT(enrolments.student_id) AS number_of_students
FROM courses
LEFT JOIN enrolments
    ON courses.course_id = enrolments.course_id
GROUP BY courses.course_id, courses.course_name;

-- =========================================
-- QUERY 4:
-- Students who have no enrolments
-- =========================================

SELECT
    students.student_id,
    students.name,
    students.email
FROM students
LEFT JOIN enrolments
    ON students.student_id = enrolments.student_id
WHERE enrolments.enrolment_id IS NULL;

-- =========================================
-- QUERY 5:
-- Update one enrolment's grade
-- =========================================

UPDATE enrolments
SET grade = 'A'
WHERE enrolment_id = 5;

-- Check the updated enrolment
SELECT *
FROM enrolments
WHERE enrolment_id = 5;