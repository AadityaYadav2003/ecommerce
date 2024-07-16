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
              'https://img.freepik.com/premium-photo/ai-image-generator-dark-owl-vector-t-shirt-design_977285-10599.jpg?w=740',
              height: 150,
              width: 150,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(
              height:
                  20), // Add some space between the image and the contact info

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
