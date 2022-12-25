# Integrate Squadwe with Flutter app

Integrate Squadwe flutter client into your flutter app and talk to your visitors in real time. [Squadwe](https://github.com/squadwe/squadwe) helps you to chat with your visitors and provide exceptional support in real time. To use Squadwe in your flutter app, follow the steps described below.



## 1. Create an Api inbox in Squadwe

Refer to [Create API Channel](https://www.squadwe.com/docs/product/channels/api/create-channel) document.

## 2. Add the package to your project

Run the command below in your terminal

`flutter pub add squadwe_client_sdk`

or

Add 
`squadwe_client_sdk:<<version>>` 
to your project's [pubspec.yml](https://flutter.dev/docs/development/tools/pubspec) file. You can check [here](https://pub.dev/packages/squadwe_client_sdk) for the latest version.

NB: This library uses [Hive](https://pub.dev/packages/hive) for local storage and [Flutter Chat UI](https://pub.dev/packages/flutter_chat_ui) for its user interface.

## 3. How to use
Replace `baseUrl` and `inboxIdentifier` with appropriate values. See [here](https://www.squadwe.com/docs/product/channels/api/client-apis) for more information on how to obtain your `baseUrl` and `inboxIdentifier`

### a. Using SquadweChatDialog
Simply call `SquadweChatDialog.show` with your parameters to show chat dialog. To close dialog use `Navigator.pop(context)`.

```
// Example
SquadweChatDialog.show(
  context,
  baseUrl: "<<<your-squadwe-base-url-here>>>",
  inboxIdentifier: "<<<your-inbox-identifier-here>>>",
  title: "Squadwe Support",
  user: SquadweUser(
    identifier: "john@gmail.com",
    name: "John Samuel",
    email: "john@gmail.com",
  ),
);
```
#### Available Parameters
| Name              | Default                   | Type         | Description                                                                                                                                                                                                                                                                                                                                                                                                                                         |
|-------------------|---------------------------|--------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| context           | -                         | BuildContext | Current BuildContext                                                                                                                                                                                                                                                                                                                                                                                                                                |
| baseUrl           | -                         | String       | Installation url for squadwe                                                                                                                                                                                                                                                                                                                                                                                                                       |
| inboxIdentifier   | -                         | String       | Identifier for target squadwe inbox                                                                                                                                                                                                                                                                                                                                                                                                                |
| enablePersistance | true                      | bool         | Enables persistence of squadwe client instance's contact, conversation and messages to disk <br>for convenience.<br>true - persists squadwe client instance's data(contact, conversation and messages) to disk. To clear persisted <br>data call SquadweClient.clearData or SquadweClient.clearAllData<br>false - holds squadwe client instance's data in memory and is cleared as<br>soon as squadwe client instance is disposed<br>Setting  |
| title             | -                         | String       | Title for modal                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| user              | null                      | SquadweUser | Custom user details to be attached to squadwe contact                                                                                                                                                                                                                                                                                                                                                                                              |
| primaryColor      | Color(0xff1f93ff)         | Color        | Primary color for SquadweChatTheme                                                                                                                                                                                                                                                                                                                                                                                                                 |
| secondaryColor    | Colors.white              | Color        | Secondary color for SquadweChatTheme                                                                                                                                                                                                                                                                                                                                                                                                               |
| backgroundColor   | Color(0xfff4f6fb)         | Color        | Background color for SquadweChatTheme                                                                                                                                                                                                                                                                                                                                                                                                              |
| l10n              | SquadweL10n()            | SquadweL10n | Localized strings for SquadweChat widget.                                                                                                                                                                                                                                                                                                                                                                                                          |
| timeFormat        | DateFormat.Hm()           | DateFormat   | Date format for chats                                                                                                                                                                                                                                                                                                                                                                                                                               |
| dateFormat        | DateFormat("EEEE MMMM d") | DateFormat   | Time format for chats      

### b. Using SquadweChat Widget
To embed SquadweChat widget inside a part of your app, use the `SquadweChat` widget. Customize chat UI theme by passing a `SquadweChatTheme` with your custom theme colors and more.

```
import 'package:squadwe_client_sdk/squadwe_client_sdk.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return SquadweChat(
      baseUrl: "<<<your-squadwe-base-url-here>>>",
      inboxIdentifier: "<<<your-inbox-identifier-here>>>",
      user: SquadweUser(
        identifier: "john@gmail.com",
        name: "John Samuel",
        email: "john@gmail.com",
      ),
      appBar: AppBar(
        title: Text(
          "Squadwe",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: Colors.white,
      ),
      onWelcome: (){
        print("Welcome event received");
      },
      onPing: (){
        print("Ping event received");
      },
      onConfirmedSubscription: (){
        print("Confirmation event received");
      },
      onMessageDelivered: (_){
        print("Message delivered event received");
      },
      onMessageSent: (_){
        print("Message sent event received");
      },
      onConversationIsOffline: (){
        print("Conversation is offline event received");
      },
      onConversationIsOnline: (){
        print("Conversation is online event received");
      },
      onConversationStoppedTyping: (){
        print("Conversation stopped typing event received");
      },
      onConversationStartedTyping: (){
        print("Conversation started typing event received");
      },
    );
  }
}
```

Horray! You're done.

#### Available Parameters
| Name              | Default                   | Type                | Description                                                                                                                                                                                                                                                                                                                                                                                                                                         |
|-------------------|---------------------------|---------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| appBar            | null                      | PreferredSizeWidget | Specify appBar if widget is being used as standalone page                                                                                                                                                                                                                                                                                                                                                                                           |
| baseUrl           | -                         | String              | Installation url for squadwe                                                                                                                                                                                                                                                                                                                                                                                                                       |
| inboxIdentifier   | -                         | String              | Identifier for target squadwe inbox                                                                                                                                                                                                                                                                                                                                                                                                                |
| enablePersistance | true                      | bool                | Enables persistence of squadwe client instance's contact, conversation and messages to disk <br>for convenience.<br>true - persists squadwe client instance's data(contact, conversation and messages) to disk. To clear persisted <br>data call SquadweClient.clearData or SquadweClient.clearAllData<br>false - holds squadwe client instance's data in memory and is cleared as<br>soon as squadwe client instance is disposed<br>Setting  |
| user              | null                      | SquadweUser        | Custom user details to be attached to squadwe contact                                                                                                                                                                                                                                                                                                                                                                                              |
| l10n              | SquadweL10n()            | SquadweL10n        | Localized strings for SquadweChat widget.                                                                                                                                                                                                                                                                                                                                                                                                          |
| timeFormat        | DateFormat.Hm()           | DateFormat          | Date format for chats                                                                                                                                                                                                                                                                                                                                                                                                                               |
| dateFormat        | DateFormat("EEEE MMMM d") | DateFormat          | Time format for chats                                                                                                                                                                                                                                                                                                                                                                                                                               |
| showAvatars       | true                      | bool                | Show avatars for received messages                                                                                                                                                                                                                                                                                                                                                                                                                  |
| showUserNames     | true                      | bool                | Show user names for received messages. 


### c. Using Squadwe Client
You can also create a customized chat ui and use `SquadweClient` to load and sendMessages. Messaging events like `onMessageSent` and `onMessageReceived` will be triggered on `SquadweCallback` passed when creating the client instance.

```
final squadweCallbacks = SquadweCallbacks(
      onWelcome: (){
        print("on welcome");
      },
      onPing: (){
        print("on ping");
      },
      onConfirmedSubscription: (){
        print("on confirmed subscription");
      },
      onConversationStartedTyping: (){
        print("on conversation started typing");
      },
      onConversationStoppedTyping: (){
        print("on conversation stopped typing");
      },
      onPersistedMessagesRetrieved: (persistedMessages){
        print("persisted messages retrieved");
      },
      onMessagesRetrieved: (messages){
        print("messages retrieved");
      },
      onMessageReceived: (squadweMessage){
        print("message received");
      },
      onMessageDelivered: (squadweMessage, echoId){
        print("message delivered");
      },
      onMessageSent: (squadweMessage, echoId){
        print("message sent");
      },
      onError: (error){
        print("Ooops! Something went wrong. Error Cause: ${error.cause}");
      },
    );
    
    SquadweClient.create(
        baseUrl: widget.baseUrl,
        inboxIdentifier: widget.inboxIdentifier,
        user: widget.user,
        enablePersistence: widget.enablePersistence,
        callbacks: squadweCallbacks
    ).then((client) {
        client.loadMessages();
    }).onError((error, stackTrace) {
      print("squadwe client creation failed with error $error: $stackTrace");
    });
```
#### Available Parameters
| Name              | Default | Type              | Description                                                                                                                                                                                                                                                                                                                                                                                                                                         |
|-------------------|---------|-------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| baseUrl           | -       | String            | Installation url for squadwe                                                                                                                                                                                                                                                                                                                                                                                                                       |
| inboxIdentifier   | -       | String            | Identifier for target squadwe inbox                                                                                                                                                                                                                                                                                                                                                                                                                |
| enablePersistance | true    | bool              | Enables persistence of squadwe client instance's contact, conversation and messages to disk <br>for convenience.<br>true - persists squadwe client instance's data(contact, conversation and messages) to disk. To clear persisted <br>data call SquadweClient.clearData or SquadweClient.clearAllData<br>false - holds squadwe client instance's data in memory and is cleared as<br>soon as squadwe client instance is disposed<br>Setting  |
| user              | null    | SquadweUser      | Custom user details to be attached to squadwe contact                                                                                                                                                                                                                                                                                                                                                                                              |
| callbacks         | null    | SquadweCallbacks | Callbacks for handling squadwe events                                                                                                                                                                                                                                                                                                                                                                                                              |

