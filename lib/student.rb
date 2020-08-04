require_relative "../config/environment.rb"

class Student

  attr_accessor :name, :grade
  attr_reader :id

  def initialize(id = nil, name, grade)
    @id = id 
    @name = name
    @grade = grade 
  end 

  def self.create_table
    sql = <<-SQL
      CREATE TABLE students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      );
    SQL

    DB[:conn].execute(sql)
  end 

  def self.drop_table 
    sql = <<-SQL
      DROP TABLE students;
    SQL

    DB[:conn].execute(sql)
  end 

  def save 
    if self.id 
      self.update
    else 
    sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.grade)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students;")[0][0]
    end 
  end 

  def self.create(name, grade)
    student = self.new(name, grade)
    student.save 
    student 
  end

  def self.new_from_db(row_array)
    student = self.new(row_array[0], row_array[1], row_array[2])
  end 

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students
      WHERE name = ?
      LIMIT 1
    SQL

    results = DB[:conn].execute(sql, name)[0]
    self.new_from_db(results)
  end 

  def update
    sql = <<-SQL
      UPDATE students SET name = ?, grade = ? WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end 





end
