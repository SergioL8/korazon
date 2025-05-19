import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/utilities/models/eventModel.dart';
import 'package:korazon/src/widgets/alertBox.dart';
import 'package:korazon/src/widgets/selectDateTime.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:korazon/src/utilities/utils.dart';
import 'package:uuid/uuid.dart';



class TicketCreationScreen extends StatefulWidget {
  const TicketCreationScreen({super.key, this.ticket});

  final TicketModel? ticket;

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
      debugPrint('End date time is null');
      _enTicketdDateTimeController = null;
    } else {
      _enTicketdDateTimeController = Timestamp.fromDate(endDateTime); // update the end date time controller
    }
  }


  void _saveTicket() {

    // Dismiss the keyboard
    FocusScope.of(context).unfocus();

    if (_ticketNameController.text.isEmpty) {
      showErrorMessage(context, title:'Please enter a ticket name');
      return;
    }
    if (_ticketPriceController.text.isEmpty) {
      _ticketPriceController.text = '0.00';
    }
    if (_startTicketDateTimeController != null && _enTicketdDateTimeController != null) { // check if the end date is before the start date
      final startDate = _startTicketDateTimeController!.toDate();
      final endDate = _enTicketdDateTimeController!.toDate();
      if (endDate.isBefore(startDate)) { // check if the end date is before the start date
        showErrorMessage(context, title: 'The end date must be after the start date');
        return;
      }
    }

    // easter egg: ticket capacity is "a positive number"
    if (_ticketMaxCapacityController.text.isNotEmpty) {
      if (_ticketMaxCapacityController.text == 'a positive number') {
        showErrorMessage(context, title: 'wtf, how did you figure this out?');
        return;
      }
      final ticketCapacity = int.tryParse(_ticketMaxCapacityController.text);
      if (ticketCapacity != null && ticketCapacity == 0) {
        showErrorMessage(context, title: 'Ticket capacity must be a positive number');
        return;
      }
    }


    // check that the ticket capacity is a whole non negative number
    if (_ticketMaxCapacityController.text.isNotEmpty) {
      final ticketCapacity = int.tryParse(_ticketMaxCapacityController.text);
      if (ticketCapacity == null || ticketCapacity < 0) {
        showErrorMessage(context, title: 'Ticket capacity must be a positive number');
        return;
      }
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
  void initState() {
    super.initState();
    if (widget.ticket != null) {
      debugPrint('In ticket creation, end ticket entry time: ${widget.ticket!.ticketEntryTimeEnd}');
      _ticketNameController.text = widget.ticket!.ticketName;
      _ticketPriceController.text = widget.ticket!.ticketPrice == 0.0 ? '' : widget.ticket!.ticketPrice.toStringAsFixed(2);
      _ticketDescriptionController.text = widget.ticket!.ticketDescription ?? '';
      _startTicketDateTimeController = widget.ticket!.ticketEntryTimeStart;
      _enTicketdDateTimeController = widget.ticket!.ticketEntryTimeEnd;
      if (widget.ticket!.ticketCapacity?.toString() == null || widget.ticket!.ticketCapacity?.toString() == '9999999') {
        _ticketMaxCapacityController.text = '';
      } else {
        _ticketMaxCapacityController.text = widget.ticket!.ticketCapacity?.toString() ?? '';
      }
      _genderController.text = widget.ticket!.genderRestriction;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Dismiss the keyboard
      },
      child: Scaffold(
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
                color: Colors.white.withValues(alpha: 0.80)
              ),
            )
          ),
          title: Text(
            'Add New Ticket',
            style: whiteSubtitle,
          ),
        ),
        body: Center(
          child: SingleChildScrollView( // makes the column scrollable
            child: Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.03), // 3% padding on all sides
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
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                              floatingLabelBehavior: FloatingLabelBehavior.never,
                              labelText: 'Ticket Name',
                              labelStyle: whiteBody,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.black.withValues(alpha: 0.25),
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
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    CurrencyInputFormatter(),
                                  ],
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
                                    fillColor: Colors.black.withValues(alpha: 0.25),
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
                      fillColor: Colors.white.withValues(alpha: 0.06),
                      hintText: 'E.g. Gender Restrictions \n      Entrance Time \n      Dress Code',
                      hintStyle: whiteBody.copyWith(
                        color: Colors.white.withValues(alpha: 0.80),
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

                  SelectDateTime(onDateChanged: _onDateTimeSelected, dateTimeUse: DateTimeUse.ticket, startDateTime: _startTicketDateTimeController, endDateTime: _enTicketdDateTimeController,),

                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
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
                              keyboardType: TextInputType.number,
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
                                fillColor: Colors.black.withValues(alpha: 0.40),
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






// A TextInputFormatter that formats digits as currency with two decimals (e.g., "00.00").
class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.currency(
    locale: 'en_US', symbol: '', decimalDigits: 2,
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove any non-digit characters
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    // Parse to integer (cents)
    final int cents = int.tryParse(digitsOnly) ?? 0;
    // Format the value as dollars and cents
    final newText = _formatter.format(cents / 100);
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}