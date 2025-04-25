import 'dart:convert';

import 'api_service.dart';
import '../models/report.dart'; // Adjust the path based on the actual location of the Report class

class ReportService {
  static Future<List<Report>> fetchReports({
    int page = 1,
    int limit = 10,
    String? startDate,
    String? endDate,
  }) async {
    try {
      Map<String, String> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;

      final response = await ApiService.get('/reports', queryParams: queryParams);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List reportsJson = data['reports'];
        return reportsJson.map((json) => Report.fromJson(json)).toList();
      } else {
        throw Exception('Error fetching reports');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Report> createReport({
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await ApiService.post('/reports', {
        'startDate': startDate,
        'endDate': endDate,
      });

      if (response.statusCode == 201) {
        return Report.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error creating report');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Report> getReportById(String id) async {
    try {
      final response = await ApiService.get('/reports/$id');

      if (response.statusCode == 200) {
        return Report.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Report not found');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Report> updateReport(String id, Map<String, dynamic> updates) async {
    try {
      final response = await ApiService.put('/reports/$id', updates);

      if (response.statusCode == 200) {
        return Report.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error updating report');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteReport(String id) async {
    try {
      final response = await ApiService.delete('/reports/$id');

      if (response.statusCode != 200) {
        throw Exception('Error deleting report');
      }
    } catch (e) {
      rethrow;
    }
  }
}
