class WeatherData {
  final String location;
  final double currentTempInC;
  final double currentTempInF;
  final String currentCondition;
  final double currentPressureInBar;
  final double currentPressureInIn;
  final double currentWindSpeedInKph;
  final double currentWindSpeedInMph;
  final int humidity;

  WeatherData(
      {required this.location,
      required this.currentTempInC,
      required this.currentTempInF,
      required this.currentCondition,
      required this.currentPressureInBar,
      required this.currentPressureInIn,
      required this.currentWindSpeedInKph,
      required this.currentWindSpeedInMph,
      required this.humidity});

  factory WeatherData.fromMap(Map<String, dynamic> map) {
    return WeatherData(
        location: map['location']['name'],
        currentTempInC: map['current']['temp_c'],
        currentTempInF: map['current']['temp_f'],
        currentCondition: map['current']['condition']['text'],
        currentPressureInBar: map['current']['pressure_mb'],
        currentPressureInIn: map['current']['pressure_in'],
        currentWindSpeedInKph: map['current']['wind_kph'],
        currentWindSpeedInMph: map['current']['wind_mph'],
        humidity: map['current']['humidity']);
  }
}
