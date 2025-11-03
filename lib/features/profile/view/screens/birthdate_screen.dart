import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/models/shared.dart';
import 'package:lite_x/features/profile/view/widgets/edit_profile/horizontal_datapicker.dart';

class BirthdateScreen extends StatefulWidget {
  final ProfileModel profileModel;
  const BirthdateScreen({super.key, required this.profileModel});

  @override
  State<BirthdateScreen> createState() => _BirthdateScreenState();
}

class _BirthdateScreenState extends State<BirthdateScreen> {
  DateTime? selectedDate;
  late bool pickBirthDate;

  @override
  void initState() {
    pickBirthDate = widget.profileModel.birthDate.isEmpty;
    selectedDate = null;
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    selectedDate = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.profileModel.birthDate);
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: ListView(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBar(
                  leading: BackButton(
                    onPressed: () async {
                      if (selectedDate == null) {
                        context.pop(widget.profileModel.birthDate);
                        return;
                      }
                      final res = await _showPopupMessage(
                        context: context,
                        message: Text(
                          "this will undo the changes you've made to your birth.",
                        ),
                        title: Text(
                          "Discard changes?",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        cancelText: "Cancel",
                        confirmText: "Discard",
                      );
                      if (res != null && res == true) {
                        context.pop(widget.profileModel.birthDate);
                        return;
                      }
                    },
                  ),
                  title: Text(
                    "Birth date",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  actions: [
                    GestureDetector(
                      child: Text(
                        "Continue",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      onTap: () {
                        if (selectedDate == null) {
                          context.pop(widget.profileModel.birthDate);
                          return;
                        } else {
                          context.pop(
                            formatDate(selectedDate, DateFormatType.fullDate),
                          );
                          return;
                        }
                      },
                    ),
                    SizedBox(width: 16),
                  ],
                ),
                Container(color: Colors.grey, height: 0.2),
                SizedBox(height: 16),
                Text(
                  "This should be the date of birth of the person using the account. Even if you're making an account for your business, event, or cat.",
                ),

                SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    style: TextStyle(),
                    children: <TextSpan>[
                      TextSpan(
                        text:
                            "X uses your age to customize your experience,\nincluding ads, as explained in our ",
                        style: TextStyle(),
                      ),
                      TextSpan(
                        text: "Privacy Policy",
                        style: TextStyle(color: Colors.blue),
                      ),
                      TextSpan(text: ".", style: TextStyle()),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                if (pickBirthDate != true)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        pickBirthDate = true;
                      });
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.profileModel.birthDate,
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.grey.withValues(alpha: 0.7),
                          ),
                        ),
                        Container(color: Colors.grey, height: 0.2),
                      ],
                    ),
                  ),

                if (pickBirthDate)
                  Center(
                    child: HorizontalDatePicker(
                      initialDate:
                          parseFormattedDate(widget.profileModel.birthDate) ??
                          DateTime.now(),
                      onDateChanged: (date) {
                        setState(() {
                          selectedDate = date;
                        });
                      },
                    ),
                  ),

                SizedBox(height: 20),
                Text(
                  "Who can see this?",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Text("Month and day", style: TextStyle(color: Colors.grey)),
                Row(
                  children: [
                    Icon(Icons.compare_arrows_outlined, size: 25),
                    SizedBox(width: 8),
                    Text(
                      "You follow each other",
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
                Container(color: Colors.grey, height: 0.2),
                SizedBox(height: 20),
                Text("Year", style: TextStyle(color: Colors.grey)),
                Row(
                  children: [
                    Icon(Icons.lock_outline, size: 25),
                    SizedBox(width: 8),
                    Text("Only you", style: TextStyle(fontSize: 20)),
                  ],
                ),
                Container(color: Colors.grey, height: 0.2),

                SizedBox(height: 16),

                Text("You can control who sees your birthday on X."),
                Text("Learn more", style: TextStyle(color: Colors.blue)),

                SizedBox(height: 48),
                Container(color: Colors.grey, height: 0.2),
                SizedBox(height: 4),
                if (widget.profileModel.birthDate.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final res = await _showPopupMessage(
                            context: context,
                            message: Text("this will remove it from profile"),
                            title: Text(
                              "Remove date of birth?",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            cancelText: "Cancel",
                            confirmText: "Remove",
                          );

                          if (res != null && res == true) {
                            context.pop("");
                          }
                        },
                        child: Text(
                          "Remove birth date",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool?> _showPopupMessage({
  required BuildContext context,
  required Text title,
  required Text message,
  String confirmText = 'Yes',
  String cancelText = 'No',
}) async {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true, // prevent closing by tapping outside
    builder: (BuildContext context) {
      return AlertDialog(
        title: title,
        content: message,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              cancelText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              confirmText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    },
  );
}
