const connection = require('./connection.js');

class DB{
   constructor (connection){
    this.connection = connection
}

    viewAlldepartments(){
        return this.connection.promise().query(
            `SELECT * FROM department`
        )
    }




}

module.exports = new DB(connection);



const inquirer = require("inquirer");
const mysql = require("mysql2");

const connection = require("./connection");
const employeeController = require("./controllers/employeeController");
const fs = require("fs");


fs.readFile("./db/schema.sql", "utf8", (err, data) => {
    if (err) throw err;
});

employeeController.mainMenu();