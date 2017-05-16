# APO Rho Pi #

This is the repo for Rho Pi's website.

The basic layout is as follows:

* config/routes matches url's to its respective controller (and action within
  the controller)

>>`match '/user/:id',            to: 'user#show',          via: [:get],          as: 'user'`

>>'aporhopi.org/user/:id' will go to the show action within the user controller, which
>>will show the profile of the user with the specified id. 

>>The profile page
>>will be displayed according to the app/views/user/show.html.erb file.

* app/controllers/ contains all the controller files, each of which define
  related actions.

>>The user_controller.rb file contains actions such as "show," "greensheet,
and "all" which contains the code relating to showing a user's profile,
creating a user's greensheet, or displaying all the users.

>>Controllers set the instance variables (preceded by a '@') that are used in
the corresponding view file with the same name.

* app/models/ contains all the model files, each of which define a table in the
  database.

>>The user.rb file sets defines the relationships between users and different
    models (events, attendances, greensheets)

* app/views/ contains all the view files, which contain the HTML (and Embedded
  Ruby to make it dynamic) that describes how to render the webpage.

>>The user/show.html.erb file contains the code to display a user's profile page.

* db/migrate/ contains all the files that describe what properties each of the
  models contain.     

>>2015..._add_fieldsto_user.rb describes that the user table in the database
>>contains rows holding username, family, line, pledge class, and other
>>relevant information.

* app/assets/stylesheets/ contains all the files with the CSS code to format the
  views.

* app/assets/javascripts/ contains all the JavaScript/CoffeeScript files.
