import 'package:flutter/material.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/utilities/models/eventModel.dart';

class TicketsSection extends StatelessWidget {
  
  const TicketsSection({super.key, required this.tickets, required this.newTicket, required this.removeTicket});

  final List<TicketModel> tickets;
  final Function({TicketModel? ticket}) newTicket;
  final Function(String) removeTicket;

  @override
  Widget build(BuildContext context) {
    debugPrint('TicketsSection: $tickets');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8,),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.07),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header ───────────────────────────────────────────
          Row(
            children: [
              Text(
                'Tickets of Event',
                style: whiteBody,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: korazonColor,
                ),
                constraints: BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
                visualDensity: VisualDensity.compact, 
                onPressed: newTicket,
              ),
            ],
          ),
          const Divider(
            color: Colors.white,
            thickness: 1,
            height: 4,
          ),
          const SizedBox(height: 16),

          // ─── Tickets List ────────────────────────────────────
          ...tickets.map((ticket) {
            
            return Dismissible(
              key: ValueKey(ticket.ticketID),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => removeTicket(ticket.ticketID),
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 16),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              child: GestureDetector(
                onTap: () {
                  newTicket(ticket: ticket);
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  color: Colors.white.withOpacity(0.15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: ListTile(
                    title: Text(
                      ticket.ticketName,
                      style: whiteBody.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Text(
                      ticket.ticketPrice == 0
                        ? 'Free'
                        : ticket.ticketPrice.toString(),
                      style: whiteBody.copyWith(
                        color: korazonColor,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                    // subtitle, trailing, etc. can go here
                  ),
                ),
              ),
            );
          })
        ],
      ),
    );
  }
}