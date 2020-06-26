# README

﻿Documentation for using the website


1. Getting the project ready:
      a.  Clone the project from https://github.com/manomoybiswas/Task-Management-System.git
      b. Download elasticsearch from https://www.elastic.co/downloads/elasticsearch and run the elasticsearch server
      c. First navigate to the project folder by < cd Task_Management_System >
      d.  Run < bundle install > to install all the dependencies.
      e. Run < rails db:setup >, wait for creating database, database migrations and seeding the database to complete.

2. Starting the website:
      a. Start the rails server by "< rails server >" or “< rails server -b 0.0.0.0 -p 3050 >”
      b. On another terminal Run < bundle exec sidekiq > to run the sidekiq
      c. Access the homepage by typing  "< localhost:3000 >" or "< localhost:3050 >"  in your browser url.

3. Admin Login:
      a. Goto Admin Login in navbar 
      b. Check the seed file in db folder
      c. Login  using username and password for Admin

4. Add Employee:
      a. Goto Users → Add users
      b. Fill the details of employee and create user

5. Employee and HR Login:
      a. Once an Admin creates an Employee and hR can login via only Google Account.
      b. Only employee with Google Account and Added by admin can login to the system

6. Task Category:
      a. Only admin has the right to create task category
      b. Goto Dashboard → Category → Create category
      c. Fill the details and create category

7. Task Assign:
      a. Admin User:
          i.  Goto Dashboard → Tasks → Create task 
          ii. Fill the necessary details and assign task to any employee except HR
      b. Employee:
          i.   Goto Dashboard → Create task  or Dashboard → My Tasks → Create task 
          ii.  Fill the necessary details and assign task to any employee
          iii. Employee can only assign task to other employees not Admin or HR

8. Subtask Create:
      a. Click on + button in Task Form and add subtask as much as you need

9. View Task:
      a. Admin:
         i.   Goto Dashboard → Tasks
         ii.  This page List all the task and each task has view edit delete approved( if submitted) button
         iii. By clicking on view button admin can view task details
      b. Employee:
         i.   Goto Dashboard → My Tasks
         ii.  This page List all the task assigned to the employee and each task has view submit button
         iii. By clicking on view button admin can view task details

10. Submit Subtask:
      a. Goto Dashboard → My Task → Click View Button 
      b. On Task Details page all sub task listed
      c. Click on Submit button to submit sub task

11. Submit Task:
      a. Employee can submit task by clicking the submit button
      b. Make sure all sub tasks (if available) submitted before task submitted

12. View My Assigned Task:
      a. Goto dashboard → Set Tasks
      b. This page List all the task assigned by employee and each task has view, edit, delete, approve ( if 
         submitted) button

13. Approved Task:
      a. Admin:
         i.   Goto Dashboard → Tasks
         ii.  This page List all the task and each task has view, edit,  delete approve ( if submitted) button
         iii. By clicking on Approve  button admin can approve a task
      b. Employee:
         i.   Goto dashboard → Set Tasks
         ii.  This page List all the task assigned by employee and each task has view edit delete approve ( if 
              submitted) button
         iii. By clicking on Approve  button admin can approve a task

14. Notify HR:
      a. If task approved admin can notify HR by clicking on Notify HR button

15. View Notified Task (HR user)
      a. HR dashboard has a Approved task section where HR can see all notified task with view and print option

16. Print Approved Task (HR user)
      a. On Approved task section in HR user each task has print button
      b. By clicking on Print Button HR can print each task

17. Print Approved Task List (HR user)
      a. Approved task section in HR user has print task list button
      b. By clicking on Print task list Button HR can print  list of approved task

18. Notification:
      a. On task create update submit approved employee and admin get a notification performed by action cable

19. Email: 
      a. On task create update submit approved employee and admin get a Email performed by action mailer
      b. Sidekiq perform the mail sending job

20. Search 
      a. On typing the task name category on search field in navbar user (except hr) can search task
      b. For searching elasticsearch is used. It reduce overhead in actual database

21. User profile:
      a. In the navbar on clicking on username, a drop down opens.
      b. Select change profile option
      c. Here employees can find change profile pictures and edit user details options.

22. Logout
      a. In the navbar on clicking on username, a drop down opens.
      b. Select logout
