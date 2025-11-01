import 'package:flutter/material.dart';
import 'package:lite_x/features/profile/models/profile_model.dart';
import 'package:lite_x/features/profile/view/widgets/edit_profile/horizontal_datapicker.dart';

class BirthdateScreen extends StatefulWidget {
  final ProfileModel profileModel;
  const BirthdateScreen({super.key, required this.profileModel});

  @override
  State<BirthdateScreen> createState() => _BirthdateScreenState();
}

class _BirthdateScreenState extends State<BirthdateScreen> {
  DateTime? selectedDate;
  @override
  Widget build(BuildContext context) {
    bool pickBirthDate = true;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppBar(
              leading: BackButton(),
              title: Text(
                "Birth date",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              actions: [
                GestureDetector(
                  child: Text(
                    "Continue",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  onTap: () {},
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
              Text(
                widget.profileModel.birthDate,
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.grey.withValues(alpha: 0.7),
                ),
              ),
            if (pickBirthDate != true)
              Container(color: Colors.grey, height: 0.2),
            if (pickBirthDate)
              // SizedBox(
              //   height: 200,
              //   child: CupertinoDatePicker(
              //     mode: CupertinoDatePickerMode.date,
              //     changeReportingBehavior: ChangeReportingBehavior.onScrollEnd,
              //     initialDateTime: DateTime(2004, 7, 21),
              //     maximumDate: DateTime(2020),
              //     minimumDate: DateTime(1960),
              //     onDateTimeChanged: (DateTime newDate) {
              //       setState(() => selectedDate = newDate);
              //     },
              //   ),
              // ),
              Center(
                child: HorizontalDatePicker(
                  initialDate: DateTime(2004, 7, 21),
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
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text("Month and day", style: TextStyle(color: Colors.grey)),
            Row(
              children: [
                Icon(Icons.compare_arrows_outlined, size: 25),
                SizedBox(width: 8),
                Text("You follow each other", style: TextStyle(fontSize: 20)),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Remove birth date", style: TextStyle(color: Colors.red)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
