// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_application_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JobApplicationModelAdapter extends TypeAdapter<JobApplicationModel> {
  @override
  final int typeId = 30;

  @override
  JobApplicationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JobApplicationModel(
      id: fields[0] as String,
      jobId: fields[1] as String,
      applicantId: fields[2] as String,
      applicantName: fields[3] as String,
      applicantEmail: fields[4] as String,
      status: fields[5] as ApplicationStatus,
      appliedDate: fields[6] as DateTime,
      lastUpdated: fields[7] as DateTime?,
      coverLetter: fields[8] as String?,
      documentIds: (fields[9] as List).cast<String>(),
      applicationData: (fields[10] as Map?)?.cast<String, dynamic>(),
      notes: fields[11] as String?,
      reviewedBy: fields[12] as String?,
      reviewedDate: fields[13] as DateTime?,
      score: fields[14] as ApplicationScore?,
      interviews: (fields[15] as List).cast<InterviewModel>(),
      rejectionReason: fields[16] as String?,
      rejectionDate: fields[17] as DateTime?,
      isArchived: fields[18] as bool,
      source: fields[19] as String?,
      referralSource: fields[20] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, JobApplicationModel obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.jobId)
      ..writeByte(2)
      ..write(obj.applicantId)
      ..writeByte(3)
      ..write(obj.applicantName)
      ..writeByte(4)
      ..write(obj.applicantEmail)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.appliedDate)
      ..writeByte(7)
      ..write(obj.lastUpdated)
      ..writeByte(8)
      ..write(obj.coverLetter)
      ..writeByte(9)
      ..write(obj.documentIds)
      ..writeByte(10)
      ..write(obj.applicationData)
      ..writeByte(11)
      ..write(obj.notes)
      ..writeByte(12)
      ..write(obj.reviewedBy)
      ..writeByte(13)
      ..write(obj.reviewedDate)
      ..writeByte(14)
      ..write(obj.score)
      ..writeByte(15)
      ..write(obj.interviews)
      ..writeByte(16)
      ..write(obj.rejectionReason)
      ..writeByte(17)
      ..write(obj.rejectionDate)
      ..writeByte(18)
      ..write(obj.isArchived)
      ..writeByte(19)
      ..write(obj.source)
      ..writeByte(20)
      ..write(obj.referralSource);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JobApplicationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ApplicationScoreAdapter extends TypeAdapter<ApplicationScore> {
  @override
  final int typeId = 32;

  @override
  ApplicationScore read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ApplicationScore(
      overallScore: fields[0] as int,
      experienceScore: fields[1] as int,
      skillsScore: fields[2] as int,
      educationScore: fields[3] as int,
      interviewScore: fields[4] as int,
      comments: fields[5] as String?,
      scoredBy: fields[6] as String,
      scoredDate: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ApplicationScore obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.overallScore)
      ..writeByte(1)
      ..write(obj.experienceScore)
      ..writeByte(2)
      ..write(obj.skillsScore)
      ..writeByte(3)
      ..write(obj.educationScore)
      ..writeByte(4)
      ..write(obj.interviewScore)
      ..writeByte(5)
      ..write(obj.comments)
      ..writeByte(6)
      ..write(obj.scoredBy)
      ..writeByte(7)
      ..write(obj.scoredDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApplicationScoreAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InterviewModelAdapter extends TypeAdapter<InterviewModel> {
  @override
  final int typeId = 33;

  @override
  InterviewModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InterviewModel(
      id: fields[0] as String,
      applicationId: fields[1] as String,
      applicantId: fields[2] as String,
      applicantName: fields[3] as String,
      type: fields[4] as InterviewType,
      status: fields[5] as InterviewStatus,
      scheduledDate: fields[6] as DateTime,
      duration: fields[7] as int,
      location: fields[8] as String,
      interviewerIds: (fields[9] as List).cast<String>(),
      interviewerNames: (fields[10] as List).cast<String>(),
      meetingLink: fields[11] as String?,
      notes: fields[12] as String?,
      feedback: fields[13] as String?,
      rating: fields[14] as int?,
      completedDate: fields[15] as DateTime?,
      rescheduledDate: fields[16] as DateTime?,
      rescheduleReason: fields[17] as String?,
      isRemote: fields[18] as bool,
      interviewQuestions: (fields[19] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, InterviewModel obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.applicationId)
      ..writeByte(2)
      ..write(obj.applicantId)
      ..writeByte(3)
      ..write(obj.applicantName)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.scheduledDate)
      ..writeByte(7)
      ..write(obj.duration)
      ..writeByte(8)
      ..write(obj.location)
      ..writeByte(9)
      ..write(obj.interviewerIds)
      ..writeByte(10)
      ..write(obj.interviewerNames)
      ..writeByte(11)
      ..write(obj.meetingLink)
      ..writeByte(12)
      ..write(obj.notes)
      ..writeByte(13)
      ..write(obj.feedback)
      ..writeByte(14)
      ..write(obj.rating)
      ..writeByte(15)
      ..write(obj.completedDate)
      ..writeByte(16)
      ..write(obj.rescheduledDate)
      ..writeByte(17)
      ..write(obj.rescheduleReason)
      ..writeByte(18)
      ..write(obj.isRemote)
      ..writeByte(19)
      ..write(obj.interviewQuestions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InterviewModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ApplicationStatusAdapter extends TypeAdapter<ApplicationStatus> {
  @override
  final int typeId = 31;

  @override
  ApplicationStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ApplicationStatus.submitted;
      case 1:
        return ApplicationStatus.underReview;
      case 2:
        return ApplicationStatus.shortlisted;
      case 3:
        return ApplicationStatus.interviewScheduled;
      case 4:
        return ApplicationStatus.interviewCompleted;
      case 5:
        return ApplicationStatus.rejected;
      case 6:
        return ApplicationStatus.hired;
      case 7:
        return ApplicationStatus.withdrawn;
      default:
        return ApplicationStatus.submitted;
    }
  }

  @override
  void write(BinaryWriter writer, ApplicationStatus obj) {
    switch (obj) {
      case ApplicationStatus.submitted:
        writer.writeByte(0);
        break;
      case ApplicationStatus.underReview:
        writer.writeByte(1);
        break;
      case ApplicationStatus.shortlisted:
        writer.writeByte(2);
        break;
      case ApplicationStatus.interviewScheduled:
        writer.writeByte(3);
        break;
      case ApplicationStatus.interviewCompleted:
        writer.writeByte(4);
        break;
      case ApplicationStatus.rejected:
        writer.writeByte(5);
        break;
      case ApplicationStatus.hired:
        writer.writeByte(6);
        break;
      case ApplicationStatus.withdrawn:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApplicationStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InterviewTypeAdapter extends TypeAdapter<InterviewType> {
  @override
  final int typeId = 34;

  @override
  InterviewType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return InterviewType.phone;
      case 1:
        return InterviewType.video;
      case 2:
        return InterviewType.inPerson;
      case 3:
        return InterviewType.technical;
      case 4:
        return InterviewType.panel;
      default:
        return InterviewType.phone;
    }
  }

  @override
  void write(BinaryWriter writer, InterviewType obj) {
    switch (obj) {
      case InterviewType.phone:
        writer.writeByte(0);
        break;
      case InterviewType.video:
        writer.writeByte(1);
        break;
      case InterviewType.inPerson:
        writer.writeByte(2);
        break;
      case InterviewType.technical:
        writer.writeByte(3);
        break;
      case InterviewType.panel:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InterviewTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InterviewStatusAdapter extends TypeAdapter<InterviewStatus> {
  @override
  final int typeId = 35;

  @override
  InterviewStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return InterviewStatus.scheduled;
      case 1:
        return InterviewStatus.completed;
      case 2:
        return InterviewStatus.cancelled;
      case 3:
        return InterviewStatus.rescheduled;
      case 4:
        return InterviewStatus.noShow;
      default:
        return InterviewStatus.scheduled;
    }
  }

  @override
  void write(BinaryWriter writer, InterviewStatus obj) {
    switch (obj) {
      case InterviewStatus.scheduled:
        writer.writeByte(0);
        break;
      case InterviewStatus.completed:
        writer.writeByte(1);
        break;
      case InterviewStatus.cancelled:
        writer.writeByte(2);
        break;
      case InterviewStatus.rescheduled:
        writer.writeByte(3);
        break;
      case InterviewStatus.noShow:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InterviewStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
