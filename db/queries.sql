SELECT manager_id
    CASE manager_id WHEN INT THEN employee(id)
                    
    * `manager_id`: `INT` to hold reference to another employee that is the manager of the current employee (`null` if the employee has no manager)