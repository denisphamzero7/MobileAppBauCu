// File: voter_info.dart

/*
Model này đại diện cho thông tin trên Thẻ Cử Tri
đã được sửa lại từ model CitizenInfo ban đầu để khớp với các trường trong ảnh.
*/
class VoterInfo {
  final int? id; // ID cho cơ sở dữ liệu (nếu cần)

  // === CÁC TRƯỜNG CÓ DỮ LIỆU TRÊN THẺ ===

  /// Họ và tên (ví dụ: PHẠM NGỌC HẬU)
  final String fullName;

  /// Ngày, tháng, năm sinh (ví dụ: 08/10/2001)
  final String dob;

  /// Giới tính (ví dụ: NAM)
  final String sex;

  /// Nơi cư trú (ví dụ: 78 LÊ TRUNG ĐÌNH, NGŨ HÀNH SƠN, ĐÀ NẴNG)
  final String placeOfResidence;

  /// Số Căn cước (ví dụ: 066201011365)
  final String citizenIdNumber; // Đổi tên từ 'idNumber' cho rõ nghĩa

  // === CÁC TRƯỜNG THÔNG TIN BẦU CỬ (THƯỜNG ĐỂ TRỐNG ĐỂ ĐIỀN SAU) ===

  /// Ủy ban nhân dân cấp... (1)
  final String? issuingAuthority;

  /// SỐ THẺ CỬ TRI (4)
  final String? voterCardNumber;

  /// KHU VỰC BỎ PHIẾU SỐ:
  final String? pollingAreaNumber;

  /// Xã/phường/đặc khu:
  final String? ward;

  /// Tỉnh/thành phố:
  final String? city;

  // === TRƯỜNG LOGIC CỦA ỨNG DỤNG (KHÔNG CÓ TRÊN THẺ) ===

  /// Dùng để theo dõi trạng thái đã bỏ phiếu hay chưa
  bool hasVoted;


  VoterInfo({
    this.id,
    required this.fullName,
    required this.dob,
    required this.sex,
    required this.placeOfResidence,
    required this.citizenIdNumber,
    this.issuingAuthority,
    this.voterCardNumber,
    this.pollingAreaNumber,
    this.ward,
    this.city,
    this.hasVoted = false,
  });

  /// Hàm để chuyển đổi object thành Map (dùng cho database)
  Map<String, dynamic> toMap() {
    return {
      // Các trường trong ảnh
      'fullName': fullName,
      'dob': dob,
      'sex': sex,
      'placeOfResidence': placeOfResidence,
      'citizenIdNumber': citizenIdNumber,

      // Các trường thông tin bầu cử
      'issuingAuthority': issuingAuthority,
      'voterCardNumber': voterCardNumber,
      'pollingAreaNumber': pollingAreaNumber,
      'ward': ward,
      'city': city,

      // Trạng thái (logic của app)
      'hasVoted': hasVoted ? 1 : 0, // Chuyển bool sang 1 (true) hoặc 0 (false)
    };
  }

  /// Hàm để tạo object từ Map (lấy từ database)
  factory VoterInfo.fromMap(Map<String, dynamic> map) {
    return VoterInfo(
      id: map['id'], // 'id' có thể là null nếu map không chứa

      // Các trường trong ảnh
      fullName: map['fullName'] ?? '',
      dob: map['dob'] ?? '',
      sex: map['sex'] ?? '',
      placeOfResidence: map['placeOfResidence'] ?? '',
      citizenIdNumber: map['citizenIdNumber'] ?? '',

      // Các trường thông tin bầu cử (có thể null)
      issuingAuthority: map['issuingAuthority'],
      voterCardNumber: map['voterCardNumber'],
      pollingAreaNumber: map['pollingAreaNumber'],
      ward: map['ward'],
      city: map['city'],

      // Trạng thái (logic của app)
      hasVoted: map['hasVoted'] == 1, // Chuyển 1 về true, mọi thứ khác về false
    );
  }
}