module(..., package.seeall)

require("sqlite3")

---- local variables and constants
local database = nil
-- database query strings
local data_SelectAllFromGrade = [[ Select * from grade; ]]
local data_SelectAllStudentsAndGrades = [[ 
    Select student.id as studentid, student.name as name, grade.name as grade 
    from student, grade 
    where student.gradeid == grade.id; 
    ]]

function checkDataBaseState()
    if (database == nil or database.isopen(database) == false) then
        local path = system.pathForFile("data.db", system.DocumentsDirectory)
        database = sqlite3.open(path)
    end
end

function getSingleStudent(id)
    local query;
    
    if (id == nil) then
      query = 'SELECT * FROM student LIMIT 1'
    else
      query = [[ Select student.id as studentid, student.name as name, grade.name as grade
        from student, grade 
        where student.gradeid == grade.id
        AND student.id = ]] .. id .. [[ ; ]]
    end
    
    checkDataBaseState{}

    local student = nil
    
    for a in database:nrows(query) do
        student = a
    end
    return student
end

function initialize()
    checkDataBaseState{}
    
    -- remove all tables (only for design phase so we can quickly update db structure)
    database:execute(
    [[ 
        drop table if exists grade;
        drop table if exists student;
        drop table if exists lessonType;
        drop table if exists results;
    ]])
    
    -- initializes tables for the app
    database:execute(
    [[ 
        PRAGMA foreign_keys = ON;
        CREATE TABLE if not exists grade 
            (id integer PRIMARY KEY, name text, active integer);
        CREATE TABLE if not exists student 
            (id integer PRIMARY KEY, gradeid integer, 
            name text, active integer,
            FOREIGN KEY(gradeid) REFERENCES grade(id)); 
        CREATE TABLE if not exists lessonType 
            (id integer PRIMARY KEY, gradeid integer, 
            name text, active integer,
            FOREIGN KEY(gradeid) REFERENCES grade(id)); 
        CREATE TABLE if not exists results 
            (id integer PRIMARY KEY, lessonid integer, studentid integer,
            date integer, active integer,
            FOREIGN KEY(lessonid) REFERENCES lessonType(id),
            FOREIGN KEY(studentid) REFERENCES student(id)); 
    ]])
       
    -- populate database with initial entries (if any)
    database:execute(
    [[
        insert into grade values(null, 'Kindergarten', 1);
        insert into grade values(null, '1st', 1);
        insert into grade values(null, '2nd', 1);
        insert into grade values(null, '3rd', 1);
        
        insert into student values(null, 3, 'Ava', 1);
        insert into student values(null, 1, 'Alex', 1);
    ]])
end