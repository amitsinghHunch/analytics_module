import 'package:flutter/material.dart';
import 'package:hunch_analyitcs/analytics.dart';
import 'package:hunch_analyitcs/locator.dart';
import 'package:hunch_analyitcs/widgets/custom_button.dart';
import 'package:hunch_analyitcs/widgets/radio_button.dart';

enum OptionType {
  onBackButton,
  onFifthVote,
  onSecondAppLaunch,
  onMorethanOneAppLaunch,
  onFirstChatCompletion
}

final AnalyticsServices _analyticsServices = locator.get<AnalyticsServices>();
Future<void> feedbackBottomsheet(BuildContext context, OptionType optionType,
    {String nativeDisplayType = ""}) {
  int selectedIndex = -1;
  String selectedOption = "none";
  String selectedQuestion = "none";

  bool submit = false;
  return showModalBottomSheet(
      isScrollControlled: true,
      enableDrag: false,
      isDismissible: true,
      context: context,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          // controller: scrollController,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(36, 34, 34, 23),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    Column(
                      children: [
                        Visibility(
                          visible: submit,
                          child: Column(
                            children: [
                              Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 30, 0, 30),
                                  child: Image.asset(
                                      'assets/images/big-smile.png',
                                      height: 96)),
                              Text(
                                "Thank you for your\n"
                                "feedback!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 30,
                                  height: 1.5,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!submit) ...[
                          ...questionList
                              .where((items) => items.optionType == optionType)
                              .map((item) {
                            selectedQuestion = item.title;
                            return Column(
                              children: [
                                Text(
                                  item.title,
                                  style: TextStyle(
                                      fontSize: 30,
                                      height: 1.5,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface),
                                ),
                                ...item.options.asMap().entries.map((e) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 20, 0, 0),
                                    child: RadioButton(
                                      context: context,
                                      isSelected: ValueNotifier<bool>(
                                          selectedIndex == e.key),
                                      onPressed: () {
                                        setState(() {
                                          selectedIndex = e.key;
                                          selectedOption = e.value.label;
                                        });
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          if (e.value.image != null) ...[
                                            Text(
                                              e.value.image,
                                              maxLines: 1,
                                              style: const TextStyle(
                                                fontSize: 24,
                                              ),
                                            ),
                                          ],
                                          Flexible(
                                            fit: FlexFit.tight,
                                            child: Text(
                                              e.value.label,
                                              maxLines: 1,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ],
                            );
                          }),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
                            child: CustomButton(
                              label: "Submit",
                              isDisabled: ValueNotifier(selectedIndex == -1),
                              onPressed: selectedIndex == -1
                                  ? null
                                  : () {
                                      // Handle button press here
                                      _analyticsServices.track(
                                          _analyticsServices
                                              .feedEvents.review_submitted,
                                          {
                                            _analyticsServices.property
                                                .question: selectedQuestion,
                                            _analyticsServices.property
                                                .response: selectedOption,
                                            _analyticsServices
                                                    .property.feedback_type:
                                                nativeDisplayType
                                          });

                                      setState(() {
                                        submit = true;
                                      });
                                    },
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Padding(
                              padding: EdgeInsets.fromLTRB(0, 21, 0, 0),
                              child: Text(
                                "Cancel",
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF383838),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      });
}

class QuestionItem {
  QuestionItem({
    required this.title,
    required this.optionType,
    this.options,
  });

  String title;
  OptionType optionType;
  List<Option>? options;
}

class Option {
  Option({required this.label, this.value, this.image});
  String label;
  String? value;
  String? image;
}

final List questionList = [
  QuestionItem(
    title: "Did you enjoy using Hunch?",
    optionType: OptionType.onBackButton,
    options: [
      Option(label: ' Loved it. Will use it again', image: "😍"),
      Option(label: ' It was okay. Might use it again', image: "🙂"),
      Option(label: ' Blah. Never using it again', image: "😖"),
    ],
  ),
  QuestionItem(
    title:
        "Are you enjoying the experience of knowing what other people think?",
    optionType: OptionType.onFifthVote,
    options: [
      Option(label: ' It’s fun!', image: "🤩"),
      Option(label: ' It’s boring', image: "😕"),
      Option(label: ' It needs to improve', image: "😖"),
    ],
  ),
  QuestionItem(
    title: "What do you love most about Hunch?",
    optionType: OptionType.onSecondAppLaunch,
    options: [
      Option(label: ' User Interface & Design', image: "🧑‍🎨"),
      Option(label: ' Content is amazing', image: "🖋️"),
      Option(label: ' Ease of use & overall experience', image: "💫"),
    ],
  ),
  QuestionItem(
    title: "What do you think about Hunch?",
    optionType: OptionType.onMorethanOneAppLaunch,
    options: [
      Option(label: ' It’s fun', image: "🤩"),
      Option(label: ' It’s informative', image: "😎"),
      Option(label: ' It gets boring after a while', image: "😖"),
    ],
  ),
  QuestionItem(
    title: "Are you enjoying the experience of chat feature?",
    optionType: OptionType.onFirstChatCompletion,
    options: [
      Option(label: ' It’s fun!', image: "🤩"),
      Option(label: ' It’s boring', image: "😕"),
      Option(label: ' It needs to improve', image: "😖"),
    ],
  ),
];
