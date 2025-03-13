const mongoose = require('mongoose');

const placeSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true
  },
  bannerImage: {
    data: Buffer,        // เก็บข้อมูลไฟล์
    contentType: String  // เก็บประเภทของไฟล์
  },
  categories: [{
    type: String,
    enum: [
      'ความรัก', 
      'การงาน', 
      'โชคลาภ', 
      'การค้าขาย', 
      'สุขภาพ', 
      'ขอบุตร', 
      'ขอหวย',
      'การเงิน',     // เพิ่มหมวดหมู่ใหม่
      'การเรียน',
      'เสริมดวง',
      'เสริมบารมี',
      'แก้กรรม',
      'อื่นๆ'
    ]
  }],
  address: {
    subdistrict: {  // ตำบล
      type: String,
      required: true
    },
    district: {      // อำเภอ
      type: String,
      required: true
    },
    province: {      // จังหวัด
      type: String,
      required: true
    }
  },
  googleMapUrl: {
    type: String,
    required: true
  },
  description: {
    type: String,
    required: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Place', placeSchema);