import 'package:flutter/material.dart';
import 'package:korazon/src/screens/event_details/expandable_tickets.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/utilities/models/eventModel.dart';


class DisplayTickets extends StatefulWidget {
  const DisplayTickets({super.key, required this.event});

  final EventModel event; 

  @override
  State<DisplayTickets> createState() => _DisplayTicketsState();
}

class _DisplayTicketsState extends State<DisplayTickets> {
  
  @override
  Widget build(BuildContext context) {
    final List<TicketModel> tickets = widget.event.tickets;

    // Dynamic heightFactor based on number of tickets
    double heightFactor;
    if (tickets.length == 1) {
      heightFactor = 0.40;
    } else if (tickets.length == 2) {
      heightFactor = 0.60;
    } else if (tickets.length == 3) {
      heightFactor = 0.80;
    } else {
      heightFactor = 0.90;
    }

    return FractionallySizedBox(
      heightFactor: heightFactor,
      widthFactor: 1,
      child: Container(
        padding: const EdgeInsets.all(30.0),
        decoration: BoxDecoration(
          // borderRadius: BorderRadius.circular(16.0),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0)),
          color: backgroundColorBM,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pull indicator
            Center(
              child: Container(
                width: 80,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 141, 141, 141),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Subtitle
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Available Tickets',
                style: whiteSubtitle,
              ),
            ),

            // Always scrollable ticket list
            Expanded(
              child: ListView(
                children: tickets.map((ticket) => ExpandableTicket(ticket: ticket)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}