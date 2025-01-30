part of 'modal_bloc.dart';

@immutable
sealed class ModalEvent {}

class UpdateHeight extends ModalEvent {
  final double height;

  UpdateHeight(this.height);
}
