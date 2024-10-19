# korazon
 
Data base
- Users: name, username, phoneNumber(phoneNumber), password, gender, userID, social networks, isHost, age, QR, bio, email(host), map of events a user has access to

- Events: description, name, eventIID, photo, nameOfHost, picOfHost, IDHost, location, dateCreated/lastTimeModified, 
    - People that have access to the event
    - Attendance



Functions
- Create user —> Includes creation of a QR code with cloud functions
    - Edit user
        - Change password
        - Recover password
- Sign in and out

- Create event —> restricted to hosts. 
    - Modify events
    - Delete event

- “Buy” tickets

- Fetch events from data base so that people can search for events (your events or all events)
    - Very simple search bar

- Function that requests information about user to see if the user has access to an event and pull information about user