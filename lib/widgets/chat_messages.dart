import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final _authenticatedUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .orderBy(
              'createdAt',
              descending: true,
            )
            .snapshots(),
        builder: (ctx, chatSpanshots) {
          if (chatSpanshots.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!chatSpanshots.hasData || chatSpanshots.data!.docs.isEmpty) {
            return const Center(
              child: Text('No messages found.'),
            );
          }

          if (chatSpanshots.hasError) {
            return const Center(
              child: Text('Something went wrong...'),
            );
          }

          final loadedData = chatSpanshots.data!.docs;

          return ListView.builder(
              padding: const EdgeInsets.only(
                bottom: 40,
                left: 13,
                right: 13,
              ),
              reverse: true,
              itemCount: loadedData.length,
              itemBuilder: (ctx, index) {
                final chatMessage = loadedData[index].data();
                final nextChatMessage = index + 1 < loadedData.length
                    ? loadedData[index + 1].data()
                    : null;

                final currentMessageUsernameId = chatMessage['userId'];
                final nextMessageUsernameId =
                    nextChatMessage != null ? nextChatMessage['userId'] : null;
                final nextuserIsSame =
                    nextMessageUsernameId == currentMessageUsernameId;

                if (nextuserIsSame) {
                  return MessageBubble.next(
                    message: chatMessage['text'],
                    isMe: _authenticatedUser.uid == currentMessageUsernameId,
                  );
                } else {
                  return MessageBubble.first(
                    userImage: chatMessage['userImage'],
                    username: chatMessage['username'],
                    message: chatMessage['text'],
                    isMe: _authenticatedUser.uid == currentMessageUsernameId,
                  );
                }
              });
        });
  }
}
