require_relative "../config/environment.rb"

class Student
  attr_accessor :id, :name, :grade

  def initialize(id = nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

# create a database table with columns matching the attributes for a Student instance
  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

# delete the students database table
  def self.drop_table
    sql = "DROP TABLE students"
    DB[:conn].execute(sql)
  end

# if the student instance already has a corresponding table row, update that row
# if not...
# insert a new row into the students table with the attributes of the student instance and...
# assign that row's id value as an attribute to the student instance
  def save
    if self.id
      self.update
    else
      sql = "INSERT INTO students (name, grade) VALUES (?, ?)"
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

# update the corresponding table row for the student instance
  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

# create a student instance, save it to the students table, and return the instance
  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
    student
  end

# creates and returns a new Student object using a row from the students table passed as an argument
  def self.new_from_db(row)
    student = self.new(row[0], row[1], row[2])
    student
  end

# returns a student object for the table row corresponding to the name passed as an argument
  def self.find_by_name(name)
    sql = "SELECT * FROM students WHERE students.name = ? LIMIT 1"

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

end
