import 'package:chromatec_service/common/widgets/failure_widget.dart';
import 'package:chromatec_service/features/requests/presentation/dialog/state/dialog_provider.dart';
import 'package:chromatec_service/features/requests/presentation/dialog/widgets/dialog_bottom_button_widget.dart';
import 'package:chromatec_service/features/requests/presentation/dialog/widgets/dialog_message_field_widget.dart';
import 'package:chromatec_service/features/requests/presentation/dialog/widgets/dialog_message_widget.dart';
import 'package:chromatec_service/features/requests/domain/entities/message.dart';
import 'package:chromatec_service/features/requests/presentation/dialog_members/pages/dialog_members_page.dart';
import 'package:chromatec_service/services/messaging_service.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class DialogWidget extends StatefulWidget {
  final DialogProvider provider;
  final String requestId;
  final String requestTitle;

  DialogWidget(
      {@required this.provider,
      @required this.requestId,
      @required this.requestTitle});

  @override
  State<StatefulWidget> createState() => DialogWidgetState();
}

class DialogWidgetState extends State<DialogWidget> {
  GlobalKey<FormState> _formKey;
  AutoScrollController _messagesScrollController;
  double _deviceHeight;
  double _deviceWidth;

  DialogWidgetState() {
    _formKey = GlobalKey<FormState>();
    _messagesScrollController = AutoScrollController();
    _addScrollBottomListener();
    _addScrollTopListener();
  }

  @override
  void initState() {
    super.initState();
    var provider = this.widget.provider;
    provider.getUserMessages(this.widget.requestId);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scrollMessagesListToPrevious();
    });
  }

  @override
  Widget build(BuildContext context) {
    var provider = this.widget.provider;
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
        onWillPop: () async {
          MessagingService.currentRequestId = "";
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(this.widget.requestTitle),
            actions: [
              PopupMenuButton(itemBuilder: (BuildContext _context) {
                return [
                  PopupMenuItem(
                      child: Container(
                    child: GestureDetector(
                        child: Text(S.of(context).dialogMembers),
                        onTap: () async {
                          NavigationService.instance.goBack();
                          NavigationService.instance
                              .navigateToRoute(MaterialPageRoute(
                            builder: (BuildContext _context) =>
                              DialogMembersPage(this.widget.requestId, provider.theme),
                          ));
                        }),
                  )),
                ];
              })
            ],
          ),
          body: _dialogUI(provider),
          floatingActionButton: Padding(
            padding: EdgeInsets.symmetric(vertical: _deviceHeight * 0.1),
            child: Consumer<DialogButtonProvider>(
              builder: (_, dialogProvider, __) {
                provider.dialogButton = dialogProvider;
                return DialogBottomButtonWidget(provider: dialogProvider, onPressed: _scrollMessagesListToBottom);
              }
            )
          )
        ));
  }

  Widget _dialogUI(DialogProvider provider) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Column(
        children: [
          Expanded(child: _messagesListUI(provider)),
          Container(
              child: (provider.uploads.length > 0)
                  ? Container(
                      color: Colors.grey[200],
                      height: 110,
                      child: HorizontalAttachmentsListWidget(uploads: provider.uploads, onRemove: provider.onRemoveUpload,)
                    )
                  : Container()),
          (!provider.isError) 
            ? Container(
                child: DialogMessageFieldWidget(provider: provider, requestId: this.widget.requestId)
              )
            : Container()
        ],
      ),
    );
  }

  Widget _messagesListUI(DialogProvider provider) {
    var requestId = this.widget.requestId;
    if (requestId != null) {
      return Container(
          height: _deviceHeight,
          width: _deviceWidth,
          margin: EdgeInsets.only(top: 5),
          child: StreamBuilder<List<Message>>(
              initialData: provider.messages,
              stream: provider.messagesStream,
              builder: (BuildContext _context, snapshot) {
                if (provider.isError) {
                  return FailureWidget(text: S.of(context).messageListLoadingError);
                }
                if ((snapshot.connectionState == ConnectionState.active) || (snapshot.connectionState == ConnectionState.done)) {
                  return _messagesListView(provider);
                } else if (provider.messages.isNotEmpty) {
                  return _messageListViewWithLoading(provider);
                } else {
                  return LoadingWidget();
                }
              })
      );
    } else
      return Container();
  }

  Widget _messageListViewWithLoading(DialogProvider provider) {
    _scrollToBottomOnMessagesListUpdate(provider);
    return ListView.builder(
      controller: _messagesScrollController,
      itemCount: provider.messages.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return LoadingWidget();
        } else {
          var message = provider.messages[index - 1];
          bool isOwnMessage = message.senderId == provider.auth.user.uid;
          return AutoScrollTag(
              key: ValueKey(index - 1), 
              controller: _messagesScrollController, 
              index: index - 1,
              child: DialogMessageWidget(message: message, isOwnMessage: isOwnMessage, provider: provider)
          );
        }
        
      },
    );
  }

  Widget _messagesListView(DialogProvider provider) {
    _scrollToBottomOnMessagesListUpdate(provider);
    return ListView.builder(
      controller: _messagesScrollController,
      itemCount: provider.messages.length,
      itemBuilder: (BuildContext context, int index) {
        var message = provider.messages[index];
        bool isOwnMessage = message.senderId == provider.auth.user.uid;
        return AutoScrollTag(
          key: ValueKey(index), 
          controller: _messagesScrollController, 
          index: index,
          child: DialogMessageWidget(message: message, isOwnMessage: isOwnMessage, provider: provider)
        );
      },
    );
  }

  void _addScrollTopListener() {
    _messagesScrollController.addListener(() {
      double minScroll = _messagesScrollController.position.minScrollExtent;
      double currentScroll = _messagesScrollController.position.pixels;
      if ((currentScroll == minScroll) && this.widget.provider.isNeedFetchData) {
        print('Fetch more data');
        this.widget.provider.getUserMessages(this.widget.requestId);
        setState(() {});
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _scrollMessagesListToPrevious();
        });
      }
    });
  }

  void _addScrollBottomListener() {
    _messagesScrollController.addListener(() {
      double maxScroll = _messagesScrollController.position.maxScrollExtent;
      double currentScroll = _messagesScrollController.position.pixels;
      var provider = this.widget.provider;
      if (maxScroll == currentScroll) {
        provider.onReachScrollBottom();
      } else {
        provider.onScrollFromBottom();
      }
    });
  }

  void _scrollToBottomOnMessagesListUpdate(DialogProvider provider) {
    if (provider.isNewMessage && _isDialogScrollerAtBottom()) {
      _scrollMessagesListToBottom();
    }
  }

  void _scrollMessagesListToPrevious() {
    _messagesScrollController.scrollToIndex(this.widget.provider.limit, preferPosition: AutoScrollPosition.begin);
  }

  void _scrollMessagesListToBottom() async {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _messagesScrollController.jumpTo(_messagesScrollController.position.maxScrollExtent);
    });
  }

  bool _isDialogScrollerAtBottom() {
    double delta = 100;
    double maxScroll = _messagesScrollController.position.maxScrollExtent;
    double currentScroll = _messagesScrollController.position.pixels;
    return (maxScroll - currentScroll < delta);
  }
 
  @override
  void dispose() {
    super.dispose();
    _messagesScrollController.dispose();
  }
}

