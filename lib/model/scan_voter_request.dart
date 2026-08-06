// lib/model/scan_voter_request.dart

class ScanVoterRequest {
  final String cccd;


  ScanVoterRequest({
    required this.cccd,

  });

  Map<String, dynamic> toJson() {
    return {
      'cccd': cccd,

    };
  }
}