// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'sync_progress_bloc.dart';

class SyncProgressState {
  int total;
  int progress;

  SyncProgressState({
    required this.total,
    required this.progress,
  });
}

class SyncProgressInitial extends SyncProgressState {
  SyncProgressInitial({required super.total, required super.progress});
}
