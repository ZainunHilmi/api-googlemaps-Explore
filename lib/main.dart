import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Maps Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const MapScreen(),
    const PlacesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Peta',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.place),
            label: 'Tempat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  LatLng? _currentLocation;
  bool _isLoading = true;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  final MapType _currentMapType = MapType.normal;
  double _zoomLevel = 14.0;

  // Contoh data tempat menarik di Jakarta
  final List<Map<String, dynamic>> _popularPlaces = [
    {
      'id': 'monas',
      'name': 'Monumen Nasional',
      'location': const LatLng(-6.1754, 106.8272),
      'description': 'Monumen peringatan kemerdekaan Indonesia',
      'type': 'landmark',
    },
    {
      'id': 'bundaran_hi',
      'name': 'Bundaran HI',
      'location': const LatLng(-6.1968, 106.8229),
      'description': 'Hotel Indonesia Roundabout',
      'type': 'landmark',
    },
    {
      'id': 'gbk',
      'name': 'Gelora Bung Karno',
      'location': const LatLng(-6.2190, 106.8006),
      'description': 'Stadion utama Indonesia',
      'type': 'sport',
    },
    {
      'id': 'taman_mini',
      'name': 'Taman Mini Indonesia',
      'location': const LatLng(-6.3024, 106.8942),
      'description': 'Taman budaya Indonesia',
      'type': 'park',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    // Request permission lokasi
    final status = await Permission.location.request();
    
    if (status.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _isLoading = false;
          _addMarkers();
          _addSamplePolyline();
        });
      } catch (e) {
        // Fallback ke lokasi default (Jakarta)
        _setDefaultLocation();
      }
    } else {
      _setDefaultLocation();
    }
  }

  void _setDefaultLocation() {
    setState(() {
      _currentLocation = const LatLng(-6.2088, 106.8456); // Jakarta
      _isLoading = false;
      _addMarkers();
      _addSamplePolyline();
    });
  }

  void _addMarkers() {
    // Marker untuk lokasi saat ini
    if (_currentLocation != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(
            title: 'Lokasi Anda',
            snippet: 'Anda berada di sini',
          ),
        ),
      );
    }

    // Marker untuk tempat populer
    for (var place in _popularPlaces) {
      BitmapDescriptor icon;
      switch (place['type']) {
        case 'landmark':
          icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
          break;
        case 'sport':
          icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
          break;
        case 'park':
          icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
          break;
        default:
          icon = BitmapDescriptor.defaultMarker;
      }

      _markers.add(
        Marker(
          markerId: MarkerId(place['id']),
          position: place['location'],
          icon: icon,
          infoWindow: InfoWindow(
            title: place['name'],
            snippet: place['description'],
          ),
          onTap: () {
            _showPlaceDetails(place);
          },
        ),
      );
    }
  }

  void _addSamplePolyline() {
    // Contoh polyline dari Monas ke GBK
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('sample_route'),
        points: [
          const LatLng(-6.1754, 106.8272), // Monas
          const LatLng(-6.1968, 106.8229), // Bundaran HI
          const LatLng(-6.2190, 106.8006), // GBK
        ],
        color: Colors.blue,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ),
    );
  }

  void _showPlaceDetails(Map<String, dynamic> place) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getPlaceIcon(place['type']),
                    color: Colors.blue,
                    size: 30,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      place['name'],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                place['description'],
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      _goToLocation(place['location']);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.navigation),
                    label: const Text('Navigasi'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      _addToFavorites(place);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.favorite_border),
                    label: const Text('Favorit'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getPlaceIcon(String type) {
    switch (type) {
      case 'landmark':
        return Icons.landscape;
      case 'sport':
        return Icons.sports_soccer;
      case 'park':
        return Icons.park;
      default:
        return Icons.place;
    }
  }

  void _goToLocation(LatLng location) {
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: location,
          zoom: 15,
          bearing: 0,
          tilt: 0,
        ),
      ),
    );
  }

  void _addToFavorites(Map<String, dynamic> place) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${place['name']} ditambahkan ke favorit'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _goToCurrentLocation() async {
    if (_currentLocation != null) {
      await _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentLocation!,
            zoom: _zoomLevel,
          ),
        ),
      );
    }
  }

  void _changeMapType() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 200,
          child: Column(
            children: [
              ListTile(
                title: const Text('Normal'),
                leading: const Icon(Icons.map),
                onTap: () {
                  setState(() {
                    // _currentMapType = MapType.normal;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Satellite'),
                leading: const Icon(Icons.satellite),
                onTap: () {
                  setState(() {
                    // _currentMapType = MapType.satellite;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Hybrid'),
                leading: const Icon(Icons.terrain),
                onTap: () {
                  setState(() {
                    // _currentMapType = MapType.hybrid;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.layers),
            onPressed: _changeMapType,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Memuat peta...'),
                ],
              ),
            )
          : GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _currentLocation ?? const LatLng(-6.2088, 106.8456),
                zoom: _zoomLevel,
              ),
              markers: _markers,
              polylines: _polylines,
              mapType: _currentMapType,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              compassEnabled: true,
              zoomControlsEnabled: false,
              onCameraMove: (position) {
                _zoomLevel = position.zoom;
              },
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            onPressed: () {
              setState(() {
                _zoomLevel += 1;
              });
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.small(
            onPressed: () {
              setState(() {
                _zoomLevel -= 1;
              });
            },
            child: const Icon(Icons.remove),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _goToCurrentLocation,
            child: const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }
}

class PlacesScreen extends StatelessWidget {
  const PlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tempat Menarik'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.landscape, color: Colors.red),
            title: const Text('Monumen Nasional'),
            subtitle: const Text('Jakarta Pusat'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart, color: Colors.green),
            title: const Text('Grand Indonesia'),
            subtitle: const Text('Shopping Mall'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.park, color: Colors.orange),
            title: const Text('Taman Mini Indonesia'),
            subtitle: const Text('Taman Budaya'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                  'https://ui-avatars.com/api/?name=User&background=random'),
            ),
            SizedBox(height: 20),
            Text(
              'Pengguna Google Maps',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Selamat menggunakan aplikasi peta!',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}