abstract class Shared{
  static String formatCount(int count){
    String formatedCount;
    if (count < 1000)
      formatedCount = "$count";
    else if (count >= 1000 && count < 1000000) {
      if (count % 1000 == 0)
        formatedCount = "${(count / 1000)}K";
      else
        formatedCount = "${(count / 1000).toStringAsFixed(1)}K";
    } else {
      if (count % 1000000 == 0)
        formatedCount = "${count / 1000000}M";
      else
        formatedCount = "${(count / 1000000).toStringAsFixed(1)}M";
    }
    return formatedCount;
  }
}


class Failure {
  final String message;
  Failure(this.message);
}
