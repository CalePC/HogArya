
class SkillsSelector {
  final List<String> _selected = [];

  List<String> get selected => List.unmodifiable(_selected);
  void updateSkill(String skill, bool selected) {
    if (selected) {
      if (!_selected.contains(skill)) _selected.add(skill);
    } else {
      _selected.remove(skill);
    }
  }
}
