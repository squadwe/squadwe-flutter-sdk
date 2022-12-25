import 'package:squadwe_client_sdk/data/local/entity/squadwe_user.dart';
import 'package:squadwe_client_sdk/ui/squadwe_chat_theme.dart';
import 'package:squadwe_client_sdk/ui/squadwe_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:intl/intl.dart';

import 'squadwe_chat_page.dart';

///Squadwe chat modal widget
/// {@category FlutterClientSdk}
class SquadweChatDialog extends StatefulWidget {
  static show(
    BuildContext context, {
    required String baseUrl,
    required String inboxIdentifier,
    bool enablePersistence = true,
    required String title,
    SquadweUser? user,
    Color? primaryColor,
    Color? secondaryColor,
    Color? backgroundColor,
    SquadweL10n? l10n,
    DateFormat? timeFormat,
    DateFormat? dateFormat,
  }) {
    showDialog(
        context: context,
        builder: (context) {
          return SquadweChatDialog(
            baseUrl: baseUrl,
            inboxIdentifier: inboxIdentifier,
            title: title,
            user: user,
            enablePersistence: enablePersistence,
            primaryColor: primaryColor,
            secondaryColor: secondaryColor,
            backgroundColor: backgroundColor,
            l10n: l10n,
            timeFormat: timeFormat,
            dateFormat: dateFormat,
          );
        });
  }

  ///Installation url for squadwe
  final String baseUrl;

  ///Identifier for target squadwe inbox.
  ///
  /// For more details see https://www.squadwe.com/docs/product/channels/api/client-apis
  final String inboxIdentifier;

  /// Enables persistence of squadwe client instance's contact, conversation and messages to disk
  /// for convenience.
  ///
  /// Setting [enablePersistence] to false holds squadwe client instance's data in memory and is cleared as
  /// soon as squadwe client instance is disposed
  final bool enablePersistence;

  /// Custom user details to be attached to squadwe contact
  final SquadweUser? user;

  /// Primary color for [SquadweChatTheme]
  final Color? primaryColor;

  /// Secondary color for [SquadweChatTheme]
  final Color? secondaryColor;

  /// Secondary color for [SquadweChatTheme]
  final Color? backgroundColor;

  /// See [SquadweL10n]
  final String title;

  /// See [SquadweL10n]
  final SquadweL10n? l10n;

  /// See [Chat.timeFormat]
  final DateFormat? timeFormat;

  /// See [Chat.dateFormat]
  final DateFormat? dateFormat;

  const SquadweChatDialog({
    Key? key,
    required this.baseUrl,
    required this.inboxIdentifier,
    this.enablePersistence = true,
    required this.title,
    this.user,
    this.primaryColor,
    this.secondaryColor,
    this.backgroundColor,
    this.l10n,
    this.timeFormat,
    this.dateFormat,
  }) : super(key: key);

  @override
  _SquadweChatDialogState createState() => _SquadweChatDialogState();
}

class _SquadweChatDialogState extends State<SquadweChatDialog> {
  late String status;
  late SquadweL10n localizedStrings;

  @override
  void initState() {
    super.initState();
    this.localizedStrings = widget.l10n ?? SquadweL10n();
    this.status = localizedStrings.offlineText;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.all(8.0),
      child: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          Visibility(
                            visible: status != localizedStrings.offlineText,
                            child: Container(
                              width: 10,
                              height: 10,
                              margin: EdgeInsets.only(left: 8),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          status,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.close,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
              ],
            ),
            Flexible(
              child: SquadweChat(
                baseUrl: widget.baseUrl,
                inboxIdentifier: widget.inboxIdentifier,
                user: widget.user,
                enablePersistence: widget.enablePersistence,
                timeFormat: widget.timeFormat,
                dateFormat: widget.dateFormat,
                theme: SquadweChatTheme(
                    primaryColor: widget.primaryColor ?? SQUADWE_COLOR_PRIMARY,
                    secondaryColor: widget.secondaryColor ?? Colors.white,
                    backgroundColor:
                        widget.backgroundColor ?? SQUADWE_BG_COLOR,
                    userAvatarNameColors: [
                      widget.primaryColor ?? SQUADWE_COLOR_PRIMARY
                    ]),
                isPresentedInDialog: true,
                onConversationIsOffline: () {
                  setState(() {
                    status = localizedStrings.offlineText;
                  });
                },
                onConversationIsOnline: () {
                  setState(() {
                    status = localizedStrings.onlineText;
                  });
                },
                onConversationStoppedTyping: () {
                  setState(() {
                    if (status == localizedStrings.typingText) {
                      status = localizedStrings.onlineText;
                    }
                  });
                },
                onConversationStartedTyping: () {
                  setState(() {
                    status = localizedStrings.typingText;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
