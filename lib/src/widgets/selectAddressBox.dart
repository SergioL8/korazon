import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:korazon/src/utilities/models/userModel.dart';
import 'package:korazon/src/utilities/design_variables.dart';
import 'package:korazon/src/widgets/loading_place_holders.dart';




class SelectAddressBox extends StatefulWidget {
  const SelectAddressBox({super.key, required this.onAddressSelected, required this.error});
  final Function(LocationModel) onAddressSelected;
  final bool error;

  @override
  State<SelectAddressBox> createState() => _SelectAddressBoxState();
}


Future<List<Map<String, String>>?> placesAPI(String inputAddress) async {
  String placesAPIKey = dotenv.env['PLACES_API_KEY']!;
  final String apiUrl = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
  final Uri url = Uri.parse(
    '$apiUrl'
    '?input=$inputAddress'
    // '&types=street_address'
    '&location=40.0150,-105.2705' // Latitude, Longitude of Boulder
    '&radius=20000' // 20km (expands results but prioritizes Boulder)
    '&components=country:us'
    '&key=$placesAPIKey'
  );

  try{
    final response = await http.get(url);
    if (response.statusCode == 200) { // if the http response is successful
      final data = json.decode(response.body); // get the response body as json
      if (data['status'] == 'OK') { // if the response data is OK
        final List<dynamic> predictions = data['predictions'] as List<dynamic>;  // Force it to List<dynamic>.

        List<Map<String, String>> responseList = [];
        for (final p in predictions) {
          // p should be a Map<String, dynamic>
          final description = p['description']?.toString() ?? '';
          final placeID = p['place_id']?.toString() ?? '';
          responseList.add({
            'description': description,
            'placeID': placeID,
          });
        }
        return responseList; 
      } else if (data['status'] == 'ZERO_RESULTS') {
        return <Map<String, String>>[];
      } else {
        debugPrint('Error in response data: ${response.body}');
      }
    } else {
      debugPrint('Error in http call: $response');
    }
  } catch(e) {
    debugPrint('Error in catch: $e');
  }
  return null;
}


Future<LocationModel?> placeDetailsAPI(String placeID, String description) async {
  String placesDetailsAPIKey = dotenv.env['PLACES_DETAILS_API_KEY']!;
  final String url = 'https://maps.googleapis.com/maps/api/place/details/json'
    '?place_id=$placeID'
    '&key=$placesDetailsAPIKey';
  
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    if (data['status'] == 'OK') {
      final result = data['result'];
      final geometry = result['geometry'];
      final location = geometry['location'];
      final double lat = (location['lat'] as num).toDouble();
      final double lng = (location['lng'] as num).toDouble();

      // Extract address components (postal code, city, state, country)
      String? postalCode;
      String? city;
      String? state;
      String? country;
      List<dynamic> components = result['address_components'];

      for (var component in components) {
        List<dynamic> types = component['types'];
        if (types.contains('postal_code')) {
          postalCode = component['long_name'];
        }
        if (types.contains('locality')) {
          city = component['long_name'];
        }
        if (types.contains('administrative_area_level_1')) {
          state = component['long_name'];
        }
        if (types.contains('country')) {
          country = component['long_name'];
        }
      }
      
      return LocationModel(
        description: description,
        verifiedAddress: true,
        placeID: placeID,
        lat: lat,
        lon: lng,
        city: city,
        state: state,
        country: country,
        postalCode: postalCode,
      );
      

    }
  }
  return null;
}






class _SelectAddressBoxState extends State<SelectAddressBox> {

  final addressController = TextEditingController();
  final FocusNode addressFocusNode = FocusNode();
  bool isAddressFocused = false;
  Timer? _debounce;
  List<Map<String, String>>? addressList;
  bool verifiedAddress = false;
  bool emptyPredicitons = false;
  bool isLoading = false;
  LocationModel? returnedLocation;


  @override
  void initState() {
    super.initState();
    addressFocusNode.addListener(() {
      setState(() {
        isAddressFocused = addressFocusNode.hasFocus;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.3,
      width: double.infinity,
      child: Card(
        color: Colors.white.withOpacity(0.07),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: widget.error ? Colors.red : Colors.white,
            width: widget.error ? 2
            : isAddressFocused ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: 12, right: 12, top: 16, bottom: 16),
          child: Column(
            children: [
              TextFormField(
                autocorrect: false, // Disable auto-correction
                controller: addressController, // set the controller
                focusNode: addressFocusNode,
                style: whiteBody,
                cursorColor: Colors.white,
                onChanged: (s) {
                  setState(() {
                    verifiedAddress = false;
                    isLoading = true;
                  });
                  if (s.isEmpty) {
                    setState(() {
                      addressList = null;
                      isLoading = false;
                    });
                  }
                  if (_debounce?.isActive ?? false) _debounce?.cancel(); // if there is a previous time, cancel it
                  _debounce = Timer(const Duration(milliseconds: 400), () async { // wait for 500 milliseconds then execute the function
                    if (addressController.text.isNotEmpty) {
                      List<Map<String, String>>? tempList = await placesAPI(addressController.text);
                      if (tempList != null) {
                        setState(() {
                          isLoading = false;
                          addressList = tempList;
                        });
                        if (addressList!.isEmpty) { // if no address suggestions found
                          setState(() {
                            emptyPredicitons = true;
                          });
                        } else if (addressList![0]['description'] == addressController.text) { // if address is verified
                          returnedLocation = await placeDetailsAPI(addressList![0]['placeID']!, addressList![0]['description']!);
                          setState(() {
                            verifiedAddress = true;
                          });
                          widget.onAddressSelected(returnedLocation!);
                          return;
                        } else { // if address not verified
                          setState(() {
                            emptyPredicitons = false;
                          });
                        }
                      }
                    }
                  });
                  returnedLocation = LocationModel(description: addressController.text, verifiedAddress: false);
                  widget.onAddressSelected(returnedLocation!);
                },
                decoration: InputDecoration(
                  isCollapsed: false,
                  isDense: true,
                  hintText: 'Address',
                  hintStyle: whiteBody,
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              if (!isLoading && (addressList == null || verifiedAddress || emptyPredicitons))
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        emptyPredicitons ? 'No address suggestions found' :
                        verifiedAddress ? 'Valid Address!' :
                        'Starting typing to get address suggestions',
                        style: whiteBody,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
              else
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3 - 40 - 16*2,
                  child: ListView.builder(
                    itemCount: isLoading ? 5 :
                      addressList?.length ?? 0,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          isLoading ? Padding(
                            padding: EdgeInsets.all(8),
                            child: LoadingTextPlaceHolder(height: 45),
                          )
                          : ListTile(
                            title: Text(
                              addressList![index]['description']!,
                              style: whiteBody,
                            ),
                            onTap: () async {
                              addressController.text = addressList![index]['description']!;
                              returnedLocation = await placeDetailsAPI(addressList![index]['placeID']!, addressList![index]['description']!);
                              widget.onAddressSelected(returnedLocation!);
                              setState(() {
                                verifiedAddress = true;
                                addressList = null;
                              });
                            },
                          ),
                          if (index < (isLoading ? 5 : addressList?.length ?? 0) -1)
                            Divider(height: 1),
                        ],
                      );
                    } 
                  ),
                ),
            ],
          ),
        )
      ),
    );
  }
}