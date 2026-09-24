import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import '../../api/api_constants.dart';
import '../../widgets/mahal_details/custom_textfield.dart';
import '../../widgets/mahal_details/photo_grid_section.dart';
import '../../widgets/mahal_details/address_button.dart';

class MahalDetailsPage extends StatefulWidget {
  const MahalDetailsPage({super.key});

  @override
  State<MahalDetailsPage> createState() => _MahalDetailsPageState();
}

class _MahalDetailsPageState extends State<MahalDetailsPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ebNoController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController managerNameController = TextEditingController();
  final TextEditingController managerPhoneController = TextEditingController();
  final TextEditingController capacityController = TextEditingController();
  final TextEditingController facilityController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // Default Booking Timings Controllers
  final TextEditingController morningStartController = TextEditingController(text: "06:00 AM");
  final TextEditingController morningEndController = TextEditingController(text: "12:00 PM");
  final TextEditingController afternoonStartController = TextEditingController(text: "01:00 PM");
  final TextEditingController afternoonEndController = TextEditingController(text: "06:00 PM");
  final TextEditingController fullDayStartController = TextEditingController(text: "06:00 AM");
  final TextEditingController fullDayEndController = TextEditingController(text: "06:00 PM");
  final TextEditingController weddingStartController = TextEditingController(text: "06:00 PM");
  final TextEditingController weddingEndController = TextEditingController(text: "02:00 PM");

  final List<XFile?> _pickedImages = List.filled(6, null);
  bool _isLoadingTimings = false;

  @override
  void initState() {
    super.initState();
    _fetchDefaultTimings();
    _fetchMahalProfile();
  }

  Future<void> _fetchMahalProfile() async {
    if (ApiConstants.token == null) return;
    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.ownerUrl}/profile"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${ApiConstants.token}",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['mahal'] != null) {
          final mahal = data['mahal'];
          final String mahalName = mahal['mahal_name'] ?? '';
          final String mahalPrice = mahal['mahal_price']?.toString() ?? '';
          final String capacity = mahal['mahal_seating_capcity']?.toString() ?? '';
          final String facility = mahal['mahal_facility'] ?? '';
          final String managerName = mahal['mahal_manager_name'] ?? '';
          final String managerPhone = mahal['manager_mbl_no'] ?? '';
          final String rawDesc = mahal['mahal_describtion'] ?? '';

          String desc = rawDesc;
          String ebNo = '';
          if (rawDesc.contains(' | EB No: ')) {
            final parts = rawDesc.split(' | EB No: ');
            desc = parts[0].trim();
            ebNo = parts[1].trim();
          } else if (rawDesc.contains('EB No: ')) {
            final parts = rawDesc.split('EB No: ');
            desc = parts[0].trim();
            ebNo = parts[1].trim();
          }

          setState(() {
            if (mahalName.isNotEmpty) nameController.text = mahalName;
            if (mahalPrice.isNotEmpty) priceController.text = mahalPrice;
            if (capacity.isNotEmpty) capacityController.text = capacity;
            if (facility.isNotEmpty) facilityController.text = facility;
            if (managerName.isNotEmpty) managerNameController.text = managerName;
            if (managerPhone.isNotEmpty) managerPhoneController.text = managerPhone;
            if (desc.isNotEmpty) descriptionController.text = desc;
            if (ebNo.isNotEmpty) ebNoController.text = ebNo;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching mahal profile: $e");
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    ebNoController.dispose();
    priceController.dispose();
    managerNameController.dispose();
    managerPhoneController.dispose();
    capacityController.dispose();
    facilityController.dispose();
    descriptionController.dispose();

    morningStartController.dispose();
    morningEndController.dispose();
    afternoonStartController.dispose();
    afternoonEndController.dispose();
    fullDayStartController.dispose();
    fullDayEndController.dispose();
    weddingStartController.dispose();
    weddingEndController.dispose();

    super.dispose();
  }

  Future<void> _fetchDefaultTimings() async {
    if (ApiConstants.token == null) return;
    setState(() { _isLoadingTimings = true; });
    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.mahalUrl}/default-timings"),
        headers: {
          "Authorization": "Bearer ${ApiConstants.token}",
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['timings'] != null) {
          final timings = data['timings'];
          if (timings['Morning'] != null) {
            morningStartController.text = timings['Morning']['start_time'] ?? "06:00 AM";
            morningEndController.text = timings['Morning']['end_time'] ?? "12:00 PM";
          }
          if (timings['Afternoon'] != null) {
            afternoonStartController.text = timings['Afternoon']['start_time'] ?? "01:00 PM";
            afternoonEndController.text = timings['Afternoon']['end_time'] ?? "06:00 PM";
          }
          if (timings['Full Day'] != null) {
            fullDayStartController.text = timings['Full Day']['start_time'] ?? "06:00 AM";
            fullDayEndController.text = timings['Full Day']['end_time'] ?? "06:00 PM";
          }
          if (timings['Wedding'] != null) {
            weddingStartController.text = timings['Wedding']['start_time'] ?? "06:00 PM";
            weddingEndController.text = timings['Wedding']['end_time'] ?? "02:00 PM";
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching default timings: $e');
    } finally {
      if (mounted) {
        setState(() { _isLoadingTimings = false; });
      }
    }
  }

  Future<bool> _saveTimings() async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.mahalUrl}/default-timings"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${ApiConstants.token}",
        },
        body: jsonEncode({
          "timings": {
            "Morning": {
              "start_time": morningStartController.text.trim(),
              "end_time": morningEndController.text.trim(),
            },
            "Afternoon": {
              "start_time": afternoonStartController.text.trim(),
              "end_time": afternoonEndController.text.trim(),
            },
            "Full Day": {
              "start_time": fullDayStartController.text.trim(),
              "end_time": fullDayEndController.text.trim(),
            },
            "Wedding": {
              "start_time": weddingStartController.text.trim(),
              "end_time": weddingEndController.text.trim(),
            },
          }
        }),
      );

      final data = jsonDecode(response.body);
      if (!mounted) return false;
      if (response.statusCode != 200 || data['success'] != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Failed to save default timings.')),
        );
        return false;
      }
      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving default timings: $e')),
        );
      }
      return false;
    }
  }

  Future<void> _saveMahalDetails() async {
    final name = nameController.text.trim();
    final ebNo = ebNoController.text.trim();
    final price = priceController.text.trim();
    final managerName = managerNameController.text.trim();
    final managerPhone = managerPhoneController.text.trim();
    final capacity = capacityController.text.trim();
    final facility = facilityController.text.trim();
    final rawDesc = descriptionController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mahal name is required.')),
      );
      return;
    }

    try {
      final description = rawDesc + (ebNo.isNotEmpty ? " | EB No: $ebNo" : "");

      // 1. Save specifications
      final detailsResponse = await http.post(
        Uri.parse("${ApiConstants.mahalUrl}/details"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${ApiConstants.token}",
        },
        body: jsonEncode({
          "mahal_name": name,
          "mahal_price": price,
          "mahal_seating_capcity": capacity,
          "mahal_facility": facility,
          "mahal_describtion": description,
          "mahal_manager_name": managerName,
          "manager_mbl_no": managerPhone,
        }),
      );

      final detailsData = jsonDecode(detailsResponse.body);
      if (detailsResponse.statusCode != 200 || detailsData['success'] != true) {
        throw Exception(detailsData['message'] ?? 'Failed to save specs details.');
      }

      // 2. Upload image if selected
      if (_pickedImages.any((img) => img != null)) {
        final request = http.MultipartRequest(
          "POST",
          Uri.parse("${ApiConstants.mahalUrl}/image"),
        );
        request.headers["Authorization"] = "Bearer ${ApiConstants.token}";

        for (int i = 0; i < 6; i++) {
          if (_pickedImages[i] != null) {
            final img = _pickedImages[i]!;
            final bytes = await img.readAsBytes();
            
            final extension = img.name.split('.').last.toLowerCase();
            String mimeType = "image/jpeg";
            if (extension == "png") mimeType = "image/png";
            if (extension == "webp") mimeType = "image/webp";
            if (extension == "gif") mimeType = "image/gif";
            
            final mimeSplit = mimeType.split('/');
            final multipartFile = http.MultipartFile.fromBytes(
              "image_$i",
              bytes,
              filename: img.name,
              contentType: MediaType(mimeSplit[0], mimeSplit[1]),
            );
            request.files.add(multipartFile);
          }
        }

        final uploadResponse = await request.send();
        final responseData = await http.Response.fromStream(uploadResponse);
        final uploadData = jsonDecode(responseData.body);

        if (uploadResponse.statusCode != 200 || uploadData['success'] != true) {
          throw Exception(uploadData['message'] ?? 'Failed to upload images.');
        }
      }

      // 3. Save Default Timings
      final timingsSaved = await _saveTimings();
      if (!timingsSaved) return;

      if (mounted) {
        Navigator.pushNamed(context, '/mahal-address');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving specifications: $e')),
        );
      }
    }
  }

  Widget _buildTimePickerField(String label, TextEditingController controller) {
    return GestureDetector(
      onTap: () async {
        TimeOfDay initial = const TimeOfDay(hour: 6, minute: 0);
        final parts = controller.text.split(' ');
        if (parts.length == 2) {
          final sub = parts[0].split(':');
          int h = int.tryParse(sub[0]) ?? 6;
          int m = sub.length > 1 ? (int.tryParse(sub[1]) ?? 0) : 0;
          if (parts[1].toUpperCase() == 'PM' && h < 12) h += 12;
          if (parts[1].toUpperCase() == 'AM' && h == 12) h = 0;
          initial = TimeOfDay(hour: h, minute: m);
        }
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: initial,
        );
        if (picked != null && mounted) {
          final localizations = MaterialLocalizations.of(context);
          controller.text = localizations.formatTimeOfDay(picked, alwaysUse24HourFormat: false);
        }
      },
      child: AbsorbPointer(
        child: CustomTextField(
          hintText: label,
          controller: controller,
        ),
      ),
    );
  }

  Widget _buildBookingTypeTimingRow(String title, TextEditingController startCtrl, TextEditingController endCtrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildTimePickerField("Start Time", startCtrl),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTimePickerField("End Time", endCtrl),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(title: const Text('Mahal Details')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [

                const SizedBox(height: 20),

                /// TEXTFIELDS
                CustomTextField(
                  hintText: "Mahal name",
                  controller: nameController,
                ),

                const SizedBox(height: 15),

                CustomTextField(
                  hintText: "Mahal EB No",
                  controller: ebNoController,
                ),

                const SizedBox(height: 15),

                CustomTextField(
                  hintText: "Mahal price",
                  controller: priceController,
                ),

                const SizedBox(height: 15),

                /// PHOTO ADD
                const Text(
                  "Mahal photos add",
                  style: TextStyle(fontSize: 20),
                ),

                const SizedBox(height: 15),

                /// PHOTO GRID
                PhotoGridSection(
                  onImagePicked: (index, file) {
                    setState(() {
                      _pickedImages[index] = file;
                    });
                  },
                ),

                const SizedBox(height: 25),

                CustomTextField(
                  hintText: "Mahal manager name",
                  controller: managerNameController,
                ),

                const SizedBox(height: 15),

                CustomTextField(
                  hintText: "manager mbl no",
                  controller: managerPhoneController,
                ),

                const SizedBox(height: 15),

                CustomTextField(
                  hintText: "Mahal seating capacity",
                  controller: capacityController,
                ),

                const SizedBox(height: 15),

                CustomTextField(
                  hintText: "Ac / Non Ac",
                  controller: facilityController,
                ),

                const SizedBox(height: 15),

                CustomTextField(
                  hintText: "Description",
                  maxLines: 3,
                  controller: descriptionController,
                ),

                const SizedBox(height: 30),

                /// DEFAULT BOOKING TIME SETTINGS SECTION
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Default Booking Time Settings",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_isLoadingTimings)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                _buildBookingTypeTimingRow("1. Morning Booking", morningStartController, morningEndController),
                _buildBookingTypeTimingRow("2. Afternoon / Evening Booking", afternoonStartController, afternoonEndController),
                _buildBookingTypeTimingRow("3. Full Day Booking", fullDayStartController, fullDayEndController),
                _buildBookingTypeTimingRow("4. Wedding Booking", weddingStartController, weddingEndController),

                const SizedBox(height: 30),

                /// ADDRESS BUTTON
                AddressButton(
                  onPressed: _saveMahalDetails,
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}