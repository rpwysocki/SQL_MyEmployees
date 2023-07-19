SELECT manager_id
    CASE manager_id WHEN INT THEN employee(id)
                    
    * `manager_id`: `INT` to hold reference to another employee that is the manager of the current employee (`null` if the employee has no manager)





const inquirer = require("inquirer");
const connection = require("../connection");

// This shows up in every function. Now I can easily call it.
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
                    // BONUS:
                    // "Update Employee Managers",
                    // "View By Manager",
                    // "View By Department",
                    // "Delete Options", // Departments, roles, employees
                    // "View Budget" // View total utilized budget of a department - the combined salaries of all employees in that department
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
                // BONUSes here
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
    const query = "SELECT id, name FROM departments";

    connection.query(query, (err, departments) => {
        handleError(err);

        console.table(departments);
        mainMenu();
    });
}

// Handle viewing all roles
function viewAllRoles() {
    const query = `
        SELECT
            roles.title AS title,
            roles.id AS role_id,
            departments.name AS department,
            roles.salary AS salary
        FROM
            roles
        INNER JOIN
            departments ON roles.department_id = departments.id
    `;

    connection.query(query, (err, roles) => {
        handleError(err);

        console.table(roles);
        mainMenu();
    });
}


// Function to handle viewing all employees
function viewAllEmployees() {
    // ChatGPT says that this is why my table isn't displaying what I want it to.
    // const query = "SELECT * FROM employees";
    // ChatGPT's solution:
    const query = `
        SELECT
            employees.id,
            employees.first_name,
            employees.last_name,
            roles.title AS title,
            departments.name AS department,
            roles.salary,
            CONCAT(managers.first_name, " ", managers.last_name) AS manager
        FROM
            employees
        INNER JOIN
            roles ON employees.role_id = roles.id
        INNER JOIN
            departments ON roles.department_id = departments.id
        LEFT JOIN
            employees AS managers ON employees.manager_id = managers.id
    `;

    connection.query(query, (err, employees) => {
        handleError(err);

        console.table(employees);
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
            const query = "INSERT INTO departments (name) VALUES (?)";
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
    const departmentQuery = "SELECT * FROM departments";

    connection.query(departmentQuery, (err, departments) => {
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
                    choices: departments.map((department) => ({
                        name: department.name,
                        value: department.id
                    })),
                }
            ])
            .then((answer) => {
                const query = "INSERT INTO roles (title, department_id, salary) VALUES (?, ?, ?)";
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
    const employeeQuery = "SELECT * FROM employees";
    const roleQuery = "SELECT * FROM roles";

    connection.query(employeeQuery, (err, employees) => {
        handleError(err);

        connection.query(roleQuery, (err, roles) => {
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
                        choices: roles.map((role) => ({
                            name: role.title,
                            value: role.id
                        })),
                    },
                    {
                        type: "list",
                        name: "empManager",
                        choices: employees.map((employee) => ({
                            name: `${employee.first_name} ${employee.last_name}`,
                            value: employee.id
                        })),
                    }
                ])
                .then((answer) => {
                    const query = "INSERT INTO employees (first_name, last_name, role_id, manager_id) VALUES (?, ?, ?, ?)";
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
    const employeeQuery = "SELECT * FROM employees";
    const roleQuery = "SELECT * FROM roles";

    connection.query(employeeQuery, (err, employees) => {
        handleError(err);

        connection.query(roleQuery, (err, roles) => {
            handleError(err);

            inquirer
                .prompt([
                    {
                        type: "list",
                        name: "employeeId",
                        message: "Which employee's role do you want to update?",
                        choices: employees.map((employee) => ({
                            name: `${employee.first_name} ${employee.last_name}`,
                            value: employee.id
                        })),
                    },
                    {
                        type: "list",
                        name: "roleId",
                        message: "Which role do you want to assign the selected employee?",
                        choices: roles.map((role) => ({
                            name: role.title,
                            value: role.id
                        })),
                    },
                ])
                .then((answers) => {
                    const query = "UPDATE employees SET role_id = ? WHERE id = ?";
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