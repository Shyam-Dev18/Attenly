import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/subject.dart';
import '../models/attendance_record.dart';

class ExportService {
  static Future<void> exportAttendanceToExcel(List<SubjectModel> subjects, List<AttendanceRecord> records) async {
    var excel = Excel.createExcel();
    
    // Overview Sheet
    Sheet overviewSheet = excel['Overview'];
    excel.setDefaultSheet('Overview');
    
    overviewSheet.appendRow([TextCellValue('Subject Name'), TextCellValue('Total Classes'), TextCellValue('Attended'), TextCellValue('Percentage (%)'), TextCellValue('Goal (%)'), TextCellValue('Status')]);
    
    final headerFormat = CellStyle(bold: true, backgroundColorHex: ExcelColor.fromHexString('#E0E0E0'));
    for (int i = 0; i < 6; i++) {
        overviewSheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).cellStyle = headerFormat;
    }

    for (var subject in subjects) {
      overviewSheet.appendRow([
        TextCellValue(subject.name),
        IntCellValue(subject.totalClasses),
        IntCellValue(subject.attendedClasses),
        DoubleCellValue(subject.percentage),
        IntCellValue(subject.attendanceGoal),
        TextCellValue(subject.isMeetingGoal ? 'Meeting Goal' : 'Needs Improvement'),
      ]);
    }

    // Records Sheet
    Sheet recordsSheet = excel['All Records'];
    recordsSheet.appendRow([TextCellValue('Date'), TextCellValue('Subject'), TextCellValue('Status')]);
    
    for (int i = 0; i < 3; i++) {
        recordsSheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).cellStyle = headerFormat;
    }

    final sortedRecords = [...records]..sort((a, b) => b.date.compareTo(a.date));
    
    final subjectMap = {for (var s in subjects) s.id: s.name};

    for (var record in sortedRecords) {
      final subjectName = subjectMap[record.subjectId] ?? 'Unknown';
      recordsSheet.appendRow([
        TextCellValue(DateFormat('yyyy-MM-dd').format(record.date)),
        TextCellValue(subjectName),
        TextCellValue(record.status.toUpperCase()),
      ]);
    }

    final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final fileName = 'Attenly_Export_$dateStr.xlsx';
    
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    
    final fileBytes = excel.save();
    if (fileBytes != null) {
      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
        
      await Share.shareXFiles([XFile(filePath)], text: 'My Attendance Export from Attenly');
    }
  }
}
