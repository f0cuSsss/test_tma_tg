part of 'modal_bloc.dart';

@immutable
abstract class ModalState {}

class ModalInitialState extends ModalState {
  final double scaleFactor;

  ModalInitialState({this.scaleFactor = 0.5});

  ModalInitialState copyWith({double? factor}) {
    return ModalInitialState(scaleFactor: factor ?? scaleFactor);
  }
}
