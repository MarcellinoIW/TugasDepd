part of 'pages.dart';

class Detailpage extends StatefulWidget {
  const Detailpage({super.key});

  @override
  State<Detailpage> createState() => _DetailpageState();
}

class _DetailpageState extends State<Detailpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Placeholder gambar dari internet
            Image.network(
              'https://cdn.pixabay.com/photo/2025/11/28/15/29/zebras-9983175_1280.jpg',
              width: 500,
              height: 500,
              // Icon fallback jika tidak ada internet
              errorBuilder: (ctx, _, __) => const Icon(Icons.image, size: 100),
            ),
            const SizedBox(height: 24),
            const Text(
              "Hello World",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}