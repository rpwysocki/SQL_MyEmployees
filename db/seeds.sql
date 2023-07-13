INSERT INTO department 
    (name)
VALUES
    ("Sales"),
    ("Marketing"),
    ("Engineering");

INSERT INTO role
    (title, salary, department_id)
VALUES
    ("Sales Manager", 100000, 1),
    ("Salesman", 50000, 1),
    ("Production Manager", 75000, 2),
    ("Designer", 50000, 2),
    ("Lead Engineer", 75000, 3),
    ("Engineer", 75000, 3);

INSERT INTO employee
    (first_name, last_name, role_id, manager_id)
VALUES
    ("Bob", "Smith", 1, NULL),
    ("Jane", "Doe", 2, 1),
    ("Bob", "Smith", 3, NULL),
    ("Bob", "Smith", 4, NULL),
    ("Bob", "Smith", 5, NULL),
    ("Bob", "Smith", 6, NULL);
   