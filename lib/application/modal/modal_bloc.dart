import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

part 'modal_event.dart';
part 'modal_state.dart';

class ModalBloc extends Bloc<ModalEvent, ModalState> {
  late WebViewController webViewController;
  final FocusNode focusNode = FocusNode();
  bool isKeyboardOpen = false;
  double topPadding = 0;

  ModalBloc() : super(ModalInitialState()) {
    on<UpdateHeight>((event, emit) {
      ModalInitialState curState = state as ModalInitialState;
      emit(curState.copyWith(factor: event.height));
    });
  }

  void onDragHandler(DragUpdateDetails details, double adjustedHeight) {
    if (state is! ModalInitialState) {
      return;
    }
    ModalInitialState curState = state as ModalInitialState;

    double newHeight =
        curState.scaleFactor - details.primaryDelta! / adjustedHeight;
    if (newHeight > 0.2 && newHeight < 1.0 && !isKeyboardOpen) {
      add(UpdateHeight(newHeight));
    }
  }
}
