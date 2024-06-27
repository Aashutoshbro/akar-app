import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _selectedLocation;
  String? _address;
  final TextEditingController _addressController = TextEditingController();
  final MapController _mapController = MapController();
  bool _isLoading = false;
  double _currentZoom = 13.0;
  bool _isDragging = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    setState(() => _isLoading = true);
    try {
      final position = await _determinePosition();
      _handleTap(LatLng(position.latitude, position.longitude));
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
      _handleTap(LatLng(27.7172, 85.3240)); // Default to Kathmandu
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Select Location')),
      body: Stack(
        children: [
          _buildMap(),
          _buildAddressDisplay(),
          _buildSearchBar(),
          _buildZoomControl(),
          _buildCenterIndicator(),
          if (_isLoading) _buildLoadingIndicator(),
          _buildFloatingActionButtons(),
        ],
      ),
     // floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        center: _selectedLocation ?? LatLng(27.7172, 85.3240),
        zoom: _currentZoom,
        minZoom: 5.0,
        maxZoom: 18.0,
        onTap: (_, point) => _handleTap(point),
        onPositionChanged: _handlePositionChanged,
      ),
      children: [
        TileLayer(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: const ['a', 'b', 'c'],
        ),
        if (_selectedLocation != null) _buildMarkerLayer(),
      ],
    );
  }

  Widget _buildMarkerLayer() {
    return MarkerLayer(
      markers: [
        Marker(
          width: 80.0,
          height: 80.0,
          point: _selectedLocation!,
          builder: (ctx) => GestureDetector(
            onPanStart: (_) => setState(() => _isDragging = true),
            onPanUpdate: _handleMarkerDrag,
            onPanEnd: (_) => _onDragEnd(),
            child: AnimatedScale(
              duration: Duration(milliseconds: 100),
              scale: _isDragging ? 1.2 : 1.0,
              child: Icon(Icons.location_on, color: Colors.red, size: 40.0),
            ),
          ),
        ),
      ],
    );
  }


  void _handleMarkerDrag(DragUpdateDetails details) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final newPosition = renderBox.globalToLocal(details.globalPosition);
    final newPoint = _mapController.pointToLatLng(CustomPoint(newPosition.dx, newPosition.dy));
    setState(() => _selectedLocation = newPoint);
  }

  void _onDragEnd() {
    setState(() => _isDragging = false);
    _debouncedUpdateAddress(_selectedLocation!);
  }

  void _debouncedUpdateAddress(LatLng point) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: 300), () => _updateAddress(point));
  }

  void _handlePositionChanged(MapPosition position, bool hasGesture) {
    if (hasGesture) {
      setState(() {
        _currentZoom = position.zoom ?? _currentZoom;
        _selectedLocation = position.center;
      });
      _debouncedUpdateAddress(position.center!);
    }
  }



  Widget _buildAddressDisplay() {
    return _address != null
        ? Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10.0, offset: Offset(0, 2))],
        ),
        child: Text(_address!, style: const TextStyle(fontSize: 16.0)),
      ),
    )
        : const SizedBox.shrink();
  }

  Widget _buildSearchBar() {
    return Positioned(
      top: 10,
      left: 10,
      right: 10,
      child: TypeAheadField(
        textFieldConfiguration: TextFieldConfiguration(
          controller: _addressController,
          decoration: InputDecoration(
            hintText: 'Enter an address',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => _addressController.clear(),
            ),
          ),
        ),
        suggestionsCallback: _fetchAddressSuggestions,
        itemBuilder: (context, suggestion) {
          return ListTile(
            title: Text(suggestion['display_name']),
          );
        },
        onSuggestionSelected: (suggestion) {
          _addressController.text = suggestion['display_name'];
          _handleTap(LatLng(
            double.parse(suggestion['lat']),
            double.parse(suggestion['lon']),
          ));
        },
      ),
    );
  }

  Widget _buildZoomControl() {
    return Positioned(
      top: 100,
      right: 14,
      child: Column(
        children: [
          FloatingActionButton(
            mini: true,
            child: Icon(Icons.add),
            onPressed: () => _changeZoom(1),
            heroTag: 'zoom_in_button',
          ),
          SizedBox(height: 8),
          FloatingActionButton(
            mini: true,
            child: Icon(Icons.remove),
            onPressed: () => _changeZoom(-1),
            heroTag: 'zoom_out_button',
          ),
        ],
      ),
    );
  }

  void _changeZoom(double delta) {
    final newZoom = (_currentZoom + delta).clamp(5.0, 18.0);
    _mapController.move(_mapController.center, newZoom);
    setState(() => _currentZoom = newZoom);
  }


  Widget _buildCenterIndicator() {
    return Stack(
      children: [
        Center(
          child: Container(
            height: 20,
            width: 1,
            color: Colors.blue,
          ),
        ),
        Center(
          child: Container(
            height: 1,
            width: 20,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
  Widget _buildFloatingActionButtons() {
    return Positioned(
      right: 16,
      bottom: 100, // Adjust this value to move the buttons up or down
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _getCurrentLocation,
            child: const Icon(Icons.my_location),
            heroTag: 'location_button',
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _confirmLocation,
            child: const Icon(Icons.check),
            heroTag: 'confirm_button',
          ),
        ],
      ),
    );
  }
  //
  // Future<void> _updateAddress(LatLng point) async {
  //   //setState(() => _isLoading = true);
  //   try {
  //     final List<Placemark> placemarks = await placemarkFromCoordinates(
  //       point.latitude,
  //       point.longitude,
  //       localeIdentifier: 'en',
  //     );
  //     if (placemarks.isNotEmpty) {
  //       final place = placemarks.first;
  //       setState(() {
  //         _address = [
  //           place.street,
  //           place.subLocality,
  //           place.locality,
  //           place.postalCode,
  //           place.country,
  //         ].where((e) => e != null && e.isNotEmpty).join(', ');
  //       });
  //     }
  //   } catch (e) {
  //     _showErrorSnackBar('Error getting address: ${e.toString()}');
  //   } finally {
  //     setState(() => _isLoading = false);
  //   }
  // }

  String formatAddress(Placemark place) {
    if (place.country?.toLowerCase() == 'nepal') {
      return [
        place.street,
        place.subLocality,
        place.locality,
        '${place.subAdministrativeArea} Municipality', // Assuming subAdministrativeArea is the municipality
        '${place.administrativeArea} ',        // Assuming administrativeArea is the province
        place.postalCode,
        place.country,
      ].where((e) => e != null && e.isNotEmpty).join(', ');
    } else {
      // Default formatting for other countries
      return [
        place.street,
        place.subLocality,
        place.locality,
        place.subAdministrativeArea,
        place.administrativeArea,
        place.postalCode,
        place.country,
      ].where((e) => e != null && e.isNotEmpty).join(', ');
    }
  }

  Future<void> _updateAddress(LatLng point) async {
    try {
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        point.latitude,
        point.longitude,
        localeIdentifier: 'en',
      );
      if (placemarks.isNotEmpty) {
        setState(() {
          _address = formatAddress(placemarks.first);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error getting address: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }


  Future<List<Map<String, dynamic>>> _fetchAddressSuggestions(String query) async {
    if (query.length <= 2) return [];

    final response = await http.get(Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=$query&limit=5'));

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      Position position = await Geolocator.getCurrentPosition();
      _handleTap(LatLng(position.latitude, position.longitude));
    } catch (e) {
      _showErrorSnackBar('Unable to get current location: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleTap(LatLng point) async {
    setState(() {
      _selectedLocation = point;
      _isLoading = true;
    });

    await _updateAddress(point);

    setState(() => _isLoading = false);
    _mapController.move(point, _currentZoom);
  }

  void _confirmLocation() {
    if (_selectedLocation != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm Location'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInfoRow('Latitude:', _selectedLocation!.latitude.toStringAsFixed(6)),
                _buildInfoRow('Longitude:', _selectedLocation!.longitude.toStringAsFixed(6)),
                if (_address != null) _buildInfoRow('Address:', _address!),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, {
                    'location': _selectedLocation,
                    'address': _address,
                  });
                },
                child: const Text('Confirm'),
              ),
            ],
          );
        },
      );
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(label, style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right),
          ),
          SizedBox(width: 10),
          Expanded(
            flex: 5,
            child: Text(value, textAlign: TextAlign.left),
          ),
        ],
      ),
    );
  }
}