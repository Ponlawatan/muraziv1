import 'package:flutter/material.dart';
import 'package:murazi_dev/models/place.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:murazi_dev/services/favorite_service.dart';
import 'package:murazi_dev/favorite.dart';

class PlaceDetailPage extends StatefulWidget {
  final Place place;

  const PlaceDetailPage({super.key, required this.place});

  @override
  _PlaceDetailPageState createState() => _PlaceDetailPageState();
}

class _PlaceDetailPageState extends State<PlaceDetailPage> {
  bool isFavorited = false;

  @override
  void initState() {
    super.initState();
    checkFavoriteStatus();
  }

  Future<void> checkFavoriteStatus() async {
    final status = await FavoriteService.checkFavoriteStatus(widget.place.id);
    setState(() {
      isFavorited = status;
    });
  }

  Future<void> toggleFavorite() async {
    final token = await FavoriteService.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณาเข้าสู่ระบบก่อน')),
      );
      return;
    }

    final newStatus = await FavoriteService.toggleFavorite(widget.place.id);
    setState(() {
      isFavorited = newStatus;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            isFavorited ? 'เพิ่มในรายการโปรดแล้ว' : 'นำออกจากรายการโปรดแล้ว'),
      ),
    );

    if (context.mounted) {
      final favoritePage = context.findAncestorStateOfType<FavoritePageState>();
      favoritePage?.fetchFavoritePlaces();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImage(constraints.maxWidth),
                _buildDetails(constraints.maxWidth),
              ],
            ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: Colors.white,
          size: 26,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 0, 0),
      centerTitle: true,
      title: const Text(
        'MURAZI',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildImage(double screenWidth) {
    double imageHeight = screenWidth > 600 ? 350 : 250;

    return Container(
      width: double.infinity,
      height: imageHeight,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        child: Stack(
          children: [
            Image.network(
              widget.place.bannerImage,
              width: double.infinity,
              height: imageHeight,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: Colors.grey[400],
                    ),
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    color: const Color.fromARGB(255, 255, 0, 0),
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetails(double screenWidth) {
    double horizontalPadding = screenWidth > 600 ? 24.0 : 16.0;

    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(),
          Divider(height: 30, color: Colors.grey[300], thickness: 1),
          _buildCategory(),
          SizedBox(height: 20),
          _buildLocationDescription(),
          SizedBox(height: 16),
          _buildDescriptionSection(),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: Text(
            widget.place.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 255, 0, 0),
            ),
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () async {
                final Uri url = Uri.parse(widget.place.googleMapUrl);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
              icon: Icon(
                Icons.map,
                size: 24,
                color: const Color.fromARGB(255, 255, 0, 0),
              ),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
            SizedBox(width: 8),
            IconButton(
              icon: Icon(
                isFavorited ? Icons.favorite : Icons.favorite_border,
                color: const Color.fromARGB(255, 255, 0, 0),
              ),
              onPressed: toggleFavorite,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategory() {
    return SizedBox(
      width: double.infinity,
      child: Text(
        'หมวดหมู่: ${widget.place.categories.join(", ")}',
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey[600],
          fontWeight: FontWeight.bold,
        ),
        softWrap: true,
        overflow: TextOverflow.visible,
      ),
    );
  }

  Widget _buildLocationDescription() {
    final subdist = widget.place.address['subdistrict'] ?? '';
    final dist = widget.place.address['district'] ?? '';
    final province = widget.place.address['province'] ?? '';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_on, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'ตำแหน่งที่ตั้ง',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildAddressRow('ตำบล/แขวง:', subdist),
          _buildAddressRow('อำเภอ/เขต:', dist),
          _buildAddressRow('จังหวัด:', province),
        ],
      ),
    );
  }

  Widget _buildAddressRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'รายละเอียด',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        SizedBox(height: 10),
        _buildDescription(),
      ],
    );
  }

  Widget _buildDescription() {
    return SizedBox(
      width: double.infinity,
      child: Text(
        widget.place.description,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        softWrap: true,
        overflow: TextOverflow.visible,
      ),
    );
  }
}
