[![Code Climate](https://codeclimate.com/repos/548f346ce30ba05437006cb3/badges/8fcb0e8dd0a815db2bf9/gpa.svg)](https://codeclimate.com/repos/548f346ce30ba05437006cb3/feed)
[![Test Coverage](https://codeclimate.com/repos/548f346ce30ba05437006cb3/badges/8fcb0e8dd0a815db2bf9/coverage.svg)](https://codeclimate.com/repos/548f346ce30ba05437006cb3/feed)

Rails Bootstrap
===============

Setup for Rails Applications

##Instructions

1. Clone this repository
2. Install the ruby version located in the `.ruby-version` file executing `rbenv install [ruby-version]`.
3. Run `gem install bundler`
4. Run `bundle install`
5. Run the following script with your application name in `snake_case`:
 `./script/bootstrap app_name`
6. Replace the git remote origin with your repository URL
7. Your app is ready. Happy coding!

##Errbit Configuration

`Errbit` is used for exception errors report. To complete this configuration setup the following environment variables in your server
- ERRBIT_API_KEY
- ERRBIT_HOST

##Configuration Files

###.mail.yml (mailer configuration for all the app)

smtp_address: "smtp.gmail.com"  
sender: "somemail@xxx.com"  
password: "some password"

###.facebook.yml (facebook app for login and share)

app_id: "APP ID"  
app_secret: "APP SECRET"  

###.redis.yml (redis db connection)

host: localhost  
port: 6379  
password: "a password if needed"

###.resque.yml (web job's overview)

user: "some user (this is a plain name, it doesn't matter if the user exists or not)"  
password: "some password"

