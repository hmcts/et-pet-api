# Manual Testing

Manual testing is always going to be a little difficult when we are dealing with a
system that interfaces to another.

But, there are some tools and tricks to help

## The Admin

The admin url is

http://localhost:(your admin port)/admin

If you are using the standard test setup using docker, or without docker and have ran the
db:seed rake task, you will be able to login with these users - all with password 'password'

* admin@example.com
* senioruser@example.com
* junioruser@example.com

These 3 users are primarily for demonstrating the roles functionality and
how users can be restricted.

## Seeing What ATOS Sees

There is an API endpoint which at least for the time being you will be able
to access.  When the system is properly deployed, this will be behind locked
doors and a browser certainly not be able to access it.

