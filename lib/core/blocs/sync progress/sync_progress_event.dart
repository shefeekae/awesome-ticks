// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'sync_progress_bloc.dart';

class SyncProgressEvent {}

class ChangeSyncProgressEvent extends SyncProgressEvent {
  int progress;
  ChangeSyncProgressEvent(
  { required this.progress,}
  );
}

class ChangeTotalCountEvent extends SyncProgressEvent {
  int total;

  ChangeTotalCountEvent({
    required this.total,
  });
}
