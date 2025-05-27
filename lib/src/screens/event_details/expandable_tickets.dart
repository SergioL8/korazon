import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:korazon/src/widgets/confirmationMessage.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:korazon/src/widgets/alertBox.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/utilities/models/eventModel.dart';



class ExpandableTicket extends StatefulWidget {

  const ExpandableTicket({super.key, required this.ticket, required this.stripeConnectedCustomerId, required this.hostID});
  
  final TicketModel ticket;
  final String? stripeConnectedCustomerId;
  final String? hostID;

  @override
  State<ExpandableTicket> createState() => _ExpandableTicketState();
}


class _ExpandableTicketState extends State<ExpandableTicket> {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    int? remaining = widget.ticket.ticketCapacity == null
        ? null
        : (widget.ticket.ticketCapacity! - (widget.ticket.ticketsSold ?? 0));

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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: SlideAction(
                          height: 30,
                          sliderButtonIconSize: 15,
                          sliderButtonIconPadding: 7,
                          text: widget.ticket.ticketPrice == 0.00
                            ? '> > > Slide to RSVP > > >'
                            : '> > > Slide to buy > > >',
                          textStyle: whiteBody,
                          outerColor: Colors.transparent.withValues(alpha: 0.5),
                          borderRadius: 8,
                          sliderButtonIcon: Container(
                            width: 28,  // wider than height
                            height: 20, // shorter height
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
                            
                            // Compute the ticket price
                            final ticketPrice = (widget.ticket.ticketPrice + 
                              (widget.ticket.ticketPrice * 0.029) + 0.30 + // + 2.9% + $0.30 Stripe fee
                              (widget.ticket.ticketPrice * 0.10)) * // + 10% KoraZon fee
                              100; // Convert to cents
                            
                            // Compute korazon's cut
                            final korazonCut = (widget.ticket.ticketPrice * 0.10) * 100; // Convert to cents

                            try {
                              // Call the backend to create a payment intent
                              debugPrint('Type of amount: ${ticketPrice.runtimeType}, value: $ticketPrice');
                              debugPrint('Type of korazonCut: ${korazonCut.runtimeType}, value: $korazonCut');
                              debugPrint('Stripe Connected Account ID: ${widget.stripeConnectedCustomerId}');
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
                                  showConfirmationMessage(context, message: 'Payment completed! Your ticket has been reserved.');

                                  // TODO: Update Firestore to mark the ticket as purchased

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
                            }

                          }
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (widget.ticket.ticketPrice != 0.00)
                        Center(
                          child: Text(
                            ' (You won\'t be charged yet)',
                            style: whiteBody.copyWith(
                              fontSize: 12,
                            )
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