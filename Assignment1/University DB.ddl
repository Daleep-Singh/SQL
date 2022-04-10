---------------------------------------------
--              CREATORS:
--        DALEEP SINGH, 1001699432
--        SHARON ALEX,  1003854206
--------------------------------------------

CREATE TABLE IF NOT EXISTS Campus (
    address VARCHAR(100) NOT NULL,
    campus_id INT PRIMARY KEY,
    campus_name VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS Person (
    utorID VARCHAR(10) PRIMARY KEY,
    sin NUMERIC(10),
    eid NUMERIC(10), -- this should not be null! this shows the partial participation for employee!
    date_of_birth DATE NOT NULL,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(30) NOT NULL,
    student_id NUMERIC(10),
    campus_id INT,
    CONSTRAINT PersonCampus FOREIGN KEY (campus_id) REFERENCES Campus(campus_id)
);

CREATE TABLE IF NOT EXISTS Employee (
    personal_num VARCHAR(11) NOT NULL,
    eid NUMERIC(10) PRIMARY KEY,
    sin NUMERIC(10) NOT NULL,
    utorID VARCHAR(10),
    staff BOOLEAN,
    faculty BOOLEAN,
    librarian BOOLEAN,
    full_time BOOLEAN,
    part_time BOOLEAN,
    CONSTRAINT Employee_SIN FOREIGN KEY(utorID) REFERENCES Person(utorID) ON DELETE CASCADE
);
    
--Employee Weak entity set 1
CREATE TABLE IF NOT EXISTS Role(
    staff BOOLEAN,
    faculty BOOLEAN,
    librarian BOOLEAN,
    eid NUMERIC(10) PRIMARY KEY,
    CONSTRAINT RoleForeignKey FOREIGN KEY(eid) REFERENCES Employee(eid)
);

-- Employee Weak entity set 2
CREATE TABLE IF NOT EXISTS EmployeeStatus (
    full_time BOOLEAN,
    part_time BOOLEAN,
    eid NUMERIC(10) PRIMARY KEY,
    CONSTRAINT StatusForeignKey FOREIGN KEY(eid) REFERENCES Employee(eid)
);
CREATE TABLE IF NOT EXISTS Faculty (
    faculty_name VARCHAR(30) NOT NULL,
    deans_eid NUMERIC(10)  UNIQUE NOT NULL,
    personal_number VARCHAR(11) NOT NULL,
    campus_id INT,
    PRIMARY KEY(faculty_name, campus_id),
    CONSTRAINT FacultyEmployeeForeignKey FOREIGN KEY(deans_eid) REFERENCES Employee(eid),
    CONSTRAINT FacultyForeignKey FOREIGN KEY(campus_id) REFERENCES Campus(campus_id)
);
CREATE TABLE IF NOT EXISTS Department (
    department_name VARCHAR(20) NOT NULL,
    department_id INT PRIMARY KEY,
    department_phone_number VARCHAR(11) NOT NULL, 
    faculty_name VARCHAR(30),
    campus_id INT,
    CONSTRAINT DepartmentForeignKey FOREIGN KEY(faculty_name,campus_id) REFERENCES Faculty(faculty_name,campus_id)
);

CREATE TABLE IF NOT EXISTS DepartmentChair (
    department_id INT NOT NULL,
    chair_eid NUMERIC(10),
    PRIMARY KEY(chair_eid, department_id),
    CONSTRAINT DepartmentChairForeignKey FOREIGN KEY(chair_eid) REFERENCES Employee(eid),
    CONSTRAINT DepartDepartID FOREIGN KEY (department_id) REFERENCES Department(department_id)
);
CREATE TABLE IF NOT EXISTS Manages (
    department_id INT,
    deans_eid NUMERIC(10)  UNIQUE NOT NULL,
    campus_id INT,
    CONSTRAINT FacultyManagesForeignKey FOREIGN KEY(deans_eid) REFERENCES Employee(eid),
    CONSTRAINT FacultyDepartmentManagesForeignKey FOREIGN KEY(department_id) REFERENCES Department(department_id),
    CONSTRAINT FacultyCampusManagesForeignKey FOREIGN KEY(campus_id) REFERENCES Campus(campus_id)
);

CREATE TABLE IF NOT EXISTS Professor (
    eid NUMERIC(10),
    tenure_stream BOOLEAN,
    teaching_stream BOOLEAN,
    clta BOOLEAN,
    professor BOOLEAN,
    assistant_professor BOOLEAN,
    associate_professor BOOLEAN,
    utorID VARCHAR(10),
    PRIMARY KEY (eid),
    CONSTRAINT Professor_Person FOREIGN KEY(utorID) REFERENCES Person(utorID),
    CONSTRAINT Professor_eid FOREIGN KEY(eid) REFERENCES Employee(eid) ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS CourseCoordinator (
    course_coordinator_eid NUMERIC(10) PRIMARY KEY,
    CONSTRAINT CourseCoordinatorForeignKey FOREIGN KEY(course_coordinator_eid) REFERENCES Professor(eid) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Course (
    course_code VARCHAR(20) NOT NULL,
    session_offered VARCHAR(15) NOT NULL,
    course_coordinator_eid NUMERIC(10)  UNIQUE NOT NULL,
    professor_eid NUMERIC(10)  UNIQUE NOT NULL,
    lecture_time VARCHAR(20) NOT NULL,
    PRIMARY KEY (course_code, session_offered),
    CONSTRAINT CourseForeignKey FOREIGN KEY(course_coordinator_eid) REFERENCES CourseCoordinator(course_coordinator_eid),
    CONSTRAINT CourseProfessorForeignKey FOREIGN KEY(professor_eid) REFERENCES Professor(eid)
);
CREATE TABLE IF NOT EXISTS Coordinates (
    course_code VARCHAR(20),
    session_offered VARCHAR(15),
    course_coordinator_eid NUMERIC(10),
    PRIMARY KEY(course_code, session_offered, course_coordinator_eid),
    CONSTRAINT CoordinatesForeignKey FOREIGN KEY(course_coordinator_eid) REFERENCES CourseCoordinator(course_coordinator_eid),
    CONSTRAINT CoordinatesCodeForeignKey FOREIGN KEY(course_code,session_offered) REFERENCES Course(course_code,session_offered)
);

CREATE TABLE IF NOT EXISTS Offers (
    department_id INT,
    course_code VARCHAR(20) NOT NULL,
    session_offered VARCHAR(15) NOT NULL,
    PRIMARY KEY (department_id, course_code, session_offered),
    CONSTRAINT OffersCourseForeignKey FOREIGN KEY(department_id) REFERENCES Department(department_id),
    CONSTRAINT OffersCourseCodeForeignKey FOREIGN KEY(course_code,session_offered) REFERENCES Course(course_code,session_offered)
    
);
CREATE TABLE IF NOT EXISTS Student (
    student_id NUMERIC(10) PRIMARY KEY,
    sin NUMERIC(10) NOT NULL,
    emerg_contact_name VARCHAR(60) NOT NULL,
    emerg_contact_num VARCHAR(11) NOT NULL,
    campus_id INT,
    course_code VARCHAR(20),
    session_offered VARCHAR(15),
    utorID VARCHAR(10),
    eid NUMERIC(10),

    CONSTRAINT Student_CourseCode FOREIGN KEY(course_code,session_offered) REFERENCES Course(course_code,session_offered),
    CONSTRAINT Student_campus_id FOREIGN KEY(campus_id) REFERENCES Campus(campus_id) ON DELETE CASCADE,
    CONSTRAINT StudentPerson FOREIGN KEY(utorID) REFERENCES Person(utorID) ON DELETE CASCADE
);  

CREATE TABLE IF NOT EXISTS StudentStatus (
    full_time BOOLEAN,
    part_time BOOLEAN,
    student_id NUMERIC(10) PRIMARY KEY,
    CONSTRAINT StatusForeignKey FOREIGN KEY(student_id) REFERENCES Student(student_id)
);
    
CREATE TABLE IF NOT EXISTS FinalMark (
    course_code VARCHAR(20),
    session_offered VARCHAR(15),
    letter_grade VARCHAR(1),
    numerical_grade INTEGER,
    student_id NUMERIC(10),
    PRIMARY KEY(student_id, course_code),
    CONSTRAINT FinalMarkForeignKey FOREIGN KEY(student_id) REFERENCES Student(student_id),
    CONSTRAINT FinalMarkCourseForeignKey FOREIGN KEY(course_code,session_offered) REFERENCES Course(course_code,session_offered)

);

CREATE TABLE IF NOT EXISTS TeachingAssistant (
    eid NUMERIC(10),
    contract_hours INT NOT NULL CHECK (contract_hours > 0),
    number_of_courses_TAing INT NOT NULL,
    course_code_ta_for VARCHAR(15) NOT NULL,
    student_id NUMERIC(10),
    sin NUMERIC(10) NOT NULL,
    campus_id INT,
    utorID VARCHAR(10),
    PRIMARY KEY (eid,utorID,student_id),
    CONSTRAINT TAEmployee FOREIGN KEY (eid) REFERENCES Employee(eid) ON DELETE CASCADE,
    CONSTRAINT TAStudent FOREIGN KEY (student_id) REFERENCES Student(student_id) ON DELETE CASCADE,
    CONSTRAINT TACampus FOREIGN KEY (campus_id) REFERENCES Campus(campus_id) ON DELETE CASCADE,
    CONSTRAINT TAPerson FOREIGN KEY (utorID) REFERENCES Person(utorID) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS Teaches (
    eid NUMERIC(10),
    course_code VARCHAR(20) NOT NULL,
    session_offered VARCHAR(15) NOT NULL,
    PRIMARY KEY (eid, course_code, session_offered),
    CONSTRAINT TeachesForeignKey FOREIGN KEY(eid) REFERENCES Professor(eid),
    CONSTRAINT TeachesCourseForeignKey FOREIGN KEY(course_code,session_offered) REFERENCES Course(course_code,session_offered)

);
CREATE TABLE IF NOT EXISTS Type(
    tenure_stream BOOLEAN,
    teaching_stream BOOLEAN,
    clta BOOLEAN,
    eid NUMERIC(10) PRIMARY KEY,
    CONSTRAINT TypeForeignKey FOREIGN KEY(eid) REFERENCES Professor(eid)
);

CREATE TABLE IF NOT EXISTS Rank(
    professor BOOLEAN,
    assistant_professor BOOLEAN,
    associate_professor BOOLEAN,
    eid NUMERIC(10) PRIMARY KEY,
    CONSTRAINT RankForeignKey FOREIGN KEY(eid) REFERENCES Professor(eid)
);



CREATE TABLE IF NOT EXISTS BelongsTo(
    campus_id INT,
    student_id NUMERIC(10),
    PRIMARY KEY (campus_id,student_id),
    CONSTRAINT BelongsToCampusId FOREIGN KEY (campus_id) REFERENCES Campus(campus_id),
    CONSTRAINT BelongsToStudentId FOREIGN KEY (student_id) REFERENCES Student(student_id)
);
    
CREATE TABLE IF NOT EXISTS Hires(
    campus_id INT,
    eid NUMERIC(10),
    PRIMARY KEY (campus_id, eid),
    CONSTRAINT HiresCampus FOREIGN KEY (campus_id) REFERENCES Campus(campus_id),
    CONSTRAINT HiresEmployee FOREIGN KEY (eid) REFERENCES Employee(eid)
);

CREATE TABLE IF NOT EXISTS Enrolls(
    student_id NUMERIC(10),
    course_code VARCHAR(20),
    session_offered VARCHAR(15),
    PRIMARY KEY (student_id,course_code,session_offered),
    CONSTRAINT EnrollsStudent FOREIGN KEY (student_id) REFERENCES Student(student_id),
    CONSTRAINT EnrollsCourseSession FOREIGN KEY (course_code,session_offered) REFERENCES Course(course_code,session_offered)
);

CREATE TABLE IF NOT EXISTS Gives(
    course_code VARCHAR(20),
    session_offered VARCHAR(15),
    student_id NUMERIC(10),
    PRIMARY KEY(session_offered,course_code,student_id),
    CONSTRAINT GivesCourse FOREIGN KEY (course_code,session_offered) REFERENCES Course(course_code,session_offered),
    CONSTRAINT GivesStudent FOREIGN KEY (student_id) REFERENCES Student(student_id)
);

--INSERTIONS
INSERT INTO Campus(address,campus_id,campus_name)
VALUES ('501 Mississauga rd',2,'UTM');

INSERT INTO Campus(address,campus_id,campus_name)
VALUES ('501 stgeorge rd',2,'UTSG');

