class StoryController {
  int _storyNumber = 1;

  void restart() {
    _storyNumber = 1;
  }

  void nextStory(int choiceNumber) {
    if (_storyNumber == 0) {
      _storyNumber = choiceNumber == 1 ? 2 : 1;
    } else if (_storyNumber == 1) {
      _storyNumber = choiceNumber == 1 ? 2 : 3;
    } else if (_storyNumber == 2) {
      _storyNumber = choiceNumber == 1 ? 5 : 4;
    } else {
      restart();
    }
  }

  bool buttonShouldBeVisible() {
    return _storyNumber < 3;
  }
}
