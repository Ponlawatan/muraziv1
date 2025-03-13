const Place = require('../models/Place');
const multer = require('multer');
const fs = require('fs');
const User = require('../models/User');
const jwt = require('jsonwebtoken');

// กำหนดการจัดเก็บไฟล์
const storage = multer.diskStorage({
  destination: function(req, file, cb) {
    const dir = './uploads';
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir);
    }
    cb(null, dir);
  },
  filename: function(req, file, cb) {
    cb(null, Date.now() + '-' + file.originalname);
  }
});

const upload = multer({ storage: storage });

// เพิ่มฟังก์ชันสำหรับดึง userId จาก token
const getUserIdFromToken = (token) => {
    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        return decoded.id;
    } catch (error) {
        return null;
    }
};

// ดึงข้อมูลทั้งหมดพร้อมแปลงรูปภาพ
exports.getAllPlaces = async (req, res) => {
  try {
    const places = await Place.find();
    const placesWithImages = places.map(place => ({
      ...place._doc,
      bannerImage: `data:${place.bannerImage.contentType};base64,${place.bannerImage.data.toString('base64')}`
    }));
    res.json(placesWithImages);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// ดึงข้อมูลตามหมวดหมู่พร้อมแปลงรูปภาพ
exports.getPlacesByCategory = async (req, res) => {
  try {
    const places = await Place.find({
      categories: req.params.category
    });
    const placesWithImages = places.map(place => ({
      ...place._doc,
      bannerImage: `data:${place.bannerImage.contentType};base64,${place.bannerImage.data.toString('base64')}`
    }));
    res.json(placesWithImages);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// ดึงข้อมูลตาม ID
exports.getPlaceById = async (req, res) => {
  try {
    const place = await Place.findById(req.params.id);
    if (place) {
      res.json(place);
    } else {
      res.status(404).json({ message: 'ไม่พบสถานที่' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// เพิ่มสถานที่ใหม่พร้อมรูปภาพ
exports.createPlace = async (req, res) => {
  try {
    const place = new Place({
      name: req.body.name,
      bannerImage: {
        data: fs.readFileSync(req.file.path),
        contentType: req.file.mimetype
      },
      categories: req.body.categories,
      address: {
        subdistrict: req.body.address.subdistrict,
        district: req.body.address.district,
        province: req.body.address.province
      },
      googleMapUrl: req.body.googleMapUrl,
      description: req.body.description
    });

    const newPlace = await place.save();
    
    // ลบไฟล์หลังจากบันทึกลง MongoDB แล้ว
    fs.unlinkSync(req.file.path);
    
    res.status(201).json(newPlace);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// แก้ไขข้อมูลสถานที่
exports.updatePlace = async (req, res) => {
  try {
    const updatedPlace = await Place.findByIdAndUpdate(
      req.params.id,
      {
        name: req.body.name,
        bannerImage: req.body.bannerImage,
        categories: req.body.categories,
        address: {
          subdistrict: req.body.address.subdistrict,
          district: req.body.address.district,
          province: req.body.address.province
        },
        googleMapUrl: req.body.googleMapUrl,
        description: req.body.description
      },
      { new: true }
    );

    if (!updatedPlace) {
      return res.status(404).json({ message: 'ไม่พบสถานที่ที่ต้องการแก้ไข' });
    }

    res.json(updatedPlace);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// เพิ่มสถานที่เข้าลิสต์ถูกใจ
exports.addToFavorites = async (req, res) => {
    try {
        const token = req.headers.authorization?.split(' ')[1];
        const placeId = req.params.placeId;

        if (!token) {
            return res.status(401).json({ message: 'ไม่พบ Token กรุณาเข้าสู่ระบบ' });
        }

        const userId = getUserIdFromToken(token);
        if (!userId) {
            return res.status(401).json({ message: 'Token ไม่ถูกต้อง' });
        }

        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({ message: 'ไม่พบผู้ใช้' });
        }

        const favoriteIndex = user.favoritePlaces.indexOf(placeId);
        let isFavorited = false;

        if (favoriteIndex === -1) {
            user.favoritePlaces.push(placeId);
            isFavorited = true;
        } else {
            user.favoritePlaces.splice(favoriteIndex, 1);
        }

        await user.save();
        res.json({ 
            message: isFavorited ? 'เพิ่มในรายการโปรดแล้ว' : 'นำออกจากรายการโปรดแล้ว',
            isFavorited 
        });
    } catch (error) {
        res.status(500).json({ message: 'เกิดข้อผิดพลาด', error: error.message });
    }
};

// ลบสถานที่ออกจากลิสต์ถูกใจ
exports.removeFromFavorites = async (req, res) => {
    try {
        const { userId } = req.body; // รับ userId จาก request body
        const placeId = req.params.placeId;

        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({ message: 'ไม่พบผู้ใช้' });
        }

        // ลบสถานที่ออกจากลิสต์ถูกใจ
        user.favoritePlaces = user.favoritePlaces.filter(
            id => id.toString() !== placeId
        );
        await user.save();

        res.json({ message: 'ลบสถานที่ออกจากรายการโปรดเรียบร้อยแล้ว' });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// ดึงรายการสถานที่ที่ถูกใจของ user
exports.getFavoritePlaces = async (req, res) => {
    try {
        const token = req.headers.authorization?.split(' ')[1];
        
        if (!token) {
            return res.status(401).json({ message: 'ไม่พบ Token กรุณาเข้าสู่ระบบ' });
        }

        const userId = getUserIdFromToken(token);
        if (!userId) {
            return res.status(401).json({ message: 'Token ไม่ถูกต้อง' });
        }

        const user = await User.findById(userId).populate('favoritePlaces');
        if (!user) {
            return res.status(404).json({ message: 'ไม่พบผู้ใช้' });
        }

        const favoritePlaces = user.favoritePlaces.map(place => ({
            _id: place._id,
            name: place.name,
            bannerImage: `data:${place.bannerImage.contentType};base64,${place.bannerImage.data.toString('base64')}`,
            categories: place.categories,
            address: place.address,
            googleMapUrl: place.googleMapUrl,
            description: place.description
        }));

        res.json(favoritePlaces);
    } catch (error) {
        res.status(500).json({ message: 'เกิดข้อผิดพลาด', error: error.message });
    }
};

// เช็คสถานะการถูกใจ
exports.checkFavoriteStatus = async (req, res) => {
    try {
        const token = req.headers.authorization?.split(' ')[1];
        const placeId = req.params.placeId;

        if (!token) {
            return res.status(401).json({ message: 'ไม่พบ Token กรุณาเข้าสู่ระบบ' });
        }

        const userId = getUserIdFromToken(token);
        if (!userId) {
            return res.status(401).json({ message: 'Token ไม่ถูกต้อง' });
        }

        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({ message: 'ไม่พบผู้ใช้' });
        }

        const isFavorited = user.favoritePlaces.includes(placeId);
        res.json({ isFavorited });
    } catch (error) {
        res.status(500).json({ message: 'เกิดข้อผิดพลาด', error: error.message });
    }
};

// เพิ่มฟังก์ชันดึงข้อมูลตามจังหวัด
exports.getPlacesByProvince = async (req, res) => {
  try {
    const province = req.params.province;
    const places = await Place.find({
      'address.province': province
    });
    
    const placesWithImages = places.map(place => ({
      ...place._doc,
      bannerImage: `data:${place.bannerImage.contentType};base64,${place.bannerImage.data.toString('base64')}`
    }));
    
    res.json(placesWithImages);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// เพิ่มฟังก์ชันดึงรายการจังหวัดทั้งหมด
exports.getAllProvinces = async (req, res) => {
  try {
    // ใช้ aggregation เพื่อดึงข้อมูลจังหวัดที่ไม่ซ้ำกัน
    const provinces = await Place.aggregate([
      { $group: { _id: "$address.province" } },
      { $match: { _id: { $ne: null } } },
      { $sort: { _id: 1 } }
    ]);
    
    // แปลงรูปแบบข้อมูล
    const provinceList = provinces.map(item => item._id);
    
    res.json(provinceList);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
