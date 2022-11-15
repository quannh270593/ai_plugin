enum ResultType { time, count, percent }

class ExerciseResult {
  int result = 0;
  ResultType type;

  ExerciseResult({required this.type});
}
