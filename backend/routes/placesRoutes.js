const express = require('express');
const router = express.Router();
const multer = require('multer');
const {
  getAllPlaces,
  getPlacesByCategory,
  getPlaceById,
  createPlace,
  updatePlace,
  addToFavorites,
  removeFromFavorites,
  getFavoritePlaces,
  checkFavoriteStatus,
  getPlacesByProvince,
  getAllProvinces
} = require('../controllers/placeController');

// กำหนดการจัดเก็บไฟล์
const storage = multer.diskStorage({
  destination: './uploads/',
  filename: function(req, file, cb) {
    cb(null, Date.now() + '-' + file.originalname);
  }
});

const upload = multer({ storage: storage });

// Routes
router.get('/places', getAllPlaces);
router.get('/places/category/:category', getPlacesByCategory);
router.get('/places/:id', getPlaceById);
router.post('/addplaces', upload.single('bannerImage'), createPlace);
router.put('/places/:id', upload.single('bannerImage'), updatePlace);

// Routes สำหรับการจัดการสถานที่ที่ถูกใจ (ไม่ใช้ middleware)
router.post('/places/:placeId/favorite', addToFavorites);
router.get('/favorite-places', getFavoritePlaces);
router.get('/favorite-status/:placeId', checkFavoriteStatus);

// เพิ่มเส้นทางใหม่
router.get('/provinces', getAllProvinces);
router.get('/places/province/:province', getPlacesByProvince);

module.exports = router; 