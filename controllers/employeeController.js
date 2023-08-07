const inquirer = require("inquirer");
const connection = require("../connection");


const handleError = (err) => {
    if (err) throw err;
};

// Function to handle the main menu
function mainMenu() {
    inquirer
        .prompt([
            {
                type: "list",
                name: "menuOptions",
                message: "What would you like to do?",
                choices: [
                    "View All Employees",
                    "Add Employee",
                    "Update Employee Role",
                    "View All Roles",
                    "Add Role",
                    "View All Departments",
                    "Add Department",
                    "Quit"
                ]
            }
        ])
        .then((answer) => {
            switch (answer.menuOptions) {
                case "View All Employees":
                    viewAllEmployees();
                    break;
                case "Add Employee":
                    addEmployee();
                    break;
                case "Update Employee Role":
                    updateEmployeeRole();
                    break;
                case "View All Roles":
                    viewAllRoles();
                    break;
                case "Add Role":
                    addRole();
                    break;
                case "View All Departments":
                    viewAllDepartments();
                    break;
                case "Add Department":
                    addDepartment();
                    break;
                case "Quit":
                    connection.end();
                    console.log("Disconnected from the MySQL server.");
                    break;
                default:
                    break;
            }
        });
}

// Viewing functions
// Handle viewing all departments
function viewAllDepartments() {
    const query = "SELECT id, name FROM department";

    connection.query(query, (err, department) => {
        handleError(err);

        console.table(department);
        mainMenu();
    });
}

// Handle viewing all roles
function viewAllRoles() {
    const query = `
        SELECT
            role.title AS title,
            role.id AS role_id,
            department.name AS department,
            role.salary AS salary
        FROM
            role
        INNER JOIN
            department ON role.department_id = department.id
    `;

    connection.query(query, (err, roles) => {
        handleError(err);

        console.table(roles);
        mainMenu();
    });
}


// Function to handle viewing all employees
function viewAllEmployees() {
   
    const query = `
        SELECT
            employee.id,
            employee.first_name,
            employee.last_name,
            role.title AS title,
            department.name AS department,
            role.salary,
            CONCAT(manager.first_name, " ", manager.last_name) AS manager
        FROM
            employee
        INNER JOIN
            role ON employee.role_id = role.id
        INNER JOIN
            department ON role.department_id = department.id
        LEFT JOIN
            employee AS manager ON employee.manager_id = manager.id
    `;

    connection.query(query, (err, employee) => {
        handleError(err);

        console.table(employee);
        mainMenu();
    });
}

// Adding functions
// Handle adding a department
function addDepartment() {
    inquirer
        .prompt([
            {
                type: "input",
                name: "department",
                message: "What is the name of the department?"
            },
        ])
        .then((answer) => {
            const query = "INSERT INTO department (name) VALUES (?)";
            const values = [answer.department];

            connection.query(query, values, (err, res) => {
                handleError(err);

                console.log(`Added ${answer.department} to the database.`);
                mainMenu();
            });
        });
}

// Handle adding a role
function addRole() {
    const departmentQuery = "SELECT * FROM department";

    connection.query(departmentQuery, (err, department) => {
        handleError(err);

        inquirer
            .prompt([
                {
                    type: "input",
                    name: "role",
                    message: "What is the name of the role?"
                },
                {
                    type: "input",
                    name: "salary",
                    message: "What is the salary of the role?"
                },
                {
                    type: "list",
                    name: "roleDept",
                    message: "Which department does the role belong to?",
                    choices: department.map((department) => ({
                        name: department.name,
                        value: department.id
                    })),
                }
            ])
            .then((answer) => {
                const query = "INSERT INTO role (title, department_id, salary) VALUES (?, ?, ?)";
                const values = [answer.role, answer.roleDept, answer.salary];

                connection.query(query, values, (err, res) => {
                    handleError(err);

                    console.log(`Added ${answer.role} to the database.`);
                    mainMenu();
                });
            })
            .catch((error) => {
                handleError(error);
            });
    });
}

// Handle adding employee
function addEmployee() {
    const employeeQuery = "SELECT * FROM employee";
    const roleQuery = "SELECT * FROM role";

    connection.query(employeeQuery, (err, employee) => {
        handleError(err);

        connection.query(roleQuery, (err, role) => {
            handleError(err);

            inquirer
                .prompt([
                    {
                        type: "input",
                        name: "first_name",
                        message: "What is the employee's first name?"
                    },
                    {
                        type: "input",
                        name: "last_name",
                        message: "What is the employee's last name?"
                    },
                    {
                        type: "list",
                        name: "empRole",
                        choices: role.map((role) => ({
                            name: role.title,
                            value: role.id
                        })),
                    },
                    {
                        type: "list",
                        name: "empManager",
                        choices: employee.map((employee) => ({
                            name: `${employee.first_name} ${employee.last_name}`,
                            value: employee.id
                        })),
                    }
                ])
                .then((answer) => {
                    const query = "INSERT INTO employee (first_name, last_name, role_id, manager_id) VALUES (?, ?, ?, ?)";
                    const values = [answer.first_name, answer.last_name, answer.empRole, answer.empManager];

                    connection.query(query, values, (err, res) => {
                        handleError(err);

                        console.log(`Added ${answer.first_name} ${answer.last_name} to the database.`);
                        mainMenu();
                    });
                })
                .catch((error) => {
                    handleError(error);
                });
        });
    });
}

// Update functions
// Handle updating employee role
function updateEmployeeRole() {
    const employeeQuery = "SELECT * FROM employee";
    const roleQuery = "SELECT * FROM role";

    connection.query(employeeQuery, (err, employee) => {
        handleError(err);

        connection.query(roleQuery, (err, role) => {
            handleError(err);

            inquirer
                .prompt([
                    {
                        type: "list",
                        name: "employeeId",
                        message: "Which employee's role do you want to update?",
                        choices: employee.map((employee) => ({
                            name: `${employee.first_name} ${employee.last_name}`,
                            value: employee.id
                        })),
                    },
                    {
                        type: "list",
                        name: "roleId",
                        message: "Which role do you want to assign the selected employee?",
                        choices: role.map((role) => ({
                            name: role.title,
                            value: role.id
                        })),
                    },
                ])
                .then((answers) => {
                    const query = "UPDATE employee SET role_id = ? WHERE id = ?";
                    const values = [answers.roleId, answers.employeeId];

                    connection.query(query, values, (err, res) => {
                        handleError(err);

                        console.log("Updated employee's role.")
                        mainMenu();
                    });
                });
        });
    });
}

module.exports = {
    mainMenu,
    viewAllDepartments,
    viewAllRoles,
    viewAllEmployees,
    addDepartment,
    addRole,
    addEmployee,
    updateEmployeeRole
};