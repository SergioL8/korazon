# korazon

Note: check for release fingerprint of android (this is related with google login method of firebase) we currently have only configured the test version
Note: Make all paddings proportional to the size of the screen

flutter run -d chrome --web-renderer html

flutter build web --web-renderer html --release


Next steps:

### - Mario:
1. Add information of user to the data base. Special the host true/false
2. Change the bottom bar so that it's different for host and for user
3. Create events
4. Update the create account {
                                name and last name
                                phone (for users) / email (for hosts)
                                password
                                age
                                gender
                                isHost
                             }



### - Sergio:
1. Fix iOS
2. Dynamically select the bottom navigation bar
3. Upload image to Storage
4. Create the home page where you can see events



### - Jona:
1. Style the users account super very mega ultra beautiful don't finish until it's super ultra beautiful




# Project Plan
## Defining the project
### What is the project?
This project consists of building the Korazon app. The Korazon app is a ticketing app for frats. However, this is not a basic ticketing app, the objective of korazon is to organize tickets for frats by digitalizing all the purchases, and economic transactions. But it is also to make parties safer, by knowing who and when each person gets into the party we can have a list of people that have attended the party making easy for guests to identify other guests in case of an incident. Frats will be able to blacklist guests, creating this community of frats that "communicate" by leaving out violent poeple.

Moreover, Korazon will have the social side. This side will consist of having profiles where people can see  what parties each person has attended as well as links to social media.


### What is the MVP (Minimum Viable Product)?
- With respect to users: The MVP is an app where users can search for parties, buy tickets for parties and see who has attended the party. Each user will have a profile that will include the parties the user has antended, and links to social media. The user will be able to scan a personal QR code to acess all events. The user will be able to search for other users and become friends. This will unlock extra features like recieve notifications when a friend of yours has bought a ticket for a party (we still have to decide what other features will be unlocked).

- With respect to the hosts: Hosts will be able to easily create events, be able to personalize the access to events up to the point of letting some users enter freely, and others to pay. The access should be as flexible up to the point where event if the user doesn't have a ticket he or she will be able to let in anyways. Moreover, the host will be able to see anyone that has attended the party and be able to see some stats like numer of people, ratio, average time of enter and others that still have to be defined. Hosts will also have a profile page where all the parties they have throw will be shwos with a couple of stats like atendance and maybe also ratio? (We have to talk about having ratio here).

One of the most important features about this app is that it most be super easy to use and navigate. Specially the sing up and and the QR code. 


### What are the nices to have?
1. Be able to posts pictures of the night. So you will have a list of parties, you can click on any of the parties and access photos and comments. The pictures you post will be seen by yours friends, and you will be able to see the pictrues yours friends and the host post.
2. You will have a chat in the app to talk with your friends.
3. You will be able to post photos in your profile about yourself or about parties.



### When will the project be finished?
The project will be finished when all the MVP features have been impmlemented. This includes not having bugs, ad having a styled, smooth application.

Note that the MVP will most likely change during the development of the app. This is ok and encourgaed.


