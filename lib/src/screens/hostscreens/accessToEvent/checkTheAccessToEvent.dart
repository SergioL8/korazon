import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:korazon/src/widgets/alertBox.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:korazon/src/widgets/colorfulSpinner.dart';
import 'package:korazon/src/utilities/models/userModel.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/utilities/models/eventModel.dart';
import 'package:korazon/src/widgets/accessToEventWidgets/allowGuestIntoPartyButton.dart';
import 'package:korazon/src/widgets/accessToEventWidgets/denyGuestIntoPartyButton.dart';



class CheckForAccessToEvent extends StatefulWidget {
  const CheckForAccessToEvent({super.key, required this.guestID, required this.eventID});
  final String guestID;
  final String eventID;

  @override
  State<CheckForAccessToEvent> createState() => _CheckForAccessToEventState();
}



class _CheckForAccessToEventState extends State<CheckForAccessToEvent> {
  
  UserModel? userModel;
  EventModel? eventModel;
  TicketModel? eventTicket;
  Map<String, dynamic>? userTicket;
  Uint8List? userImage;

  bool noUserInfo = false;
  String? ticketId;


  /// This function wll check if a user has in his list of events the event he is trying to access
  Future<bool> _checkAccessToEvent() async {
    // 1. Pull user info and store it in an model
    final userDocument = await FirebaseFirestore.instance.collection('users').doc(widget.guestID).get();
    userModel = UserModel.fromDocumentSnapshot(userDocument);
    if (userModel == null) {
      noUserInfo = true;
      showErrorMessage(context, content: 'There was an error loading the user information. Please try again');
      debugPrint('User not found. line 83');
      return false;
    }

    // 2. Pull event info and store it in a model
    final eventDocument = await FirebaseFirestore.instance.collection('events').doc(widget.eventID).get();
    eventModel = EventModel.fromDocumentSnapshot(eventDocument);
    if (eventModel == null) {
      showErrorMessage(context, content: 'There was an error loading the event information. Please try again');
      debugPrint('Event not found. line 92');
      return false;
    }

    // 3. Check if user is in event's ticket holder list
    if (eventModel!.eventTicketHolders == null) { return false; }
    if (!eventModel!.eventTicketHolders!.contains(widget.guestID)) {
      debugPrint('User not in event ticket holders list');
      return false;
    }

    // 4. Check if user has the ticket in its list of tickets
    final List<String> eventsAttending = userModel!.tickets.map((ticket) => ticket['eventID'] as String).toList();
    if (!eventsAttending.contains(widget.eventID)) {
      debugPrint('User doesn\'t have the event in its list of tickets');
      return false;
    }

    // 5. Pull the ticket that the user has for the event
    userTicket = userModel!.tickets.firstWhere(
      (ticket) => ticket['eventID'] == widget.eventID,
      orElse: () => <String, dynamic>{},
    );

    // 6. Pull ticket data from the event
    // Extract the user's ticket ID from the fetched map
    final rawUserTicketId = userTicket?['ticketID'] as String?;
    if (rawUserTicketId == null || rawUserTicketId.isEmpty) {
      debugPrint('Missing ticketID in userTicket map: $userTicket');
      return false;
    }

    try {
      eventTicket = eventModel!.tickets.firstWhere(
        (t) => t.ticketID.trim() == rawUserTicketId.trim(),
      );
    } on StateError {
      debugPrint('Ticket in user\'s list not found in event\'s tickets');
      eventTicket = null; // firstWhere throws StateError if nothing matches
    }

    // 7. Check if user is in the ticket's list of users
    if (eventTicket == null || eventTicket!.ticketHolders == null) { return false; }
    if (!eventTicket!.ticketHolders!.contains(widget.guestID)) {
      debugPrint('User not in ticket holders list');
      return false;
    }

    // 8. Everything is fine, user has access to the event
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<bool>(
        future: _checkAccessToEvent(), // check if the user has access to the event and store the result in snapshot
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) { // if checking is still in progress show a loading indicator
            return const ColorfulSpinner();
          } else if (snapshot.hasError || noUserInfo) {
            return const Text('An error occurred, try again later');
          } else {
            return Scaffold(
              body: Container(
                height: MediaQuery.of(context).size.height,
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 60, left: 20, right: 20), // add padding to the body
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      snapshot.data! ? const Color.fromARGB(255, 108, 188, 101) : const Color.fromARGB(255, 218, 93, 93),
                      snapshot.data! ? const Color.fromARGB(255, 34, 98, 28,) : const Color.fromARGB(255, 186, 4, 4),
                    ]
                  ),
                ),
                child: LayoutBuilder(builder: (ctx, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(width: double.infinity,), // make the column take the full width of the screen
                          Icon(
                            snapshot.data! ? Icons.check_circle_rounded : Icons.cancel_rounded,
                            color: Colors.white,
                            size: 100,
                          ),
                      
                          const SizedBox(height: 35,),
                      
                          userInfoCard(userModel!, eventTicket),
                      
                          const SizedBox(height: 35,),
                      
                          Text(
                            'Always Ask for ID',
                            style: whiteSubtitle.copyWith(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10,),
                          Text(
                            'User information might be wrong, always check information',
                            style: whiteBody.copyWith(
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10,),
                          Row(
                            children: [
                              Expanded(child: DenyGuestIn()),
                              const SizedBox(width: 8),
                              Expanded(child: AllowGuestIn(userData: userModel, eventID: widget.eventID)),
                            ],
                          ),
                          const SizedBox(height: 40,),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            );
          }
        }
      )
    );
  }







  Widget userInfoCard(UserModel user, TicketModel? ticket) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Name: ',
                    style: whiteBody.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '${user.name} ${user.lastName}',
                    style: whiteBody.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  )
                ],
              ),
              Spacer(),
              Material(
                elevation: 6,
                shadowColor: Colors.black45,
                shape: const CircleBorder(),
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/images/no_profile_picture_place_holder.png'),
                ),
              )
            ],
          ),
          const SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    'Sex',
                    style: whiteBody.copyWith(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    user.gender,
                    style: whiteBody.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  )
                ],
              ),
              Column(
                children: [
                  Text(
                    'Class',
                    style: whiteBody.copyWith(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    user.academicYear,
                    style: whiteBody.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  )
                ],
              )
            ],
          ),



          const SizedBox(height: 10,),



// =============================== Ticket info section ===============================
          ListTileTheme( // make expansion tile more compact
            dense: true,
            contentPadding: EdgeInsets.zero,
            child: ExpansionTile(
              tilePadding: const EdgeInsets.fromLTRB(8, 0, 8, 0), // no top padding
              childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              enabled: ticket != null,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color.fromARGB(255, 186, 184, 255),
                ),
                child: Icon(
                  Icons.confirmation_num_outlined,
                  color: const Color.fromARGB(255, 60, 45, 202),
                ),
              ),
              title: Text(
                'Ticket Type',
                style: whiteBody.copyWith(
                  color: const Color.fromARGB(255, 60, 45, 202),
                  fontSize: 11
                ),
              ),
              subtitle: Text(
                ticket?.ticketName ?? 'No ticket found',
                style: whiteBody.copyWith(
                  color: const Color.fromARGB(255, 60, 45, 202),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: const Color.fromARGB(255, 219, 215, 255),
              collapsedBackgroundColor: const Color.fromARGB(255, 219, 215, 255),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                  color: const Color.fromARGB(255, 60, 45, 202),
                  width: 0.5,
                ),
              ),
              collapsedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                  color: const Color.fromARGB(255, 60, 45, 202),
                  width: 0.5,
                ),
              ),
              iconColor: const Color.fromARGB(255, 60, 45, 202),
              collapsedIconColor: const Color.fromARGB(255, 60, 45, 202),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
               children: ticket != null ? <Widget> [
                  if (ticket.ticketDescription != null && ticket.ticketDescription!.isNotEmpty)
                    Text(
                      'Description',
                      style: whiteBody.copyWith(
                        color: const Color.fromARGB(255, 60, 45, 202),
                        fontSize: 12,
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.all(0),
                      color: const Color.fromARGB(255, 246, 242, 242,),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Text(
                          ticket.ticketDescription!,
                          style: whiteBody.copyWith(
                            color: const Color.fromARGB(255, 60, 45, 202),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8,),
                  Card(
                    color: const Color.fromARGB(255, 246, 242, 242,),
                    margin: const EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      visualDensity: const VisualDensity(vertical: -4),
                      minVerticalPadding: 0,
                      dense: true,
                      leading: Icon(
                        Icons.people_outline,
                        color: const Color.fromARGB(255, 150, 147, 225),
                        size: 25,
                      ),
                      title: Text(
                        'Gender Restriction',
                        style: whiteBody.copyWith(
                          color: const Color.fromARGB(255, 60, 45, 202),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        ticket.genderRestriction == 'all' ? 'No gender restrictions' : ticket.genderRestriction,
                        style: whiteBody.copyWith(
                          color: const Color.fromARGB(255, 60, 45, 202),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8,),
                  Card(
                    color: const Color.fromARGB(255, 246, 242, 242,),
                    margin: const EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      visualDensity: const VisualDensity(vertical: -4),
                      minVerticalPadding: 0,
                      dense: true,
                      leading: Icon(
                        Icons.access_time_rounded,
                        color: const Color.fromARGB(255, 150, 147, 225),
                        size: 25,
                      ),
                      title: Text(
                        'Entry Time',
                        style: whiteBody.copyWith(
                          color: const Color.fromARGB(255, 60, 45, 202),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        () {
                          final startTs = ticket.ticketEntryTimeStart;
                          final endTs = ticket.ticketEntryTimeEnd;
                          if (startTs != null && endTs != null) {
                            final start = DateFormat.jm().format(startTs.toDate().toLocal());
                            final end = DateFormat.jm().format(endTs.toDate().toLocal());
                            return 'From $start to $end';
                          } else if (startTs != null) {
                            final start = DateFormat.jm().format(startTs.toDate().toLocal());
                            return 'From $start';
                          } else if (endTs != null) {
                            final end = DateFormat.jm().format(endTs.toDate().toLocal());
                            return 'Until $end';
                          } else {
                            return 'No entry time specified';
                          }
                        }(),
                        style: whiteBody.copyWith(
                          color: const Color.fromARGB(255, 60, 45, 202),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  )
              ] : const <Widget>[]
            ),
          ),


          const SizedBox(height: 10,),

// =============================== Black list section ===============================
          ListTileTheme( // make expansion tile more compact
            dense: true,
            contentPadding: EdgeInsets.zero,
            child: ExpansionTile(
              enabled: userModel!.blackList != null && userModel!.blackList!.isNotEmpty,
              tilePadding: const EdgeInsets.fromLTRB(8, 0, 8, 0), // no top padding
              childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              backgroundColor: const Color.fromARGB(255, 255, 215, 215),
              collapsedBackgroundColor: const Color.fromARGB(255, 255, 215, 215),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color.fromARGB(255, 255, 184, 184),
                ),
                child: Icon(
                  Icons.edit_note_rounded,
                  size: 30,
                  color: const Color.fromARGB(255, 202, 45, 45),
                ),
              ),
              title: Text(
                'Black Lists',
                style: whiteBody.copyWith(
                  color: const Color.fromARGB(255, 202, 45, 45),
                  fontSize: 11
                ),
              ),
              subtitle: Text(
                userModel!.blackList != null && userModel!.blackList!.isNotEmpty
                  ? '${userModel!.blackList!.length}'
                  : '0',
                style: whiteBody.copyWith(
                  color: const Color.fromARGB(255, 202, 45, 45),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                  color: const Color.fromARGB(255, 202, 45, 45),
                  width: 0.5,
                ),
              ),
              collapsedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                  color: const Color.fromARGB(255, 202, 45, 45),
                  width: 0.5,
                ),
              ),
              iconColor: const Color.fromARGB(255, 202, 45, 45),
              collapsedIconColor: const Color.fromARGB(255, 202, 45, 45),

              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListView.builder(
                  padding: const EdgeInsets.only(bottom: 0.0),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: userModel!.blackList?.length ?? 0,
                  itemBuilder: (ctx, index) {
                    final blackListItem = userModel!.blackList![index];
                    
                    return Card(
                      color: const Color.fromARGB(255, 246, 242, 242,),
                      margin: const EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Container(
                        alignment: Alignment.centerLeft,
                        height: 30,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        child: Text(
                          " • ${blackListItem.fratUserName} — ${DateFormat('MM/dd/yyyy').format(blackListItem.blackListDate.toDate().toLocal())}",
                          style: whiteBody.copyWith(
                            color: const Color.fromARGB(255, 202, 45, 45),
                            fontSize: 13,
                          ),
                        ),
                      )
                    );
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}