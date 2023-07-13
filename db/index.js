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