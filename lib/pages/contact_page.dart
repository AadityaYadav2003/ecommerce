import 'package:flutter/material.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Add an image at the top
          Center(
            child: Image.network(
              'data:image/jpeg;base64,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', // Replace with your image URL
              height: 150,
              width: 150,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 20), // Add some space between the image and the contact info

          // Contact information tiles
          const ContactInfoTile(
            icon: Icons.person,
            label: 'Name',
            value: 'Raviva Infotech',
          ),
          const ContactInfoTile(
            icon: Icons.phone,
            label: 'Phone Number',
            value: '+91 7045599660',
          ),
          const ContactInfoTile(
            icon: Icons.email,
            label: 'Email',
            value: 'ravivainfotech@gmail.com',
          ),
          const ContactInfoTile(
            icon: Icons.location_on,
            label: 'Address',
            value:
                'SHOP NO. 16, SAI VIHAR CHOWL, DEWVIPADA MAIN ROAD, BORIVALI EAST, MUMBAI , Mumbai, Maharashtra, India, PIN: 400066',
          ),
        ],
      ),
    );
  }
}

class ContactInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const ContactInfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value),
    );
  }
}
