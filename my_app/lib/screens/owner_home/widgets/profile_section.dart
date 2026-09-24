import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../api/api_constants.dart';
import '../../../routes/app_routes.dart';

class ProfileSection extends StatefulWidget {
  final VoidCallback? onTap;

  const ProfileSection({super.key, this.onTap});

  @override
  State<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> {
  String mahalName = 'Mahal Owner';
  String? mahalImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchMahalProfile();
  }

  Future<void> _fetchMahalProfile() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.ownerUrl}/profile'),
        headers: {'Authorization': 'Bearer ${ApiConstants.token}'},
      );
      if (response.statusCode != 200 || !mounted) return;

      final data = jsonDecode(response.body);
      final mahal = data['mahal'] ?? {};
      final mahalId = mahal['mahal_id']?.toString() ?? '';
      setState(() {
        mahalName = mahal['mahal_name'] ?? 'Mahal Owner';
        mahalImageUrl = mahalId.isEmpty ? null : '${ApiConstants.mahalUrl}/$mahalId/image';
      });
    } catch (error) {
      debugPrint('Error fetching mahal profile: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap ?? () => Navigator.of(context).pushNamed(AppRoutes.ownerProfile),
      child: Row(
        children: [
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
              image: mahalImageUrl == null
                  ? null
                  : DecorationImage(
                      image: NetworkImage(mahalImageUrl!),
                      fit: BoxFit.cover,
                    ),
            ),
            child: mahalImageUrl == null
                ? const Icon(Icons.business, size: 34, color: Colors.deepOrange)
                : null,
          ),

          const SizedBox(width: 20),

          Expanded(
            child: Text(
              mahalName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
