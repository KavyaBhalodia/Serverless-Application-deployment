import React, { useState, useEffect } from "react";
import axios from "axios";

// const API_BASE_URL =
//   "https://lcx16t5xu2.execute-api.us-east-1.amazonaws.com/Dev";

const API_BASE_URL = process.env.REACT_APP_API_INVOKE_URL;
console.log("API_BASE_URL",API_BASE_URL)
const App = () => {
  const [students, setStudents] = useState([]);
  const [newStudent, setNewStudent] = useState({
    studentId: "",
    name: "",
    email: "",
  });

  useEffect(() => {
    fetchStudents();
  }, []);

  const fetchStudents = async () => {
    try {
      const response = await axios.get(`${process.env.REACT_APP_API_INVOKE_URL}Dev/students`);
      console.log("response-fetchStudents",response)
      setStudents(response.data.students);
    } catch (error) {
      console.error("Error fetching students:", error);
    }
  };

  const addStudent = async () => {
    try {
      await axios.post(`${process.env.REACT_APP_API_INVOKE_URL}Dev/student`, newStudent);
      console.log("newstudent",newStudent)
      fetchStudents(); // Refresh the list after adding
    } catch (error) {
      console.error("Error adding student:", error);
    }
  };

  const deleteStudent = async (studentId) => {
    try {
      const payload = { studentId }; // Construct the request payload
      const response = await axios.delete(`${process.env.REACT_APP_API_INVOKE_URL}Dev/student`, {
        data: payload,
      });
      console.log("Response from delete:", response.data); // Log the response body
      fetchStudents(); // Refresh the list after deleting
      return response.data; // Return the response body
    } catch (error) {
      console.error("Error deleting student:", error);
      return { error: "Delete operation failed" }; // Return an error message in case of failure
    }
  };

  return (
    <div>
      <h3>{API_BASE_URL}</h3>
      <h1>Students</h1>
      <ul>
        {students.map((student) => (
          <li key={student.studentId}>
            {student.name} - {student.email}
            <button onClick={() => deleteStudent(student.studentId)}>
              Delete
            </button>
          </li>
        ))}
      </ul>
      <h2>Add New Student</h2>
      <form
        onSubmit={(e) => {
          e.preventDefault();
          addStudent();
        }}
      >
        <input
          type="text"
          placeholder="Student ID"
          value={newStudent.studentId}
          onChange={(e) =>
            setNewStudent({ ...newStudent, studentId: e.target.value })
          }
        />
        <input
          type="text"
          placeholder="Name"
          value={newStudent.name}
          onChange={(e) =>
            setNewStudent({ ...newStudent, name: e.target.value })
          }
        />
        <input
          type="email"
          placeholder="Email"
          value={newStudent.email}
          onChange={(e) =>
            setNewStudent({ ...newStudent, email: e.target.value })
          }
        />
        {/* Add other input fields as needed */}
        <button type="submit">Add Student</button>
      </form>
    </div>
  );
};

export default App;