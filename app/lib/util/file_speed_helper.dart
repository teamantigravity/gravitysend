import 'package:gravitysend_app/gen/strings.g.dart';

const _millisecondsPerSecond = 1000;
const _secondsPerMinute = 60;
const _secondsPerHour = 3600;
const _secondsPerDay = 86400;

int getFileSpeed({
  required int start,
  required int end,
  required int bytes,
}) {
  final deltaTime = end - start;
  if (deltaTime <= 0) {
    return 0;
  }
  return (_millisecondsPerSecond * bytes) ~/ deltaTime;
}

/// Calculates throughput over a recent sliding window of `(timestamp, bytes)` samples.
/// Use this instead of [getFileSpeed] to avoid speed jumping around because of
/// stalls earlier in the transfer.
int getFileSpeedFromHistory(List<({int time, int bytes})> history) {
  if (history.length < 2) {
    return 0;
  }

  final start = history.first;
  final end = history.last;
  final deltaTime = end.time - start.time;
  final deltaBytes = end.bytes - start.bytes;
  if (deltaTime <= 0 || deltaBytes <= 0) {
    return 0;
  }

  return (_millisecondsPerSecond * deltaBytes) ~/ deltaTime;
}

String getRemainingTime({
  required int bytesPerSeconds,
  required int remainingBytes,
}) {
  if (bytesPerSeconds == 0) {
    return remainingBytes == 0 ? t.progressPage.remainingTime.seconds(n: 0, ss: '00') : '∞';
  }

  final remainingTimeInSeconds = _getRemainingTime(bytesPerSeconds: bytesPerSeconds, remainingBytes: remainingBytes);

  if (remainingTimeInSeconds < _secondsPerMinute) {
    return t.progressPage.remainingTime.seconds(n: 0, ss: remainingTimeInSeconds.toString().padLeft(2, '0'));
  } else if (remainingTimeInSeconds < _secondsPerHour) {
    final minutes = remainingTimeInSeconds ~/ _secondsPerMinute;
    final seconds = remainingTimeInSeconds % _secondsPerMinute;
    return t.progressPage.remainingTime.minutes(n: minutes, ss: seconds.toString().padLeft(2, '0'));
  } else if (remainingTimeInSeconds < _secondsPerDay) {
    final hours = remainingTimeInSeconds ~/ _secondsPerHour;
    final minutes = (remainingTimeInSeconds % _secondsPerHour) ~/ _secondsPerMinute;
    return t.progressPage.remainingTime.hours(h: hours, m: minutes);
  } else {
    final days = remainingTimeInSeconds ~/ _secondsPerDay;
    final remainingAfterDays = remainingTimeInSeconds % _secondsPerDay;
    final hours = remainingAfterDays ~/ _secondsPerHour;
    final minutes = (remainingAfterDays % _secondsPerHour) ~/ _secondsPerMinute;
    return t.progressPage.remainingTime.days(d: days, h: hours, m: minutes);
  }
}

int _getRemainingTime({
  required int bytesPerSeconds,
  required int remainingBytes,
}) {
  return remainingBytes ~/ bytesPerSeconds;
}
