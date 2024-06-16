import 'package:flutter/material.dart';
import 'package:komunly/pages/profile/profile_page.dart';
import 'package:komunly/pages/transactions_page.dart';
import 'package:komunly/theme/colors.dart';
import 'package:komunly/widgets/premiumUser.dart';

class NotificationItem extends StatefulWidget {
  final String profilePicture;
  final String username;
  final String description;
  final String action;
  final bool premium;
  final bool verificado;
  final String? user_id;
  final String? post_id;

  const NotificationItem({
    super.key,
    required this.profilePicture,
    required this.username,
    required this.description,
    required this.action,
    required this.premium,
    required this.verificado,
    this.user_id,
    this.post_id,
  });

  @override
  State<NotificationItem> createState() => _PostNotificationState();
}

class _PostNotificationState extends State<NotificationItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        color: Colors.grey[900],
        margin: const EdgeInsets.only(bottom: 6),
        shape: const RoundedRectangleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(widget.profilePicture),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                   widget.premium == true
                        ? Row(
                            children: [
                              PremiumUser(
                                  username: widget.username, fontSize: 14),
                                  const SizedBox(width: 5,),
                              widget.verificado == true
                                  ? const Icon(Icons.check, color: primary, size: 14,)
                                  : const SizedBox.shrink(),
                            ],
                          )
                        : Row(
                            children: [
                              Text(
                                widget.username,
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.white),
                              ),
                                const SizedBox(width: 5,),
                              widget.verificado == true
                                  ? const Icon(Icons.check, color: primary, size: 14,)
                                  : const SizedBox.shrink()
                            ],
                          ),
                    Text(
                      widget.description,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) =>
                            checkRoute(widget.action, widget.user_id)));
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 225, 255, 0),
                    ),
                    child: Text(
                      "Ver",
                      style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

checkRoute(type, userId) {
  if (type == "FOLLOW") {
    return ProfilePage(id: userId);
  } else if (type == "COMMENT" ||
      type == "LIKE" ||
      type == "REPOST" ||
      type == "REQUEST") {
    return ProfilePage(id: userId);
  } else if (type == "DEPOSIT" || type == "CHARGE" || type == "TRANSFERENCE") {
    return TransactionsPage();
  }
}
