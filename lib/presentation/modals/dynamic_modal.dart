import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tma_tg_bottom_webview/application/modal/modal_bloc.dart';
import 'package:tma_tg_bottom_webview/presentation/core/app_colors.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DynamicModal extends StatelessWidget {
  const DynamicModal({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ModalBloc(), // need DI!
      child: DynamicModalView(url: url),
    );
  }
}

class DynamicModalView extends StatefulWidget {
  final String url;

  const DynamicModalView({super.key, required this.url});

  @override
  State<DynamicModalView> createState() => _DynamicModalViewState();
}

class _DynamicModalViewState extends State<DynamicModalView>
    with WidgetsBindingObserver {
  late ModalBloc bloc;

  @override
  void initState() {
    bloc = BlocProvider.of<ModalBloc>(context);
    WidgetsBinding.instance.addObserver(this);
    bloc.webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = View.of(context).viewInsets.bottom;
    final isKeyboardOpen = bottomInset > 0;
    if (isKeyboardOpen != bloc.isKeyboardOpen) {
      setState(() {
        bloc.isKeyboardOpen = isKeyboardOpen;
        if (bloc.isKeyboardOpen) {
          context.read<ModalBloc>().add(UpdateHeight(1.0));
        } else {
          context.read<ModalBloc>().add(UpdateHeight(0.5));
        }
      });
    }
  }

  void onRollDownPressed(BuildContext context) {
    context.read<ModalBloc>().add(UpdateHeight(0.2));
  }

  void onClosePressed(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    bloc.topPadding = MediaQueryData.fromView(View.of(context)).padding.top;
    final double adjustedHeight = screenHeight - bloc.topPadding;

    return Container(
      padding: EdgeInsets.only(
        top: bloc.topPadding,
      ),
      child: GestureDetector(
        onTap: () => bloc.focusNode.unfocus(),
        onVerticalDragUpdate: (d) => bloc.onDragHandler(d, adjustedHeight),
        child: BlocBuilder<ModalBloc, ModalState>(
          builder: (context, state) {
            ModalInitialState curState =
                state as ModalInitialState; // NOT GOOD!

            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              height: curState.scaleFactor * adjustedHeight,
              child: Container(
                decoration: _buildBoxDecoration(),
                child: Column(
                  children: [
                    _buildTopBottomSheetWidget(curState, context),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: Platform.isIOS
                              ? MediaQuery.of(context).padding.bottom
                              : 0,
                        ),
                        child:
                            WebViewWidget(controller: bloc.webViewController),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Container _buildTopBottomSheetWidget(
      ModalInitialState curState, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: curState.scaleFactor >= 0.5
                ? () => onRollDownPressed(context)
                : () => onClosePressed(context),
            child: Text(
              curState.scaleFactor >= 0.5
                  ? 'Згорнути' // should use localization, raw string not good
                  : 'Закрити',
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _buildBoxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      boxShadow: Platform.isIOS
          ? [
              const BoxShadow(
                color: AppColors.primary,
                blurRadius: 10,
              ),
            ]
          : [
              const BoxShadow(
                color: AppColors.primary,
                blurRadius: 5,
              ),
            ],
    );
  }
}
