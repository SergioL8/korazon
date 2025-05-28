import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:slide_to_act/slide_to_act.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:korazon/src/widgets/alertBox.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/utilities/models/eventModel.dart';



class ExpandableTicket extends StatefulWidget {

  const ExpandableTicket({super.key, required this.ticket, required this.stripeConnectedCustomerId, required this.hostID, required this.event});
  
  final TicketModel ticket;
  final String? stripeConnectedCustomerId; // host's Stripe Connected Account ID
  final String? hostID;
  final EventModel event;

  @override
  State<ExpandableTicket> createState() => _ExpandableTicketState();
}


class _ExpandableTicketState extends State<ExpandableTicket> {
  bool isExpanded = false;
  bool paymentSuccessful = false;
  @override
  Widget build(BuildContext context) {
    int? remaining = widget.ticket.ticketCapacity == null
        ? null
        : (widget.ticket.ticketCapacity! - (widget.ticket.ticketHolders!.length));

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => isExpanded = !isExpanded),
            child: ClipPath(
              clipper: TicketClipper(),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                height: 152,
                decoration: BoxDecoration(
                  gradient: linearGradient,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    Text(
                      widget.ticket.ticketName,
                      style: whiteBody.copyWith(fontWeight: FontWeight.bold, fontSize: 21.0),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 1,
                      child: CustomPaint(
                        painter: DottedLinePainter(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('Price: ', style: whiteBody),
                                const SizedBox(width: 4),
                                Text(
                                  widget.ticket.ticketPrice == 0.00
                                      ? 'Free'
                                      : '\$${widget.ticket.ticketPrice.toStringAsFixed(2)}',
                                  style: whiteBody.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            Text(
                              isExpanded 
                                ? 'Tap to hide details'
                                : 'Tap to view details',
                              style: whiteBody.copyWith(
                                fontSize: 14,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white,
                                decorationThickness: 1.5,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          remaining == null
                              ? 'Unlimited'
                              : remaining > 0
                                  ? '$remaining remaining'
                                  : 'Sold Out',
                          style: whiteBody,
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                child: isExpanded ? Container(
                  key: const ValueKey('expanded'),
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(16),
                  width: MediaQuery.of(context).size.width - 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        linearGradient.colors.first.withValues(alpha: 0.60),
                        linearGradient.colors.last.withValues(alpha: 0.60),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.ticket.ticketDescription != null && widget.ticket.ticketDescription!.isNotEmpty)
                        Text(
                          widget.ticket.ticketDescription!,
                          style: whiteBody,
                        ),
                      
                      SizedBox(height: 8,),
                      Text(
                        widget.ticket.genderRestriction == 'all' 
                        ? ' • This ticket has no gender restrictions'
                        : widget.ticket.genderRestriction == 'Female'
                          ? ' • This ticket is restricted to women only'
                          : ' • This ticket is restricted to men only',
                        style: whiteBody,
                      ),
                      SizedBox(height: 8),
                      if (widget.ticket.ticketEntryTimeStart != null && widget.ticket.ticketEntryTimeEnd != null)
                        Text(
                          ' • Ticket entry time: ${DateFormat('hh:mm a').format(widget.ticket.ticketEntryTimeStart!.toDate().toLocal())} - ${DateFormat('hh:mm a').format(widget.ticket.ticketEntryTimeEnd!.toDate().toLocal())}',
                          style: whiteBody,
                        )
                      else if (widget.ticket.ticketEntryTimeStart != null)
                        Text(
                          ' • Ticket entry time: ${DateFormat('hh:mm a').format(widget.ticket.ticketEntryTimeStart!.toDate().toLocal())} - End of event',
                          style: whiteBody,
                        )
                      else
                        Text(
                          ' • No entry time restrictions',
                          style: whiteBody,
                        ),
                      const SizedBox(height: 16),
                      paymentSuccessful
                        ? Center(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.55),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  weight: 10.00,
                                ),
                              ),
                            ),
                          )
                        : SlideAction(
                          height: 28,
                          sliderButtonIconSize: 15,
                          sliderButtonIconPadding: 7,
                          outerColor: Colors.transparent.withValues(alpha: 0.5),
                          borderRadius: 8,
                          submittedIcon: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          sliderButtonIcon: Container(
                            width: 25,  // wider than height
                            height: 19, // shorter height
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(width: 1, height: 16, color: backgroundColorBM),
                                SizedBox(width: 4),
                                Container(width: 1, height: 16, color: backgroundColorBM),
                                SizedBox(width: 4),
                                Container(width: 1, height: 16, color: backgroundColorBM),
                              ],
                            ),
                          ),
                          onSubmit: () async {
                            // Get user's ID
                            final uid = FirebaseAuth.instance.currentUser?.uid;
                            if (uid == null) {
                              showErrorMessage(context, content: 'There was an error loading your user, please logout and login again', errorAction: ErrorAction.logout);
                              return;
                            }

                            // Check if the user is already a ticket holder

                            // Check if the user is aleady an event ticket holder

                            
                            // Compute the ticket price
                            final ticketPrice = (widget.ticket.ticketPrice + 
                              (widget.ticket.ticketPrice * 0.029) + 0.30 + // + 2.9% + $0.30 Stripe fee
                              (widget.ticket.ticketPrice * 0.10)) * // + 10% KoraZon fee
                              100; // Convert to cents
                            
                            // Compute korazon's cut
                            final korazonCut = (widget.ticket.ticketPrice * 0.10) * 100; // Convert to cents

                            // ~~~~~~~~~~~~~ Begin availability transaction ~~~~~~~~~~~~~
                            final eventReference = FirebaseFirestore.instance.collection('events').doc(widget.event.documentID);
                            
                            try {
                              await FirebaseFirestore.instance.runTransaction((tx) async { // create the transaction
                                final snap = await tx.get(eventReference); // get the event document snapshot

                                // Check if the event exists
                                if (!snap.exists) {
                                  throw Exception('Event does not exist');
                                }

                                // Check if tickets exist for this event and pull them from the snapshot
                                final data = snap.data();
                                if (data == null || !data.containsKey('tickets')) {
                                  throw Exception('No tickets available for this event');
                                }
                                final tickets = List<Map<String, dynamic>>.from(data['tickets'] ?? []);

                                // Find the ticket by documentID
                                final index = tickets.indexWhere((t) => t['documentID'] == widget.ticket.ticketID);
                                if (index == -1) {
                                  throw Exception('Ticket not found');
                                }

                                // Get the users that have bought or have this ticket on hold
                                final ticket = Map<String, dynamic>.from(tickets[index]);
                                final holders = List<String>.from(ticket['ticketHolders'] ?? <String>[]);
                                final pending = List<String>.from(ticket['userWithTicketsOnHold'] ?? <String>[]);

                                // Already on hold?
                                if (pending.contains(uid) || holders.contains(uid)) {
                                  throw Exception('You already hold this ticket');
                                }

                                // Check if the ticket is sold out
                                final capacity = ticket['ticketCapacity'] as int?;
                                if (capacity != null &&
                                    holders.length + pending.length >= capacity) {
                                  throw Exception('Sold out');
                                }

                                // Reserve seat
                                pending.add(uid);
                                ticket['userWithTicketsOnHold'] = pending;
                                tickets[index] = ticket;

                                tx.update(eventReference, {'tickets': tickets});
                              });
                            } catch (e) {
                              showErrorMessage(context,
                                  content: e.toString().contains('Sold out')
                                      ? 'Sold out. Please choose another ticket.'
                                      : 'Unable to reserve ticket. Try again.');
                              return; // Abort payment flow
                            }
                            // ----- End availability transaction -----


                            try {
                              // Call the backend to create a payment intent
                              final response = await http.post(
                                Uri.parse('https://us-central1-korazon-dc77a.cloudfunctions.net/createTicketPaymentIntent'),
                                headers: {'Content-Type': 'application/json'},
                                body: jsonEncode({
                                  'amount': ticketPrice.round(),
                                  'korazonCut': korazonCut.round(),
                                  'stripeConnectedAccountId': widget.stripeConnectedCustomerId,
                                  'ticketID': widget.ticket.ticketID,
                                  'attendeeUID': uid,
                                  'hostUID': widget.hostID,
                                }),
                              );

                              // Check if the response is successful
                              if (response.statusCode == 200) {
                                final clientSecret = json.decode(response.body)['clientSecret'];
                                debugPrint('ClientSecret received.');

                                // Initialize the payment page
                                await Stripe.instance.initPaymentSheet(
                                  paymentSheetParameters: SetupPaymentSheetParameters(
                                    paymentIntentClientSecret: clientSecret,
                                    merchantDisplayName: 'Korazon',
                                    style: ThemeMode.dark,
                                  ),
                                );

                                try {
                                  // Present the payment page
                                  await Stripe.instance.presentPaymentSheet();
                                  debugPrint('Payment completed successfully.');
                                  setState(() {
                                    paymentSuccessful = true;
                                  });

                                  // ---- Finalize ticket purchase in one transaction ----
                                  await FirebaseFirestore.instance.runTransaction((tx) async {
                                    // Get the event document snapshot and check if it exists
                                    final snap = await tx.get(eventReference);
                                    if (!snap.exists) throw Exception('Event missing during finalize.');

                                    // Get the data and check the tickets if it contains the tickets list
                                    final data = snap.data();
                                    if (data == null || !data.containsKey('tickets')) throw Exception('Tickets missing during finalize.');
                                    final tickets = List<Map<String, dynamic>>.from(data['tickets'] ?? []);

                                    // Find the ticket by documentID
                                    final idx = tickets.indexWhere((t) => t['documentID'] == widget.ticket.ticketID);
                                    if (idx == -1) throw Exception('Ticket not found during finalize.');

                                    // Get the ticket and its holders
                                    final ticket  = Map<String, dynamic>.from(tickets[idx]);
                                    final pending = List<String>.from(ticket['userWithTicketsOnHold'] ?? <String>[]);
                                    final holders = List<String>.from(ticket['ticketHolders'] ?? <String>[]);

                                    // Remove from pending (if still present) and add to holders
                                    pending.remove(uid);
                                    if (!holders.contains(uid)) holders.add(uid);

                                    ticket['userWithTicketsOnHold'] = pending;
                                    ticket['ticketHolders'] = holders;
                                    tickets[idx] = ticket;

                                    // Update both tickets array and eventTicketHolders atomically
                                    tx.update(eventReference, {
                                      'tickets'             : tickets,
                                      'eventTicketHolders'  : FieldValue.arrayUnion([uid]),
                                    });

                                    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
                                    tx.update(userRef, {
                                      'tickets': FieldValue.arrayUnion([
                                        {
                                          'eventId'    : widget.event.documentID,
                                          'ticketId'   : widget.ticket.ticketID,
                                          'purchasedAt': Timestamp.now(),
                                        }
                                      ])
                                    });
                                  });
                                } on Exception catch (e) {
                                  if (e is StripeException) {
                                    showErrorMessage(context, content: e.error.localizedMessage ?? 'Something went wrong during payment.');
                                    debugPrint('Stripe payment error: ${e.error.localizedMessage}');
                                  } else {
                                    showErrorMessage(context, content: 'An unexpected error occurred.');
                                    debugPrint('Unexpected error: $e');
                                  }
                                  debugPrint('Stripe payment error: $e');
                                }

                              } else {
                                showErrorMessage(context, content: 'There was an error creating your payment. Try again later.');
                                debugPrint('Error creating payment intent: ${response.statusCode} - ${response.body}');
                              }

                            } catch (e) {
                              showErrorMessage(context, content: 'Unexpected error. Please try again', errorAction: ErrorAction.none);
                              debugPrint('Unexpected error: $e');
                              return;
                            } finally {
                              if (!paymentSuccessful) {
                                // Remove the user from pending holds
                                try {
                                  await FirebaseFirestore.instance.runTransaction((tx) async {
                                    // Get the event document snapshot and check if it exists
                                    final snap = await tx.get(eventReference);
                                    if (!snap.exists) return; 

                                    // Get the data and check if it contains the tickets list
                                    final data = snap.data();
                                    if (data == null || !data.containsKey('tickets')) return;

                                    // Pull the tickets from the data
                                    final tickets = List<Map<String, dynamic>>.from(data['tickets'] ?? []);

                                    // Find the ticket by documentID
                                    final idx = tickets.indexWhere((t) => t['documentID'] == widget.ticket.ticketID);
                                    if (idx == -1) return;
                                    final ticket = Map<String, dynamic>.from(tickets[idx]);

                                    // Get the list of users with tickets on hold and remove the current user
                                    final pending = List<String>.from(ticket['userWithTicketsOnHold'] ?? <String>[]);
                                    pending.remove(uid);

                                    // Update the ticket with the new list of users on hold
                                    ticket['userWithTicketsOnHold'] = pending;
                                    tickets[idx] = ticket;
                                    tx.update(eventReference, {'tickets': tickets});
                                  });
                                } catch (_) {
                                  // Silently fail since it will be handled by the webhook
                                }
                            }
                            }

                          },
                          child: Shimmer.fromColors(
                            baseColor: Colors.white,
                            highlightColor: Colors.grey.shade400,
                            child: Text(
                              widget.ticket.ticketPrice == 0.00
                                  ? '> > > Slide to RSVP > > >'
                                  : '> > > Slide to buy > > >',
                              style: whiteBody.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 6),
                      if (widget.ticket.ticketPrice != 0.00)
                        Center(
                          child: Text(
                            paymentSuccessful
                              ? 'Purchase complete. Your ticket will show in your profile soon.'
                              : ' (You won\'t be charged yet)',
                            style: whiteBody.copyWith(
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                    ],
                  ),
                ) : SizedBox.shrink()
              ),
            ),
          ),
        ],
      ),
    );
  }
}



/// Clips the container into a ticket shape with scalloped side notches.
class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const notchRadius = 16.0;
    final halfHeight = 76; // size.height / 2;
    final path = Path();

    path.moveTo(0, 0);
    path.lineTo(size.width, 0);

    // right notch
    path.lineTo(size.width, halfHeight - notchRadius);
    path.arcToPoint(
      Offset(size.width, halfHeight + notchRadius),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);

    // left notch
    path.lineTo(0, halfHeight + notchRadius);
    path.arcToPoint(
      Offset(0, halfHeight - notchRadius),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}


/// Draws a horizontal dotted line at vertical center.
class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = backgroundColorBM
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    const dashWidth = 1.0;
    const dashSpace = 8.0;
    double startX = 0;
    final y = size.height / 2;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, y),
        Offset(startX + dashWidth, y),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}