import 'package:flutter/material.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/utilities/models/eventModel.dart';
import 'package:korazon/src/widgets/alertBox.dart';
import 'package:korazon/src/widgets/selectDateTime.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:uuid/uuid.dart';




class TicketCreationScreen extends StatefulWidget {
  const TicketCreationScreen({super.key});

  @override
  State<TicketCreationScreen> createState() => _TicketCreationScreenState();
}


class _TicketCreationScreenState extends State<TicketCreationScreen> {

  final TextEditingController _ticketNameController = TextEditingController();
  final TextEditingController _ticketPriceController = TextEditingController();
  final TextEditingController _ticketDescriptionController = TextEditingController();
  final TextEditingController _ticketMaxCapacityController = TextEditingController();
  final TextEditingController _genderController = TextEditingController(text: 'all');
  Timestamp? _startTicketDateTimeController;
  Timestamp? _enTicketdDateTimeController;
  final FocusNode descriptionFocusNode = FocusNode();
  bool isDescriptionFocused = false;


  void _onDateTimeSelected(DateTime? startDateTime, DateTime? endDateTime) {
    debugPrint('Start date time: $startDateTime');
    debugPrint('End date time: $endDateTime');
    if (startDateTime == null) {
      _startTicketDateTimeController = null;
    } else{
      _startTicketDateTimeController = Timestamp.fromDate(startDateTime); // update the start date time controller
    }
    if (endDateTime == null) {
      _enTicketdDateTimeController = null;
    } else {
      _enTicketdDateTimeController = Timestamp.fromDate(endDateTime); // update the end date time controller
    }
  }


  void _saveTicket() {
    if (_ticketNameController.text.isEmpty) {
      showErrorMessage(context, title:'Please enter a ticket name');
      return;
    }
    if (_ticketPriceController.text.isEmpty) {
      showErrorMessage(context, title: 'Please enter a ticket price');
      return;
    }
    
    final String uuid = Uuid().v4();
    var ticket = TicketModel(
      ticketID: uuid,
      ticketName: _ticketNameController.text,
      ticketPrice: double.parse(_ticketPriceController.text),
      ticketDescription: _ticketDescriptionController.text.isNotEmpty ? _ticketDescriptionController.text : null,
      ticketEntryTimeStart: _startTicketDateTimeController,
      ticketEntryTimeEnd: _enTicketdDateTimeController,
      ticketCapacity: _ticketMaxCapacityController.text.isNotEmpty ? int.parse(_ticketMaxCapacityController.text) : null,
      genderRestriction: _genderController.text,
    );
    Navigator.of(context).pop<TicketModel>(ticket);
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColorBM,
      appBar: AppBar(
        backgroundColor: backgroundColorBM,
        leadingWidth: 80,
        leading: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Cancel',
            style: whiteBody.copyWith(
              color: Colors.white.withOpacity(0.80)
            ),
          )
        ),
        title: Text(
          'Add New Ticket',
          style: whiteSubtitle,
        ),
      ),
      body:SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - kToolbarHeight + 150),
          child: IntrinsicHeight(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children:[
                ClipPath(
                  clipper: TicketClipper(),
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      gradient: linearGradient,
                    ),
                    child: Column(
                      children: [
                        TextFormField(
                          style: whiteBody,
                          controller: _ticketNameController,
                          cursorColor: Colors.white,
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            labelText: 'Ticket Name',
                            labelStyle: whiteBody,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.black.withOpacity(0.25),
                          ),
                        ),
                    
                        const SizedBox(height: 16),
                    
                        // Dotted perforation line
                        SizedBox(
                          width: double.infinity,
                          height: 1,
                          child: CustomPaint(
                            painter: DottedLinePainter(),
                          ),
                        ),
                    
                        const SizedBox(height: 16),
                    
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Price',
                              style: whiteBody
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 100,
                              child: TextFormField(
                                style: whiteBody,
                                controller: _ticketPriceController,
                                cursorColor: Colors.white,
                                decoration: InputDecoration(
                                  floatingLabelBehavior: FloatingLabelBehavior.never,
                                  label: Text(
                                    'Free',
                                    style: whiteBody,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.attach_money,
                                    color: Colors.white,
                                  ),
                                  prefixIconConstraints: const BoxConstraints(
                                    minWidth: 32,   // instead of the ~48px default
                                    minHeight: 32,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 14,   // adjust for your text height
                                    horizontal: 8,  // small horizontal padding
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.black.withOpacity(0.25),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextField( // DESCRIPTION text field
                  minLines: 3, // make the text field thicker
                  maxLines: 5,
                  style: whiteBody,
                  cursorColor: Colors.white,
                  textCapitalization: TextCapitalization.sentences,
                  controller: _ticketDescriptionController, // set the controller
                  focusNode: descriptionFocusNode,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.07),
                    hintText: 'E.g. Gender Restrictions \n      Entrance Time \n      Dress Code',
                    hintStyle: whiteBody.copyWith(
                      color: Colors.white.withOpacity(0.40),
                    ),
                    labelText: 'Description',
                    labelStyle: whiteSubtitle.copyWith(
                      fontWeight: isDescriptionFocused ? FontWeight.w800 : FontWeight.w400,
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always, // Always show label at the top left
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15), // rounded corners
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15), // Rounded corners
                      borderSide: BorderSide(color: Colors.white)
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15), // Rounded corners
                      borderSide: BorderSide(color: Colors.white)
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SelectDateTime(onDateChanged: _onDateTimeSelected, dateTimeUse: DateTimeUse.ticket,),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.white,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ticket Capacity',
                          style: whiteBody,
                        ),
                        SizedBox(
                          width: 100,
                          child: TextFormField(
                            style: whiteBody,
                            controller: _ticketMaxCapacityController,
                            cursorColor: Colors.white,
                            decoration: InputDecoration(
                              floatingLabelBehavior: FloatingLabelBehavior.never,
                              label: Text(
                                'Unlimited',
                                style: whiteBody,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14,   // adjust for your text height
                                horizontal: 8,  // small horizontal padding
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.black.withOpacity(0.25),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Restrict ticket to a gender:',
                    style: whiteBody,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _genderController.text = 'all';
                              });
                            },
                            child: Icon(
                              Icons.transgender,
                              color: _genderController.text == 'all' ? korazonColor : const Color.fromARGB(255, 123, 123, 123),
                              size: 50,
                            ),
                          ),
                          Text(
                            'All Genders',
                            style: TextStyle(
                              color: _genderController.text == 'all' ? korazonColor : const Color.fromARGB(255, 123, 123, 123),
                            ),
                          ),
                        ]
                      ),
                      
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _genderController.text = 'Male';
                              });
                            },
                            child: Icon(
                              Icons.male_rounded,
                              color: _genderController.text == 'Male' ? Colors.blue[700] : const Color.fromARGB(255, 123, 123, 123),
                              size: 50,
                            ),
                          ),
                          Text(
                            'Male',
                            style: TextStyle(
                              color: _genderController.text == 'Male' ? Colors.blue[700] : const Color.fromARGB(255, 123, 123, 123),
                            ),
                          ),
                        ]
                      ),
                  
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _genderController.text = 'Female';
                              });
                            },
                            child: Icon(
                              Icons.female_rounded,
                              color: _genderController.text == 'Female' ? Colors.purple[600] : const Color.fromARGB(255, 123, 123, 123),
                              size: 50,
                            ),
                          ),
                          Text(
                            'Female',
                            style: TextStyle(
                              color: _genderController.text == 'Female' ? Colors.purple[600] : const Color.fromARGB(255, 123, 123, 123),
                            ),
                          ),
                        ]
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Spacer(),
                GestureDetector(
                  onTap: _saveTicket,
                  child: Container(
                    width: double.infinity,
                    height: 75,
                    decoration: BoxDecoration(
                      gradient: linearGradient,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Text(
                        'Save',
                        style: whiteSubtitle.copyWith(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                        )
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}






/// Clips the container into a ticket shape with scalloped side notches.
class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const notchRadius = 16.0;
    final halfHeight = size.height / 2;
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