import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:uuid/uuid.dart';
import '../models/checkin_record.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';

class CheckinScreen extends StatefulWidget {
  const CheckinScreen({super.key});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _previousTopicController = TextEditingController();
  final _expectedTopicController = TextEditingController();
  final _locationService = LocationService();

  int _currentStep = 0;
  int _moodBefore = 3;
  double? _lat;
  double? _lng;
  String? _qrValue;
  bool _loadingLocation = false;
  bool _submitting = false;

  @override
  void dispose() {
    _previousTopicController.dispose();
    _expectedTopicController.dispose();
    super.dispose();
  }

  Future<void> _getLocation() async {
    setState(() => _loadingLocation = true);
    try {
      final position = await _locationService.getCurrentLocation();
      setState(() {
        _lat = position.latitude;
        _lng = position.longitude;
        _loadingLocation = false;
        _currentStep = 1;
      });
    } catch (e) {
      setState(() => _loadingLocation = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onQRScanned(String value) {
    setState(() {
      _qrValue = value;
      _currentStep = 2;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    try {
      final record = CheckinRecord(
        id: const Uuid().v4(),
        checkinTime: DateTime.now(),
        checkinLat: _lat!,
        checkinLng: _lng!,
        qrCodeValue: _qrValue!,
        previousTopic: _previousTopicController.text.trim(),
        expectedTopic: _expectedTopicController.text.trim(),
        moodBefore: _moodBefore,
      );

      await DatabaseService.instance.insertCheckin(record);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Check-in successful!'),
            backgroundColor: Color(0xFF00B894),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _submitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('📍 Class Check-in'),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF5A52D5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 10,
        shadowColor: const Color(0xFF6C63FF).withValues(alpha: 0.5),
      ),
      body: Stepper(
        currentStep: _currentStep,
        controlsBuilder: (context, details) => const SizedBox.shrink(),
        steps: [
          // Step 1: GPS
          Step(
            title: const Text('Get GPS Location'),
            subtitle: _lat != null
                ? Text('📍 ${_lat!.toStringAsFixed(4)}, ${_lng!.toStringAsFixed(4)}')
                : null,
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            content: Column(
              children: [
                const Text(
                  'Tap the button below to capture your GPS location.',
                  style: TextStyle(color: Color(0xFF636E72)),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _loadingLocation ? null : _getLocation,
                  icon: _loadingLocation
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.my_location),
                  label: Text(_loadingLocation ? 'Getting location...' : 'Capture Location'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Step 2: QR Code
          Step(
            title: const Text('Scan QR Code'),
            subtitle: _qrValue != null ? Text('✅ Scanned: $_qrValue') : null,
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            content: Column(
              children: [
                const Text(
                  'Scan the class QR code to verify your room.',
                  style: TextStyle(color: Color(0xFF636E72)),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF6C63FF).withValues(alpha: 0.3)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _currentStep == 1
                      ? MobileScanner(
                          onDetect: (capture) {
                            final barcode = capture.barcodes.firstOrNull;
                            if (barcode?.rawValue != null && _qrValue == null) {
                              _onQRScanned(barcode!.rawValue!);
                            }
                          },
                        )
                      : const Center(
                          child: Text('Complete previous step first'),
                        ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    _onQRScanned('MANUAL-${DateTime.now().millisecondsSinceEpoch}');
                  },
                  icon: const Icon(Icons.keyboard),
                  label: const Text('Skip (Manual Entry)'),
                ),
              ],
            ),
          ),

          // Step 3: Form
          Step(
            title: const Text('Learning Reflection'),
            isActive: _currentStep >= 2,
            state: StepState.indexed,
            content: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _previousTopicController,
                    decoration: InputDecoration(
                      labelText: 'Previous class topic',
                      hintText: 'What was covered last class?',
                      prefixIcon: const Icon(Icons.history_edu),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Please enter the previous topic'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _expectedTopicController,
                    decoration: InputDecoration(
                      labelText: 'Expected topic today',
                      hintText: 'What do you expect to learn?',
                      prefixIcon: const Icon(Icons.lightbulb_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Please enter expected topic'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'How are you feeling?',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(5, (index) {
                      final mood = index + 1;
                      final emojis = ['😡', '🙁', '😐', '🙂', '😄'];
                      final labels = [
                        'Very\nnegative',
                        'Negative',
                        'Neutral',
                        'Positive',
                        'Very\npositive',
                      ];
                      return GestureDetector(
                        onTap: () => setState(() => _moodBefore = mood),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _moodBefore == mood
                                ? const Color(0xFF6C63FF).withValues(alpha: 0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: _moodBefore == mood
                                ? Border.all(color: const Color(0xFF6C63FF), width: 2)
                                : null,
                          ),
                          child: Column(
                            children: [
                              Text(emojis[index], style: const TextStyle(fontSize: 28)),
                              const SizedBox(height: 4),
                              Text(
                                labels[index],
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B894),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        shadowColor: const Color(0xFF00B894).withValues(alpha: 0.5),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Submit Check-in ✅',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
