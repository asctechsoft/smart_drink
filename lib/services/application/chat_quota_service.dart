import 'package:shared_preferences/shared_preferences.dart';
import 'package:waternudge/configs/pref_const.dart';
import 'package:waternudge/configs/pref_defaults.dart';
import 'package:waternudge/utils/date_utils.dart';

/// The free AI-chat allowance every device gets each day.
///
/// The count lives in SharedPreferences, so it is per install — the gateway
/// counts the same allowance against the anonymous Firebase uid, which is what
/// actually enforces it. This copy exists so the screen can show how many
/// questions are left and stop the user before a request is spent.
///
/// The day rolls over on the device's own calendar day (the same `YYYY-MM-DD`
/// key the drink log uses), so a user always wakes up to a fresh allowance.
class ChatQuotaService {
  /// Questions granted per device per day.
  static int get perDay => PrefDefaults.chatFreeQuestionsPerDay;

  /// How many questions are still free today.
  Future<int> remainingToday() async {
    final prefs = await SharedPreferences.getInstance();
    return perDay - await _usedToday(prefs);
  }

  /// Marks one question as spent and returns what is left afterwards.
  Future<int> consume() async {
    final prefs = await SharedPreferences.getInstance();
    final used = await _usedToday(prefs);
    final next = (used + 1).clamp(0, perDay);
    await prefs.setString(PrefConst.chatFreeUsedDate, AppDateUtils.todayKey());
    await prefs.setInt(PrefConst.chatFreeUsedCount, next);
    return perDay - next;
  }

  /// Usage stored for today; a counter left over from an earlier day reads as
  /// zero (and is rewritten on the next [consume]).
  Future<int> _usedToday(SharedPreferences prefs) async {
    final storedDate = prefs.getString(PrefConst.chatFreeUsedDate);
    if (storedDate != AppDateUtils.todayKey()) return 0;
    final used = prefs.getInt(PrefConst.chatFreeUsedCount) ?? 0;
    return used.clamp(0, perDay);
  }
}
