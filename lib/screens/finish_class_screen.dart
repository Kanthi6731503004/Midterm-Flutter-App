import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:intl/intl.dart';
import '../models/checkin_record.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';

class FinishClassScreen extends StatefulWidget {
  const FinishClassScreen({super.key});

  @override
  State<FinishClassScreen> createState() => _FinishClassScreenState();
}

class _FinishClassScreenState extends State<FinishClassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _learnedController = TextEditingController();
  final _feedbackController = TextEditingController();
  final _locationService = LocationService();

  List<CheckinRecord> _activeSessions = [];
  CheckinRecord? _selectedSession;
  bool _loadingSessions = true;

  int _currentStep = 0;
  double? _lat;
  double? _lng;
  String? _qrValue;
  bool _loadingLocation = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadActiveSessions();
  }

  @override
  void dispose() {
    _learnedController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _loadActiveSessions() async {
    try {
      final records = await DatabaseService.instance.getActiveRecords();
      setState(() {
        _activeSessions = records;
        _loadingSessions = false;
        if (records.length == 1) {
          _selectedSession = records.first;
        }
      });
    } catch (e) {
      setState(() => _loadingSessions = false);
    }
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
          SnackBar(content: Text('$e'), backgroundColor: Colors.red),
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
    if (_selectedSession == null) return;

    setState(() => _submitting = true);

    try {
      await DatabaseService.instance.updateFinishClass(
        id: _selectedSession!.id,
        finishTime: DateTime.now(),
        finishLat: _lat!,
        finishLng: _lng!,
        learnedToday: _learnedController.text.trim(),
        feedback: _feedbackController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Class finished! Great job!'),
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
        title: const Text('🏁 Finish Class'),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF6B6B), Color(0xFFEE5253)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 10,
        shadowColor: const Color(0xFFFF6B6B).withValues(alpha: 0.5),
      ),
      body: _loadingSessions
          ? const Center(child: CircularProgressIndicator())
          : _activeSessions.isEmpty
              ? _buildNoActiveSessions()
              : _buildContent(),
    );
  }

  Widget _buildNoActiveSessions() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, size: 64, color: Color(0xFFB2BEC3)),
            const SizedBox(height: 16),
            const Text(
              'No Active Sessions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You need to check in first before finishing a class.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF636E72)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
              ),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final timeFormat = DateFormat('HH:mm');
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Session selector
          if (_activeSessions.length > 1) ...[
            const Text(
              'Select Session',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...(_activeSessions.map((session) {
              final isSelected = _selectedSession?.id == session.id;
              return GestureDetector(
                onTap: () => setState(() => _selectedSession = session),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFF6B6B)
                          : const Color(0xFFDFE6E9),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: isSelected
                            ? const Color(0xFFFF6B6B)
                            : const Color(0xFFB2BEC3),
                      ),
                      const SizedBox(width: 12),
                      Text(session.moodEmoji,
                          style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(session.expectedTopic,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            Text(
                              'Checked in at ${timeFormat.format(session.checkinTime)}',
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF636E72)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            })),
            const SizedBox(height: 16),
          ] else if (_selectedSession != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFF6B6B).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Text(_selectedSession!.moodEmoji,
                      style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedSession!.expectedTopic,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Checked in at ${timeFormat.format(_selectedSession!.checkinTime)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF636E72),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (_selectedSession != null)
            Stepper(
              currentStep: _currentStep,
              physics: const ClampingScrollPhysics(),
              controlsBuilder: (context, details) => const SizedBox.shrink(),
              steps: [
                // Step 1: GPS
                Step(
                  title: const Text('Get GPS Location'),
                  subtitle: _lat != null
                      ? Text(
                          '📍 ${_lat!.toStringAsFixed(4)}, ${_lng!.toStringAsFixed(4)}')
                      : null,
                  isActive: _currentStep >= 0,
                  state:
                      _currentStep > 0 ? StepState.complete : StepState.indexed,
                  content: Column(
                    children: [
                      const Text(
                        'Capture your GPS to confirm you\'re still in class.',
                        style: TextStyle(color: Color(0xFF636E72)),
                      ),
                      const SizedBox(height: 12),
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
                        label: Text(_loadingLocation
                            ? 'Getting location...'
                            : 'Capture Location'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B6B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
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
                  subtitle:
                      _qrValue != null ? Text('✅ Scanned: $_qrValue') : null,
                  isActive: _currentStep >= 1,
                  state:
                      _currentStep > 1 ? StepState.complete : StepState.indexed,
                  content: Column(
                    children: [
                      const Text(
                        'Scan the class QR code again to finish.',
                        style: TextStyle(color: Color(0xFF636E72)),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 250,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFFF6B6B).withValues(alpha: 0.3),
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _currentStep == 1
                            ? MobileScanner(
                                onDetect: (capture) {
                                  final barcode =
                                      capture.barcodes.firstOrNull;
                                  if (barcode?.rawValue != null &&
                                      _qrValue == null) {
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
                          _onQRScanned(
                              'MANUAL-${DateTime.now().millisecondsSinceEpoch}');
                        },
                        icon: const Icon(Icons.keyboard),
                        label: const Text('Skip (Manual Entry)'),
                      ),
                    ],
                  ),
                ),

                // Step 3: Reflection form
                Step(
                  title: const Text('Post-Class Reflection'),
                  isActive: _currentStep >= 2,
                  state: StepState.indexed,
                  content: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _learnedController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'What did you learn today?',
                            hintText: 'Summarize what you learned...',
                            prefixIcon: const Icon(Icons.school),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Please describe what you learned'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _feedbackController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Feedback',
                            hintText:
                                'Any feedback about the class or instructor?',
                            prefixIcon: const Icon(Icons.feedback_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Please provide feedback'
                              : null,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submitting ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00B894),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 18),
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
                                    'Finish Class 🎉',
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
        ],
      ),
    );
  }
}
