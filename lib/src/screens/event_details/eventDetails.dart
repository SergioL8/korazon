import 'dart:math';
import 'dart:async';
import 'dart:typed_data';
import 'package:blur/blur.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:korazon/src/widgets/alertBox.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/utilities/models/eventModel.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:korazon/src/widgets/loading_place_holders.dart';
import 'package:korazon/src/screens/event_details/static_map.dart';
import 'package:korazon/src/screens/event_details/guest_list.dart';
import 'package:korazon/src/screens/event_details/display_tickets.dart';




double _panelOverlap = 100;
double _gap = 8;

class EventDetails extends StatefulWidget {
  const EventDetails({
    super.key,
    required this.event,
    required this.imageData,
  });

  final EventModel event;
  final Uint8List? imageData;

  @override
  State<EventDetails> createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  late EventModel _currentEvent;
  Uint8List? _hostImageData;
  Uint8List? _flyerImageData;
  StreamSubscription<DocumentSnapshot>? _subscription;
  final GlobalKey _imageKey = GlobalKey();
  double _actualImageHeight = 0.0;
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();

    // Initialize local copy of the passed-in event
    _currentEvent = widget.event;

    // Attach a listener to the single document in "events" collection
    _subscription = FirebaseFirestore.instance
      .collection('events')
      .doc(_currentEvent.documentID)
      .snapshots()
      .listen((snapshot) { // This callback fires whenever the document changes
        if (!snapshot.exists) { // check the document exists
          showErrorMessage(context, content: 'Event not found. It may have been deleted.');
          _subscription?.cancel(); // Cancel subscription before popping, just to be safe:
          Navigator.of(context).pop(); // Pop back to the previous screen 
          return;
        }

        // Rebuild the EventModel from the fresh snapshot
        final updatedEvent = EventModel.fromDocumentSnapshot(snapshot);
        if (updatedEvent == null) return; // Check that the document is not empty

        // Update the local copy of the event
        setState(() {
          _currentEvent = updatedEvent;
        });
      });

      // Calculate the actual height of the image after the first frame is rendered
      if (widget.imageData != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final RenderBox box = _imageKey.currentContext!.findRenderObject() as RenderBox;
          setState(() {
            _actualImageHeight = box.size.height;
          });
        });
      }
    _loadFlyerImage(); // Load the flyer image data
    _loadHostImage(); // Load the host image data
  }

  Future<void> _loadHostImage() async {
    _hostImageData = await getImage(_currentEvent.hostProfilePicPath);
    setState(() {
      _hostImageData = _hostImageData;
    });
  }

  Future<void> _loadFlyerImage() async {
    // If the image data is already provided, no need to load it again
    if (widget.imageData != null) {
      setState(() {
        _flyerImageData = widget.imageData;
      });
    } else {
      // Load the flyer image from the event's photoPath
      _flyerImageData = await getImage(_currentEvent.photoPath);
      setState(() {
        _flyerImageData = _flyerImageData;
      });
      // Get the exact height of the widget containing the image
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final RenderBox box = _imageKey.currentContext!.findRenderObject() as RenderBox;
        setState(() {
          _actualImageHeight = box.size.height;
        });
      });
    }
  }



  @override
  void dispose() {
    _subscription?.cancel(); // Cancel the subscription when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: backgroundColorBM,
      body: Stack(
        children: [
          // ================= Background Image =================
          Hero(
            tag: _currentEvent.documentID,
            child: SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.width * (4/3),
              child: _flyerImageData == null
                ? LoadingImagePlaceHolder()
                : Image.memory(
                    key: _imageKey,
                    _flyerImageData!,
                    fit: BoxFit.cover,
                  ),
            ),
          ),

          Positioned(
            top: _actualImageHeight,
            left: 0,
            right: 0, 
            child: Blur(
              colorOpacity: 0,
              blur: 3,
              child: Transform.flip(
                flipY: true,
                child: SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.width * (4/3),
                  child: _flyerImageData == null
                    ? LoadingImagePlaceHolder()
                    : Image.memory(
                      _flyerImageData!,
                      fit: BoxFit.cover
                  ),
                ),
              ),
            )          
          ),

          Positioned(
            bottom: 0,
            left:   0,
            right:  0, 
            child: Container(
              height: 150,
              color: backgroundColorBM,
            )
          ),


          // ================= Scrollable Section =================
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // ================= Back button =================
                Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                    left: 8,
                  ),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size:   35,
                        weight: 60,
                      ),
                    ),
                  ),
                ),

                // ================= Add a buffer to display the image properly =================
                SizedBox(
                  height: MediaQuery.of(context).size.width * (4/3) - _panelOverlap - MediaQuery.of(context).padding.top - 43,
                  width: double.infinity,
                ),


                // ================= Event Details and Ticket Button =================
                Stack(
                  children: [

                    // ================= Black Panel with Event Details =================
                    ClipPath(
                      clipper: DiagonalClipperBlackPanel(),
                      child: Container(
                        color: backgroundColorBM,
                        width: MediaQuery.of(context).size.width,
                        // height: 900,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              // ================ Host profile picture and name ================
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.60,
                                height: 65,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: MediaQuery.of(context).size.width * 0.060,
                                      backgroundImage: _hostImageData == null
                                        ? AssetImage( 'assets/images/no_profile_picture.webp') as ImageProvider
                                        : MemoryImage(_hostImageData!)
                                    ),
                                    const SizedBox(width: 10),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.60 - MediaQuery.of(context).size.width * 0.15 - 10,
                                      height: MediaQuery.of(context).size.width * 0.15,
                                      child: AutoSizeText(
                                        _currentEvent.hostName,
                                        minFontSize: 8,
                                        maxLines: 1,
                                        style: whiteTitle.copyWith(
                                          fontSize: 55
                                        ),
                                      ),
                                    )
                                  ],
                                )
                              ),

                              // ================ Event Title ================
                              SelectableText(
                                _currentEvent.title,
                                style: whiteSubtitle.copyWith(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              SizedBox(height: 4),

                              // ================ Event Date and Time ================
                              SelectableText(
                                DateFormat('EEEE, MMMM d, yyyy, h:mm a').format(_currentEvent.startDateTime.toDate()),
                                style: whiteBody.copyWith(
                                  fontSize: 18,
                                )
                              ),
                              SizedBox(height: 4),

                              // ================ +21 age restriction ================
                              if (_currentEvent.plus21)
                                Text(
                                  '+21 Only',
                                  style: whiteBody.copyWith(
                                    fontSize: 18,
                                  )
                                ),
                              SizedBox(height: 12),

                              // ================ Event Description ================
                              if (_currentEvent.description != '')
                                Text(
                                  'Event Details',
                                  style: whiteSubtitle
                                ),
                                SelectableText(
                                  _currentEvent.description,
                                  style:  whiteBody,
                                ),
                                SizedBox(height: 12),

                              // ================ Event Description ================
                              Text(
                                'Location',
                                style: whiteSubtitle
                              ),
                              if (_currentEvent.location != null)
                                Padding(
                                  padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.0,),
                                  child: Text(
                                    _currentEvent.location!.description,
                                    style: whiteBody,
                                  ),
                                )
                              else 
                                Text(
                                  'Sorry no information about the location. Please report the error, you can find the report button by scrolling down.',
                                  style: whiteBody,
                                ),
                              SizedBox(height: 4),
                              Center(
                                child: StaticMap(
                                  lat: _currentEvent.location?.lat,
                                  lon: _currentEvent.location?.lon,
                                  eventId: _currentEvent.documentID,
                                  width: MediaQuery.of(context).size.width - 32,
                                  height: (MediaQuery.of(context).size.width - 32) * (2/3)
                                ),
                              ),
                              SizedBox(height: 24),

                              // ================ Attending users ================
                              Text(
                                'Guest List',
                                style: whiteSubtitle
                              ),
                              GuestList(guestList: _currentEvent.attendees ?? [], endDateTime: _currentEvent.endDateTime),
                              SizedBox(height: 24),


                              // ================= Private Analytics =================
                              if (_currentEvent.hostId == currentUserId)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Private Analytics',
                                      style: whiteSubtitle
                                    ),
                                    Text(
                                      // Guard against division by zero:
                                      "Ratio (men:women) = 1:${_currentEvent.totalWomenAttendees > 0 ? (_currentEvent.totalMaleAttendees / _currentEvent.totalWomenAttendees).toStringAsFixed(2) : '0'}",
                                      style: whiteBody,
                                    ),
                                    Text(
                                      'Ticket Holders List',
                                      style: whiteBody.copyWith(
                                        fontSize: 18
                                      )
                                    ),
                                    GuestList(guestList: _currentEvent.eventTicketHolders ?? [], endDateTime: Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 5)),)),
                                  ],
                                ),
                                



                              // ================= Report button =================



                              // ================ Padding =================
                              SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ================= Show tickets button =================
                    Positioned(
                      top: 0,
                      left: MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width * 0.40) + _gap,
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            useSafeArea: true,
                            isScrollControlled: true,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(24),
                              ),
                            ),
                            context: context,
                            builder: (ctx) => DisplayTickets(event: _currentEvent)
                          );
                        },
                        child: ClipPath(
                          clipper: DiagonalClipperTicketsButton(),
                          child: Container(
                            width: (MediaQuery.of(context).size.width * 0.40) - _gap - _gap + 1,
                            height: 65,
                            decoration: BoxDecoration(
                              gradient: linearGradient,
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.04),
                              child: Icon(
                                FontAwesomeIcons.ticket,
                                color: Colors.white,
                                size: 30,
                                weight: 40,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      )
    );
  }
}






class DiagonalClipperBlackPanel extends CustomClipper<Path> {
  /// How many dp to “cut in” before the diagonal at B and C (the “33”).
  final double diagonalDepthOffset;

  /// What fraction down from the top is the diagonal’s end (C at 0.08·H).
  final double diagonalYFraction;

  /// Radius for rounding every corner.
  final double cornerRadius;

  DiagonalClipperBlackPanel({
    this.diagonalDepthOffset  = 33.0,
    this.diagonalYFraction    = 0.08,
    this.cornerRadius         = 12.0,
  });

  @override
  Path getClip(Size size) {
    final double W = size.width;
    final double H = size.height;
    final double r = cornerRadius;


    // 1) Compute raw points B=(0.60W, 0) and C=(0.60W+offset, gapHeight).
    final double xB = 0.60 * W;
    final double yB = 0.0;
    final double xC = xB + diagonalDepthOffset;
    final double yC = 74.0;

    // 2) Unit‐vector along diagonal BC:
    final double dx = xC - xB;             // = diagonalDepthOffset
    final double dy = yC - yB;             // = 0.08 * H
    final double L  = sqrt(dx * dx + dy * dy);
    final double ux = dx / L;  // normalized x
    final double uy = dy / L;  // normalized y

    // 3) Compute the “step‐in” t for rounding the acute/obtuse corners B and C:
    //
    //    At B, we approach from the left (vector e_in=(-1,0))
    //    and leave along e_out=(+ux, +uy).
    //    cos(phiB) = e_in • e_out = (-1,0)•(ux,uy) = -ux.
    //    Hence phiB = acos(-ux), and tB = r / tan(phiB/2).
    final double phiB = acos(-ux);
    final double tB   = r / tan(phiB / 2);

    final Path path = Path();

    // ===== Corner A (0, 0) – 90° between [↓] and [→] =====
    path.moveTo(r, 0);  
    // We will close this corner at the very end.

    // ===== Edge A→B (top) – stop tB short of raw B =====
    path.lineTo(xB - tB, 0);

    // ===== Corner B (acute between top→ and diagonal ↘) =====
    path.arcToPoint(
      Offset(xB + ux * tB, uy * tB),
      radius: Radius.circular(r),
      clockwise: true,    // convex/acute → “outside” arc is correct 
    );

    // ===== Edge B→C (diagonal) – stop tB short of raw C =====
    path.lineTo(xC - ux * tB, yC - uy * tB);

    // ===== Corner C (obtuse between diagonal ↖ and small-horz →) =====
    path.arcToPoint(
      Offset(xC + r, yC),
      radius: Radius.circular(r),
      clockwise: false,
    );

    // ===== Edge C→D (small horizontal) – stop r short of D =====
    path.lineTo(W - r, yC);

    // ===== Corner D (W, yC) – 90° between [→] and [↓] =====
    path.arcToPoint(
      Offset(W, yC + r),
      radius: Radius.circular(r),
      clockwise: true,
    );

    // ===== Edge D→E (right side) – stop r short of E =====
    path.lineTo(W, H - r);

    // ===== Corner E (W, H) – 90° between [↓] and [←] =====
    path.arcToPoint(
      Offset(W - r, H),
      radius: Radius.circular(r),
      clockwise: true,
    );

    // ===== Edge E→F (bottom) – from (W - r, H) → (r, H) =====
    path.lineTo(r, H);

    // ===== Corner F (0, H) – 90° between [←] and [↑] =====
    path.arcToPoint(
      Offset(0, H - r),
      radius: Radius.circular(r),
      clockwise: true,
    );

    // ===== Edge F→A (left side) – from (0, H - r) → (0, r) =====
    path.lineTo(0, r);

    // ===== Final rounding of A (0, 0) – 90° between [↑] and [→] =====
    path.arcToPoint(
      Offset(r, 0),
      radius: Radius.circular(r),
      clockwise: true,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(DiagonalClipperBlackPanel old) {
    return old.cornerRadius         != cornerRadius
        || old.diagonalDepthOffset != diagonalDepthOffset
        || old.diagonalYFraction   != diagonalYFraction;
  }
}




class DiagonalClipperTicketsButton extends CustomClipper<Path> {
  /// How far in from the right edge the raw diagonal corner is (D).
  final double diagonalDepth;

  /// The desired radius for all rounded corners.
  final double cornerRadius;

  DiagonalClipperTicketsButton({
    this.diagonalDepth = 30.0,
    this.cornerRadius = 12.0,
  });

  @override
  Path getClip(Size size) {
    final double W = size.width;
    final double H = size.height;
    final double D = diagonalDepth;
    final double r = cornerRadius;

    // 1) Compute diagonal unit vector and length:
    final double dx = D;
    final double dy = H;
    final double L = sqrt(dx * dx + dy * dy);
    final double ux = dx / L; // diagonal’s x‐component
    final double uy = dy / L; // diagonal’s y‐component

    // uy = 65 / (diagonalDepth**2 + 65**2)

    // 2) Compute interior angles for the two “non-right” corners:
    //
    //    Bottom-left (BL) corner is between:
    //      - bottom edge:   e_bottom = (-1, 0),
    //      - diagonal:      e_diag   = (-ux, -uy) when traveling “up-left” from (D,H) to (0,0).
    //
    //    cos(phi_BL) = e_bottom • e_diag = (-1, 0) • (-ux, -uy) = ux.
    //    Thus phi_BL = acos( -ux ).
    final double phiBL = acos(-ux);
    //    So the offset along each edge is:
    final double tBL = r / tan(phiBL / 2);

    //    Top-left (TL) corner is between:
    //      - top edge:     e_top    = (1, 0),
    //      - diagonal:     e_diag   = (ux, uy) when traveling “down-right” from (0,0) to (D,H).
    //
    //    But in the path we come *backwards* along diagonal toward (0,0),
    //    so the local diagonal direction at the TL corner is (-ux, -uy).
    //    cos(phi_TL) = e_top • [(-ux, -uy)] = -ux.
    //    Thus phi_TL = acos( ux ).
    final double phiTL = acos(ux);
    final double tTL = r / tan(phiTL / 2);
    // tTL = r / (tan( acos(diagonalDepth / (diagonalDepth**2 + 65**2)) / 2))

    final Path path = Path();

    //
    // === Top-edge and top-right corner ===
    //

    // A) Start on the top edge, “tTL” points to the right of (0,0).
    path.moveTo(tTL, 0);

    // B) Draw straight to just before the top-right corner:
    path.lineTo(W - r, 0);

    // C) Round the top-right corner (a 90° corner) from (W - r, 0) → (W, r).
    path.arcToPoint(
      Offset(W, r),
      radius: Radius.circular(r),
      clockwise: true,
    );

    //
    // === Right edge and bottom-right corner (also 90°) ===
    //

    // D) Draw straight down from (W, r) → (W, H - r).
    path.lineTo(W, H - r);

    // E) Round the bottom-right 90° corner: (W, H - r) → (W - r, H).
    path.arcToPoint(
      Offset(W - r, H),
      radius: Radius.circular(r),
      clockwise: true,
    );

    //
    // === Bottom-edge and bottom-left diagonal corner ===
    //

    // F) Draw straight along the bottom from (W - r, H) → (D + tBL, H).
    path.lineTo(D + tBL, H);

    // G) Now round the diagonal corner.  
    //    We must go from (D + tBL, H) up/left to (D - ux*tBL, H - uy*tBL),
    //    at which point our circle of radius r will be tangent to both the bottom
    //    edge and the diagonal edge.
    path.arcToPoint(
      Offset(D - ux * tBL, H - uy * tBL),
      radius: Radius.circular(r),
      clockwise: true,
    );

    //
    // === Diagonal edge back up to top-left (rendezvous at tTL) ===
    //

    // H) Draw the straight (slanted) segment from (D - ux*tBL, H - uy*tBL)
    //    up to the point on the diagonal that is exactly tTL away from (0,0). 
    //    That point is (ux * tTL, uy * tTL).
    path.lineTo(ux * tTL, uy * tTL);

    // I) Finally round the top-left corner (acute angle). We go from (ux*tTL, uy*tTL)
    //    → (tTL, 0) with a circle of radius r, tangential to both the diagonal
    //    and the top edge.
    path.arcToPoint(
      Offset(tTL, 0),
      radius: Radius.circular(r),
      clockwise: true,
    );

    // J) Close the path back to the start.
    path.close();
    return path;
  }

  @override
  bool shouldReclip(DiagonalClipperTicketsButton oldClipper) {
    return oldClipper.diagonalDepth != diagonalDepth ||
           oldClipper.cornerRadius != cornerRadius;
  }
}