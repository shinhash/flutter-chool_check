import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final CameraPosition initialPostion = CameraPosition(
    target: LatLng(
      37.5216,
      126.9243,
    ),
    zoom: 16,
  );

  late GoogleMapController controller;
  bool choolcheckDone = false;
  bool canChoolCheck = false;
  final double okDistance = 100;

  checkPermision() async {
    final isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationEnabled) {
      throw Exception('위치 서비스 활성화 필요');
    }

    LocationPermission checkedPermision = await Geolocator.checkPermission();
    if (checkedPermision == LocationPermission.denied) {
      checkedPermision = await Geolocator.requestPermission();
    }

    if (checkedPermision != LocationPermission.always &&
        checkedPermision != LocationPermission.whileInUse) {
      throw Exception('위치 권한 허가 필요');
    }
  }

  @override
  void initState() {
    super.initState();
    Geolocator.getPositionStream().listen((event) {
      final start = LatLng(
        37.5216,
        126.9243,
      );
      final end = LatLng(
        event.latitude,
        event.longitude,
      );
      final distance = Geolocator.distanceBetween(
        start.latitude,
        start.longitude,
        end.latitude,
        end.longitude,
      );

      setState(() {
        if (distance > okDistance) {
          canChoolCheck = false;
        } else {
          canChoolCheck = true;
        }
      });
    });
  }

  /// FutureBuilder
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '오늘도 출근',
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: myLocationButton,
            icon: Icon(
              Icons.my_location,
            ),
            color: Colors.blue,
          ),
        ],
      ),
      body: FutureBuilder(
        future: checkPermision(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          return Column(
            children: [
              Expanded(
                flex: 2,
                child: _GoogleMap(
                  initialPostion: initialPostion,
                  onMapCreated: _onMapCreate,
                  okDistance: okDistance,
                  canChoolCheck: canChoolCheck,
                ),
              ),
              Expanded(
                flex: 1,
                child: _ChoolCheckButtons(
                  choolcheckDone: choolcheckDone,
                  canChoolCheck: canChoolCheck,
                  choolCheckProcess: choolCheckProcess,
                ),
              )
            ],
          );
        },
      ),
    );
  }

  myLocationButton() async {
    final location = await Geolocator.getCurrentPosition();

    controller.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(
          location.latitude,
          location.longitude,
        ),
      ),
    );
  }

  choolCheckProcess() async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('출근하기'),
          content: Text('출근 하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text('NO'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
              child: Text('YES'),
            ),
          ],
        );
      },
    );

    if (result != null && result) {
      setState(() {
        choolcheckDone = true;
      });
    }
  }

  _onMapCreate(GoogleMapController controller){
    this.controller = controller;
  }
}

class _GoogleMap extends StatefulWidget {
  final CameraPosition initialPostion;
  final MapCreatedCallback onMapCreated;
  final double okDistance;
  final bool canChoolCheck;

  const _GoogleMap({
    required this.initialPostion,
    required this.onMapCreated,
    required this.okDistance,
    required this.canChoolCheck,
    super.key,
  });

  @override
  State<_GoogleMap> createState() => _GoogleMapState();
}

class _GoogleMapState extends State<_GoogleMap> {
  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: widget.initialPostion,
      mapType: MapType.normal,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      onMapCreated: widget.onMapCreated,
      markers: {
        Marker(
          markerId: MarkerId('123'),
          position: LatLng(
            37.5216,
            126.9243,
          ),
        ),
      },
      circles: {
        Circle(
          circleId: CircleId('inDistance'),
          center: LatLng(
            37.5216,
            126.9243,
          ),
          radius: widget.okDistance,
          fillColor: widget.canChoolCheck
              ? Colors.blue.withOpacity(0.4)
              : Colors.red.withOpacity(0.4),
          strokeColor: widget.canChoolCheck ? Colors.blue : Colors.red,
          strokeWidth: 1,
        ),
      },
    );
  }
}

class _ChoolCheckButtons extends StatefulWidget {
  final bool choolcheckDone;
  final bool canChoolCheck;
  final VoidCallback choolCheckProcess;

  const _ChoolCheckButtons({
    required this.choolcheckDone,
    required this.canChoolCheck,
    required this.choolCheckProcess,
    super.key,
  });

  @override
  State<_ChoolCheckButtons> createState() => _ChoolCheckButtonsState();
}

class _ChoolCheckButtonsState extends State<_ChoolCheckButtons> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          widget.choolcheckDone ? Icons.check : Icons.timelapse_outlined,
          color: widget.choolcheckDone ? Colors.green : Colors.blue,
        ),
        SizedBox(
          height: 16,
        ),
        if (!widget.choolcheckDone && widget.canChoolCheck)
          OutlinedButton(
            onPressed: widget.choolCheckProcess,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue,
            ),
            child: Text('출근하기'),
          ),
      ],
    );
  }
}
