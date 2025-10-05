// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReportModelAdapter extends TypeAdapter<ReportModel> {
  @override
  final int typeId = 17;

  @override
  ReportModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReportModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      type: fields[3] as ReportType,
      category: fields[4] as ReportCategory,
      generatedAt: fields[5] as DateTime,
      generatedBy: fields[6] as String,
      parameters: (fields[7] as Map).cast<String, dynamic>(),
      data: (fields[8] as Map).cast<String, dynamic>(),
      status: fields[9] as ReportStatus,
      filePath: fields[10] as String?,
      downloadUrl: fields[11] as String?,
      recordCount: fields[12] as int,
      scheduledFor: fields[13] as DateTime?,
      scheduleFrequency: fields[14] as String?,
      isScheduled: fields[15] as bool,
      recipients: (fields[16] as List).cast<String>(),
      metadata: (fields[17] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, ReportModel obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.generatedAt)
      ..writeByte(6)
      ..write(obj.generatedBy)
      ..writeByte(7)
      ..write(obj.parameters)
      ..writeByte(8)
      ..write(obj.data)
      ..writeByte(9)
      ..write(obj.status)
      ..writeByte(10)
      ..write(obj.filePath)
      ..writeByte(11)
      ..write(obj.downloadUrl)
      ..writeByte(12)
      ..write(obj.recordCount)
      ..writeByte(13)
      ..write(obj.scheduledFor)
      ..writeByte(14)
      ..write(obj.scheduleFrequency)
      ..writeByte(15)
      ..write(obj.isScheduled)
      ..writeByte(16)
      ..write(obj.recipients)
      ..writeByte(17)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AnalyticsDataModelAdapter extends TypeAdapter<AnalyticsDataModel> {
  @override
  final int typeId = 21;

  @override
  AnalyticsDataModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AnalyticsDataModel(
      id: fields[0] as String,
      metricName: fields[1] as String,
      metricType: fields[2] as AnalyticsMetricType,
      data: (fields[3] as Map).cast<String, dynamic>(),
      timestamp: fields[4] as DateTime,
      category: fields[5] as String?,
      filters: (fields[6] as Map?)?.cast<String, dynamic>(),
      description: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AnalyticsDataModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.metricName)
      ..writeByte(2)
      ..write(obj.metricType)
      ..writeByte(3)
      ..write(obj.data)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.filters)
      ..writeByte(7)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalyticsDataModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChartDataModelAdapter extends TypeAdapter<ChartDataModel> {
  @override
  final int typeId = 23;

  @override
  ChartDataModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChartDataModel(
      id: fields[0] as String,
      title: fields[1] as String,
      type: fields[2] as ChartType,
      dataPoints: (fields[3] as List).cast<ChartDataPoint>(),
      options: (fields[4] as Map?)?.cast<String, dynamic>(),
      createdAt: fields[5] as DateTime,
      category: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ChartDataModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.dataPoints)
      ..writeByte(4)
      ..write(obj.options)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChartDataModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChartDataPointAdapter extends TypeAdapter<ChartDataPoint> {
  @override
  final int typeId = 24;

  @override
  ChartDataPoint read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChartDataPoint(
      label: fields[0] as String,
      value: fields[1] as double,
      color: fields[2] as String?,
      metadata: (fields[3] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, ChartDataPoint obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.label)
      ..writeByte(1)
      ..write(obj.value)
      ..writeByte(2)
      ..write(obj.color)
      ..writeByte(3)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChartDataPointAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReportTypeAdapter extends TypeAdapter<ReportType> {
  @override
  final int typeId = 18;

  @override
  ReportType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ReportType.summary;
      case 1:
        return ReportType.detailed;
      case 2:
        return ReportType.chart;
      case 3:
        return ReportType.export;
      case 4:
        return ReportType.dashboard;
      default:
        return ReportType.summary;
    }
  }

  @override
  void write(BinaryWriter writer, ReportType obj) {
    switch (obj) {
      case ReportType.summary:
        writer.writeByte(0);
        break;
      case ReportType.detailed:
        writer.writeByte(1);
        break;
      case ReportType.chart:
        writer.writeByte(2);
        break;
      case ReportType.export:
        writer.writeByte(3);
        break;
      case ReportType.dashboard:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReportCategoryAdapter extends TypeAdapter<ReportCategory> {
  @override
  final int typeId = 19;

  @override
  ReportCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ReportCategory.applications;
      case 1:
        return ReportCategory.interviews;
      case 2:
        return ReportCategory.users;
      case 3:
        return ReportCategory.jobs;
      case 4:
        return ReportCategory.documents;
      case 5:
        return ReportCategory.performance;
      case 6:
        return ReportCategory.compliance;
      case 7:
        return ReportCategory.system;
      default:
        return ReportCategory.applications;
    }
  }

  @override
  void write(BinaryWriter writer, ReportCategory obj) {
    switch (obj) {
      case ReportCategory.applications:
        writer.writeByte(0);
        break;
      case ReportCategory.interviews:
        writer.writeByte(1);
        break;
      case ReportCategory.users:
        writer.writeByte(2);
        break;
      case ReportCategory.jobs:
        writer.writeByte(3);
        break;
      case ReportCategory.documents:
        writer.writeByte(4);
        break;
      case ReportCategory.performance:
        writer.writeByte(5);
        break;
      case ReportCategory.compliance:
        writer.writeByte(6);
        break;
      case ReportCategory.system:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReportStatusAdapter extends TypeAdapter<ReportStatus> {
  @override
  final int typeId = 20;

  @override
  ReportStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ReportStatus.pending;
      case 1:
        return ReportStatus.processing;
      case 2:
        return ReportStatus.completed;
      case 3:
        return ReportStatus.failed;
      default:
        return ReportStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, ReportStatus obj) {
    switch (obj) {
      case ReportStatus.pending:
        writer.writeByte(0);
        break;
      case ReportStatus.processing:
        writer.writeByte(1);
        break;
      case ReportStatus.completed:
        writer.writeByte(2);
        break;
      case ReportStatus.failed:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AnalyticsMetricTypeAdapter extends TypeAdapter<AnalyticsMetricType> {
  @override
  final int typeId = 22;

  @override
  AnalyticsMetricType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AnalyticsMetricType.count;
      case 1:
        return AnalyticsMetricType.percentage;
      case 2:
        return AnalyticsMetricType.trend;
      case 3:
        return AnalyticsMetricType.distribution;
      case 4:
        return AnalyticsMetricType.comparison;
      case 5:
        return AnalyticsMetricType.timeSeries;
      default:
        return AnalyticsMetricType.count;
    }
  }

  @override
  void write(BinaryWriter writer, AnalyticsMetricType obj) {
    switch (obj) {
      case AnalyticsMetricType.count:
        writer.writeByte(0);
        break;
      case AnalyticsMetricType.percentage:
        writer.writeByte(1);
        break;
      case AnalyticsMetricType.trend:
        writer.writeByte(2);
        break;
      case AnalyticsMetricType.distribution:
        writer.writeByte(3);
        break;
      case AnalyticsMetricType.comparison:
        writer.writeByte(4);
        break;
      case AnalyticsMetricType.timeSeries:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalyticsMetricTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChartTypeAdapter extends TypeAdapter<ChartType> {
  @override
  final int typeId = 25;

  @override
  ChartType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ChartType.bar;
      case 1:
        return ChartType.line;
      case 2:
        return ChartType.pie;
      case 3:
        return ChartType.doughnut;
      case 4:
        return ChartType.area;
      case 5:
        return ChartType.scatter;
      default:
        return ChartType.bar;
    }
  }

  @override
  void write(BinaryWriter writer, ChartType obj) {
    switch (obj) {
      case ChartType.bar:
        writer.writeByte(0);
        break;
      case ChartType.line:
        writer.writeByte(1);
        break;
      case ChartType.pie:
        writer.writeByte(2);
        break;
      case ChartType.doughnut:
        writer.writeByte(3);
        break;
      case ChartType.area:
        writer.writeByte(4);
        break;
      case ChartType.scatter:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChartTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
